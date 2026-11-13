extends "res://tests/tower_test.gd"
## Discover using the actual controller, then replay from the normal entry without teleports.
var opening: OpeningAscent
var measured: Dictionary = {}
var recovery: Dictionary = {}
var audit: Dictionary = {}

func _run() -> void:
	var boot := preload("res://scenes/main/boot.tscn").instantiate()
	root.add_child(boot)
	current_scene = boot
	boot.enter_ascent()
	await process_frame
	await process_frame
	opening = current_scene as OpeningAscent
	check(opening != null, "Main menu loads the opening")
	if opening == null:
		quit(1)
		return
	tower = opening
	world = opening
	body = opening.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder")
	await _ticks(8)
	_check_world()
	var groups: Array = [OpeningRoute.MAIN]
	groups.append_array(OpeningRoute.BRANCHES)
	for group: Array in groups:
		for edge: Array in group:
			var recipe := await _discover(edge)
			check(not recipe.is_empty(), "Reachable " + _key(edge))
			if recipe.is_empty():
				print("UNREACHABLE ", edge, " ", recorder.last_jump)
				continue
			measured[_key(edge)] = recipe
			print("EDGE ", _key(edge), " ", recipe)
	if not failures.is_empty():
		quit(1)
		return
	_check_graph(groups)
	_audit_layout()
	tower.reset_ascent()
	await _ticks(8)
	await _replay(OpeningRoute.MAIN)
	check(opening.zone_index == 2, "Route crosses both section boundaries")
	for fork: Array in OpeningRoute.BRANCHES.slice(0, 3):
		var start: String = fork[0][0]
		var finish: String = fork[-1][1]
		var before := _main_index(start)
		var after := _main_index(finish)
		tower.reset_ascent()
		await _ticks(8)
		await _replay(OpeningRoute.MAIN.slice(0, before) + fork + OpeningRoute.MAIN.slice(after))
		check(String(body.surface_body_name) == "Summit", "Fork reaches summit " + start)
	await _check_recovery()
	var report := FileAccess.open("res://.godot/opening_measurements.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"edges": measured, "recovery": recovery, "audit": audit, "checks": checks, "failures": failures}, "	"))
	print("Opening checks: %d, validated jumps: %d, failures: %d" % [checks, measured.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)

func _key(edge: Array) -> String:
	return "%s > %s" % [edge[0], edge[1]]

func _discover(edge: Array) -> Dictionary:
	var source: Rect2 = opening.surfaces[edge[0]]
	var target: Rect2 = opening.surfaces[edge[1]]
	var expected: int = edge[3] if edge.size() > 3 else 0
	var charge_order: Array[int] = [35, 40, 45, 30, 25, 20, 15, 10]
	if edge[1] == "InspectionPocket":
		charge_order = [26, 25, 27]
	for ticks in range(6, 46):
		if ticks not in charge_order:
			charge_order.append(ticks)
	var offsets: Array[int] = [0]
	for offset in range(4, int(source.size.x / 2) - 3, 4):
		offsets.append(offset * edge[2] if edge[2] != 0 else offset)
		offsets.append(-offsets[-1])
	for offset in offsets:
		var launch_x := source.get_center().x + offset
		for ticks in charge_order:
			var result := await _attempt(edge, source, target, launch_x, ticks, expected, 5.0)
			if result.is_empty():
				continue
			var left := await _attempt(edge, source, target, launch_x - 0.75, ticks, expected, 3.0)
			if left.is_empty():
				continue
			var right := await _attempt(edge, source, target, launch_x + 0.75, ticks, expected, 3.0)
			if right.is_empty():
				continue
			var adjacent := 0
			for neighbor: int in [ticks - 1, ticks + 1]:
				if neighbor >= 6 and neighbor <= 45:
					if not (await _attempt(edge, source, target, launch_x, neighbor, expected, 3.0)).is_empty():
						adjacent += 1
			result["adjacent_charge_ticks"] = adjacent
			return result
	return {}

func _attempt(edge: Array, source: Rect2, target: Rect2, launch_x: float, ticks: int,
		expected: int, minimum_margin: float) -> Dictionary:
	body.reset_movement(Vector2(launch_x, source.position.y))
	await _ticks(7)
	if not body.is_on_floor() or String(body.surface_body_name) != edge[0]:
		return {}
	await _route_jump(ticks, edge[2])
	if String(body.last_landing_surface) != edge[1] or body.rebound_count != expected:
		return {}
	await _brake()
	var margin := minf(body.position.x - target.position.x, target.end.x - body.position.x)
	if not body.is_on_floor() or String(body.surface_body_name) != edge[1] or margin < minimum_margin:
		return {}
	return {"x": launch_x, "ticks": ticks, "direction": edge[2], "rebounds": expected,
		"landing_x": body.position.x, "landing_y": body.position.y, "margin": margin,
		"rise": source.position.y - target.position.y, "dx": body.position.x - launch_x,
		"apex": recorder.last_jump.get("peak_height", 0), "ceiling": recorder.last_jump.get("hit_ceiling", false)}

func _route_jump(ticks: int, direction: int) -> void:
	await _charge(ticks * DT, direction)
	await _tick(direction, false, false, true)
	await _finish_jump()

func _replay(edges: Array) -> void:
	for edge: Array in edges:
		var recipe: Dictionary = measured[_key(edge)]
		var positioned := await _walk(recipe.x)
		check(positioned, "Continuous approach " + _key(edge))
		if not positioned:
			return
		var rebounds := body.rebound_count
		await _route_jump(recipe.ticks, recipe.direction)
		await _brake()
		var landed: bool = body.is_on_floor() and String(body.surface_body_name) == edge[1]
		check(landed, "Continuous support " + _key(edge))
		await process_frame
		check(absf(body.position.y - opening.camera.position.y) < 91, "Camera keeps landing visible")
		check(body.rebound_count - rebounds == recipe.rebounds, "Continuous rebound count " + _key(edge))
		if not landed:
			print("REPLAY STOP ", _key(edge), " ", body.position, " ", recorder.last_jump)
			return

func _check_world() -> void:
	check(body.is_on_floor() and String(body.surface_body_name) == "Base", "Exterior spawn is supported")
	check(body.get_node("CollisionShape2D").shape.size == Vector2(10, 24), "Approved collider")
	check(body.get_node("Visual/David").sprite_frames == preload("res://resources/visuals/david_frames_cinematic.tres"), "Approved character art")
	for row: Dictionary in opening.route:
		var machine := opening.get_node("Geometry/" + row.id) as OpeningMachine
		check(machine.collision_layer == 1 and machine.collision_mask == 2, "Collision layers " + row.id)
		if machine.silhouette.is_empty():
			check(machine.get_child(0).shape.size == row.rect.size, "Rectangular casing " + row.id)
		else:
			check(machine.get_child(0).polygon == machine.silhouette, "Shared art/collision outline " + row.id)
	for asset in ["machinery", "facade", "ventilation", "transformers", "city_depth", "wall"]:
		var texture := load("res://assets/environment/opening/%s.png" % asset) as Texture2D
		check(texture != null and not texture.get_image().has_mipmaps(), "Pixel texture " + asset)

func _main_index(surface: String) -> int:
	for index in OpeningRoute.MAIN.size():
		if OpeningRoute.MAIN[index][0] == surface:
			return index
	return OpeningRoute.MAIN.size()

func _check_graph(groups: Array) -> void:
	var links := {}
	for group: Array in groups:
		for edge: Array in group:
			if not links.has(edge[0]):
				links[edge[0]] = []
			links[edge[0]].append(edge[1])
	for row: Dictionary in opening.route:
		var pending: Array = [row.id]
		var seen := {}
		while not pending.is_empty():
			var surface: String = pending.pop_back()
			if seen.has(surface):
				continue
			seen[surface] = true
			pending.append_array(links.get(surface, []))
		check(seen.has("Summit"), "Graph returns every authored landing to summit " + row.id)
	for surface in ["SignBeam", "HousingRoof", "RadiatorHead"]:
		check(links[surface].size() == 2, "Two viable routes at " + surface)

func _check_recovery() -> void:
	await _check_special_surfaces()
	await _drop("GateCanopy", -1, "BadgeReader")
	await _drop("BankTongue", 1, "BusCabinet")
	await _drop("Summit", -1, "TowerFin")
	await _replay(OpeningRoute.MAIN.slice(_main_index("TowerFin"), _main_index("ElevatorShoe")))
	await _drop("TransferBridge", 1, "ChuteCatch", true)
	await _replay(OpeningRoute.BRANCHES[-1])
	check(String(body.surface_body_name) == "PillarSill", "Chute catch reconnects through fan column")
	await _replay(OpeningRoute.MAIN.slice(_main_index("PillarSill"), _main_index("TransferBridge")))
	tower.toggle_pause()
	var paused_at := body.position
	await _ticks(3)
	check(body.position == paused_at, "Pause preserves position")
	tower.reset_ascent()
	await _ticks(8)
	check(body.is_on_floor() and body.position.distance_to(TowerAscent.SPAWN) < 0.1, "Reset reacquires exterior support")

func _drop(source: String, direction: int, target: String, slide_expected := false) -> void:
	var rect: Rect2 = opening.surfaces[source]
	body.reset_movement(Vector2(rect.get_center().x, rect.position.y - 1))
	opening.camera.reset_tracking()
	await _ticks(8)
	for tick in 110:
		await _tick(direction)
		if not body.is_on_floor():
			break
	check(not body.is_on_floor(), "Walk off " + source)
	var committed := 0
	var slide_entry := Vector2.ZERO
	var slide_exit := Vector2.ZERO
	var camera_visible := true
	for tick in 220:
		if body.state == PlayerController.State.FORCED_SLIDING:
			if committed == 0:
				slide_entry = body.position
			committed += 1
			var previous_x: float = body.position.x
			await _tick(1, true, true, true)
			check(body.position.x < previous_x, "Chute ignores uphill and jump input")
			slide_exit = body.position
		else:
			await _tick()
		await process_frame
		camera_visible = camera_visible and absf(body.position.y - opening.camera.position.y) < 91
		if body.is_on_floor() and body.state == PlayerController.State.GROUNDED and String(body.surface_body_name) == target:
			break
	check(camera_visible, "Camera follows fall from " + source)
	check(body.is_on_floor() and String(body.surface_body_name) == target, "Fall catches " + target)
	check((committed > 0) == slide_expected, "Expected chute commitment " + source)
	if slide_expected:
		check(slide_exit.x <= 199, "Committed descent reaches the exit plane")
	recovery[source] = {"catch": body.surface_body_name, "drop": body.position.y - rect.position.y,
		"slide_ticks": committed, "slide_entry_x": slide_entry.x, "slide_exit_x": slide_exit.x}

func _check_special_surfaces() -> void:
	var pocket: Dictionary = measured["GlassLintel > InspectionPocket"]
	body.reset_movement(Vector2(pocket.x, -61))
	await _ticks(8)
	await _route_jump(pocket.ticks, 1)
	check(String(body.surface_body_name) == "InspectionPocket" and not recorder.last_jump.hit_ceiling, "Medium charge clears the lintel")
	body.reset_movement(Vector2(pocket.x, -61))
	await _ticks(8)
	await _route_jump(45, 1)
	check(recorder.last_jump.hit_ceiling, "Full charge strikes the pocket ceiling")
	body.reset_movement(Vector2(77, -312))
	await _ticks(10)
	check(String(body.surface_body_name) == "PipeSaddle" and body.slope_degrees() > 30, "Slope face supports the collider")
	body.reset_movement(Vector2(197, -947))
	await _ticks(8)
	check(body.active_surface.id == &"ice", "Condensation tray uses approved ice profile")
	await _ticks(10, 1)
	var started_x: float = body.position.x
	await _ticks(5)
	check(body.position.x > started_x and absf(body.velocity.x) > 1, "Released input coasts on condensate")

func _audit_layout() -> void:
	var widths := {}
	var profiles := {}
	var min_rise := INF
	var max_rise := 0.0
	var min_span := INF
	var max_span := 0.0
	var longest_alternation := 0
	var alternating := 0
	var previous_direction := 0
	var repeats: Array[String] = []
	var recent: Array[Dictionary] = []
	for row: Dictionary in opening.route:
		var width := int(row.rect.size.x)
		widths[width] = widths.get(width, 0) + 1
		profiles[row.shape] = profiles.get(row.shape, 0) + 1
	for edge: Array in OpeningRoute.MAIN:
		var result: Dictionary = measured[_key(edge)]
		min_rise = minf(min_rise, result.rise)
		max_rise = maxf(max_rise, result.rise)
		min_span = minf(min_span, absf(result.dx))
		max_span = maxf(max_span, absf(result.dx))
		alternating = alternating + 1 if edge[2] != previous_direction else 1
		longest_alternation = maxi(longest_alternation, alternating)
		previous_direction = edge[2]
		recent.append(result)
		if recent.size() > 4:
			recent.pop_front()
		if recent.size() == 4:
			var rises: Array[float] = []
			var spans: Array[float] = []
			for sample: Dictionary in recent:
				rises.append(sample.rise)
				spans.append(absf(sample.dx))
			if rises.max() - rises.min() <= 8 and spans.max() - spans.min() <= 16:
				repeats.append(_key(edge))
	audit = {"widths": widths, "profiles": profiles, "rise": [min_rise, max_rise],
		"span": [min_span, max_span], "longest_alternation": longest_alternation,
		"similar_four_jump_windows": repeats}
	check(widths.size() >= 10, "Authored width distribution stays varied")
	check(longest_alternation < 6, "Same-side runs break alternation")
	if not repeats.is_empty():
		print("DESIGN REVIEW similar four-jump windows ending at ", repeats)
