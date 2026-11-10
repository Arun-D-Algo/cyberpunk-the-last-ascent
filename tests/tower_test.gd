extends "res://tests/physics_test.gd"
## Candidate discovery uses the actual solver. Final replay never resets between pads.
var tower: TowerAscent
var recipes: Array[Dictionary] = []
var elapsed_ticks: int = 0
var replay_seconds: float = 0.0
var fall_result: Dictionary = {}

func _run() -> void:
	tower = preload("res://scenes/levels/tower_ascent.tscn").instantiate()
	root.add_child(tower)
	world = tower
	body = tower.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder")
	await _ticks(8)
	var previous: Rect2 = Rect2(70, 144, 80, 8)
	for row: Dictionary in tower.route:
		var found: bool = false
		for offset: float in [0.0, -8.0, 8.0, -16.0, 16.0, -24.0, 24.0]:
			if absf(offset) > previous.size.x / 2.0 - 5.0:
				continue
			var launch_x: float = previous.get_center().x + offset
			for charge_ticks: int in range(45, 23, -1):
				var hold: float = charge_ticks * DT
				body.reset_movement(Vector2(launch_x, previous.position.y))
				await _ticks(8)
				await _charge(hold, row.direction)
				await _tick(row.direction, false, false, true)
				await _finish_jump()
				if body.is_on_floor() and String(body.last_landing_surface) == row.id and (not row.ricochet or body.rebound_count == 1):
					await _brake()
					if body.is_on_floor() and String(body.surface_body_name) == row.id and body.position.x > row.rect.position.x + 3.0 and body.position.x < row.rect.end.x - 3.0:
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
	check(recipes.size() == 60, "Sixty solver-validated interactions")
	if recipes.size() == 60:
		await _continuous_replay()
	var file: FileAccess = FileAccess.open("res://.godot/tower_measurements.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"recipes": recipes, "checks": checks, "failures": failures, "replay_seconds": replay_seconds, "fall": fall_result}, "\t"))
	if failures.is_empty():
		print("PASS: %d tower checks / 60 continuous landings" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d tower checks" % [failures.size(), checks])
		quit(1)

func _finish_jump() -> void:
	for tick: int in 110:
		if body.is_on_floor() and body.state == PlayerController.State.GROUNDED:
			return
		await _tick()

func _brake() -> void:
	for tick: int in 45:
		if absf(body.velocity.x) < 1.0 or not body.is_on_floor():
			return
		await _tick(0 if absf(body.velocity.x) < 14.0 else -signi(roundi(body.velocity.x)))

func _walk(x: float) -> bool:
	for tick: int in 180:
		if not body.is_on_floor():
			return false
		var error: float = x - body.position.x
		if absf(error) < 0.6 and absf(body.velocity.x) <= body.active_surface.charge_speed_limit:
			return true
		# Slow approach keeps ice positioning deliberate rather than oscillatory.
		var speed_limit: float = minf(30.0, absf(error) * 5.0 + 2.0)
		var direction: int = signi(roundi(error * 100))
		if body.velocity.x * direction > speed_limit:
			direction = 0
		await _tick(direction)
	print("WALK FAILED target ", x, " at ", body.position, " speed ", body.velocity, " surface ", body.surface_body_name)
	return false

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
	check(tower.zone_index == 3, "Climb crosses all four zones")
	check(body.maximum_height > 2500, "Continuous world height recorded")
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
	check(tower.zone_index < 3, "Fall returns to earlier zone")
	await _ticks(6)
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


func _tick(direction: int = 0, pressed: bool = false, held: bool = false, released: bool = false) -> void:
	await super._tick(direction, pressed, held, released)
	elapsed_ticks += 1
