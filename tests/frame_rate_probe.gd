extends "res://tests/physics_test.gd"
## Run at --fixed-fps 30 / 60 / 120 while project physics remains 60 Hz.


func _run() -> void:
	check(Engine.physics_ticks_per_second == 60, "Physics tick remains 60Hz")
	await _new_fixture()
	var jump: Dictionary = await _jump(0.75, 1)
	near(jump["peak_height"], 69.015, 0.05, "Render cadence preserves maximum height")
	near(jump["displacement"], 132.007, 0.05, "Render cadence preserves range")
	near(jump["airborne_seconds"], 0.8, 0.0001, "Render cadence preserves flight time")
	print("CADENCE height=%.3f dx=%.3f air=%.3f" % [jump["peak_height"], jump["displacement"], jump["airborne_seconds"]])
	await _new_fixture()
	world.get_child(0).set_meta("surface_physics", preload("res://resources/surfaces/ice.tres"))
	await _ticks(2)
	body.velocity.x = 65.0
	var start_x: float = body.position.x
	await _ticks(30)
	near(body.position.x - start_x, 14.12666, 0.01, "Cadence preserves ice stopping")
	await _new_fixture()
	_solid(Rect2(38, -160, 8, 200))
	await _charge(0.75, 1)
	await _tick(1, false, false, true)
	for tick: int in 30:
		await _tick()
		if body.rebound_count > 0:
			break
	near(body.velocity.x, -99.0, 0.01, "Cadence preserves universal restitution")
	check(body.rebound_count == 1, "Cadence preserves single impulse")
	world.free()
	world = null
	if failures.is_empty():
		print("PASS: render-cadence probe")
		quit(0)
	else:
		quit(1)
