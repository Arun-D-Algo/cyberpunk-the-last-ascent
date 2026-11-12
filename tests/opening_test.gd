extends "res://tests/tower_test.gd"
## Candidate discovery uses the actual solver. Final replay never resets between pads.
var tolerances: Array[Dictionary] = []
var falls: Array[Dictionary] = []

func _run() -> void:
	var boot := preload("res://scenes/main/boot.tscn").instantiate()
	root.add_child(boot)
	current_scene = boot
	boot.enter_ascent()
	await process_frame
	await process_frame
	check(current_scene is OpeningAscent, "Main-menu ascent opens the production scene")
	if not current_scene is OpeningAscent:
		quit(1)
		return
	tower = current_scene as OpeningAscent
	world = tower
	body = tower.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder")
	await _ticks(8)
	_check_world()
	var previous: Rect2 = Rect2(16, 144, 288, 24)
	for row: Dictionary in tower.route:
		var found: bool = false
		for offset: float in [0.0, -8.0, 8.0, -16.0, 16.0, -24.0, 24.0, -32.0, 32.0, -48.0, 48.0, -64.0, 64.0]:
			if absf(offset) > previous.size.x / 2.0 - 5.0:
				continue
			var launch_x: float = previous.get_center().x + offset
			for charge_ticks: int in (range(6, 46) if row.zone == 0 else range(45, 5, -1)):
				var hold: float = charge_ticks * DT
				body.reset_movement(Vector2(launch_x, previous.position.y))
				await _ticks(8)
				await _charge(hold, row.direction)
				await _tick(row.direction, false, false, true)
				await _finish_jump()
				if body.is_on_floor() and String(body.last_landing_surface) == row.id and (body.rebound_count == 1 if row.ricochet else (body.rebound_count == 0 if row.zone == 0 else true)):
					await _brake()
					if body.is_on_floor() and String(body.surface_body_name) == row.id and body.position.x > row.rect.position.x + 6.0 and body.position.x < row.rect.end.x - 6.0:
						recipes.append({"id": row.id, "x": launch_x, "hold": hold, "direction": row.direction, "landing": body.position, "rebounds": body.rebound_count})
						found = true
						break
			if found:
				break
		check(found, "Reachable mandatory landing " + row.id)
		if not found:
			print("UNREACHABLE ", row, " from ", previous, " last ", body.position, " ", body.last_landing_surface, " trace ", recorder.last_jump)
			break
		print("ROUTE ", recipes[-1])
		previous = row.rect
	check(recipes.size() == 36, "Thirty-six solver-validated interactions")
	if recipes.size() == 36:
		await _check_falls()
		await _check_tolerances()
		await _continuous_replay()
	var file: FileAccess = FileAccess.open("res://.godot/opening_measurements.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"recipes": recipes, "tolerances": tolerances, "recovery_falls": falls, "checks": checks, "failures": failures, "replay_seconds": replay_seconds, "fall": fall_result}, "\t"))
	if failures.is_empty():
		print("PASS: %d opening checks / 36 continuous landings" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d opening checks" % [failures.size(), checks])
		quit(1)

func _continuous_replay() -> void:
	tower.reset_ascent()
	await _ticks(8)
	var replay_start: int = elapsed_ticks
	for recipe: Dictionary in recipes:
		check(await _walk(recipe.x), "Walk to launch continuously " + recipe.id)
		var previous_rebounds: int = body.rebound_count
		await _charge(recipe.hold, recipe.direction)
		await _tick(recipe.direction, false, false, true)
		await _finish_jump()
		check(body.rebound_count - previous_rebounds == recipe.rebounds, "Continuous collision sequence " + recipe.id)
		check(String(body.last_landing_surface) == recipe.id and body.is_on_floor(), "Continuous landing " + recipe.id)
		await _brake()
		if not body.is_on_floor() or String(body.surface_body_name) != recipe.id:
			check(false, "Continuous route lost support " + recipe.id)
			return
	replay_seconds = (elapsed_ticks - replay_start) * DT
	check(tower.zone_index == 2, "Climb crosses all three sections")
	check(body.maximum_height > 1600, "Continuous world height recorded")
	# Walk off summit into the open side lane: no teleport or automatic retry.
	for tick: int in 100:
		await _tick(-1)
		if not body.is_on_floor():
			break
	var start_y: float = body.position.y
	var fall_start: int = elapsed_ticks
	var peak_fall_speed: float = 0.0
	for tick: int in 600:
		await _tick()
		peak_fall_speed = maxf(peak_fall_speed, body.velocity.y)
		await process_frame
		if absf(body.position.y - tower.camera.position.y) >= 91.0 and tick < 10:
			print("CAMERA ", body.position, " ", tower.camera.position)
		check(absf(body.position.y - tower.camera.position.y) < 91.0, "Long-fall camera keeps player visible")
		if body.is_on_floor() and body.position.y > start_y + 200.0:
			break
	fall_result = {"start_y": start_y, "landing_y": body.position.y, "drop": body.position.y - start_y, "seconds": (elapsed_ticks - fall_start) * DT, "peak_speed": peak_fall_speed, "zone_after": tower.zone_index + 1}
	check(body.is_on_floor() and body.position.y > start_y + 200, "Long fall catches earlier solid geometry")
	check(tower.zone_index < 2, "Fall returns to earlier zone")
	await _ticks(6)
	var catch_index := -1
	for index in tower.route.size():
		if tower.route[index].id == String(body.surface_body_name):
			catch_index = index
	check(catch_index >= 0, "Fall catches a route destination")
	if catch_index >= 0 and catch_index + 1 < recipes.size():
		var recovery: Dictionary = recipes[catch_index + 1]
		check(await _walk(recovery.x), "Walk into recovery launch position")
		await _charge(recovery.hold, recovery.direction)
		await _tick(recovery.direction, false, false, true)
		await _finish_jump()
		check(String(body.last_landing_surface) == recovery.id, "Recover onto the next ascent destination")
	await _charge(0.3, 0)
	check(body.state == PlayerController.State.CHARGING, "Recovery can charge after long fall")
	tower.toggle_pause()
	var paused_at: Vector2 = body.position
	await _ticks(3)
	check(body.position == paused_at and body.charge_duration == 0.0, "Pause cancels charge without movement")
	tower.toggle_pause()
	tower.reset_ascent()
	await _ticks(8)
	check(body.is_on_floor() and body.position.distance_to(TowerAscent.SPAWN) < 0.1, "Explicit reset reacquires base")


func _check_world() -> void:
	check(tower.route.size() == 36, "Opening contains 36 authored destinations")
	check(body.get_node("CollisionShape2D").shape.size == Vector2(10, 24), "Approved player collider")
	check(body.get_node("Visual/David").sprite_frames == preload("res://resources/visuals/david_frames_cinematic.tres"), "Approved character art")
	check(tower.get_node("Scenery").get_child(0) is OpeningBackdrop, "Authored backdrop loads")
	for row: Dictionary in tower.route:
		var machine := tower.get_node("Geometry/" + row.id) as OpeningMachine
		check(machine != null and machine.size == row.rect.size, "Complete casing bounds " + row.id)
		check(machine.collision_layer == 1 and machine.collision_mask == 2, "Collision layers " + row.id)
		check(machine.get_child(0).shape.size == machine.size, "Collider matches casing " + row.id)
	for asset in ["machinery", "facade", "ventilation", "transformers", "city_depth"]:
		var path: String = "res://assets/environment/opening/" + asset + ".png"
		var texture := load(path) as Texture2D
		check(texture != null and not texture.get_image().has_mipmaps(), "Pixel texture " + asset)
	check(tower.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "Scene inherits approved nearest filtering")
	check(tower.get_node("Scenery").process_mode == Node.PROCESS_MODE_PAUSABLE, "Ambient effects pause with gameplay")

func _check_tolerances() -> void:
	var previous := Rect2(16, 144, 288, 24)
	for index in recipes.size():
		var recipe: Dictionary = recipes[index]
		var row: Dictionary = tower.route[index]
		var successes := [0, 0]
		for group in 2:
			for side in [-1, 1]:
				var x: float = recipe.x + (side * 2.0 if group == 1 else 0.0)
				var hold: float = recipe.hold + (side * DT if group == 0 else 0.0)
				body.reset_movement(Vector2(x, previous.position.y))
				await _ticks(8)
				await _charge(hold, recipe.direction)
				await _tick(recipe.direction, false, false, true)
				await _finish_jump()
				if body.is_on_floor() and String(body.last_landing_surface) == recipe.id:
					successes[group] += 1
		tolerances.append({"id": recipe.id, "adjacent_charge_ticks": successes[0], "two_pixel_offsets": successes[1],
			"rise": previous.position.y - row.rect.position.y, "center_dx": row.rect.get_center().x - recipe.x})
		check(successes[0] > 0 and successes[1] > 0, "Reproducible timing and position window " + recipe.id)
		previous = row.rect


func _check_falls() -> void:
	for index in [2, 16, 30]:
		var row: Dictionary = tower.route[index]
		body.reset_movement(Vector2(row.rect.get_center().x, row.rect.position.y))
		tower.camera.reset_tracking()
		await _ticks(8)
		for tick in 90:
			await _tick(-1)
			if not body.is_on_floor():
				break
		var start_y := body.position.y
		for tick in 400:
			await _tick()
			await process_frame
			check(absf(body.position.y - tower.camera.position.y) < 91, "Recovery fall camera")
			if body.is_on_floor():
				break
		check(body.is_on_floor() and body.position.y > start_y, "Miss catches earlier geometry " + row.id)
		falls.append({"from": row.id, "to": body.last_landing_surface, "drop": body.position.y - start_y})
		await _ticks(6)
		await _tick(0, true, true)
		check(body.state == PlayerController.State.CHARGING, "Fresh charge after setback " + row.id)
