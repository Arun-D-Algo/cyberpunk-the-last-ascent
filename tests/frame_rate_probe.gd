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
	world.free()
	world = null
	if failures.is_empty():
		print("PASS: render-cadence probe")
		quit(0)
	else:
		quit(1)
