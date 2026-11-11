extends "res://tests/physics_test.gd"

const RAMP = preload("res://resources/surfaces/controlled_ramp.tres")

func _run() -> void:
	var baseline := OS.get_cmdline_user_args().has("--baseline")
	await _measure(12.0, 36.0, false, baseline)
	await _measure(18.435, 24.0, false, baseline)
	await _measure(35.0, 180.0, true, baseline)
	await _measure(30.0, 720.0, true, baseline)
	if not baseline:
		await _measure(18.435, 24.0, true, false, -1)
	print("Slope checks: %d, failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _measure(angle: float, length: float, separate: bool, baseline: bool, direction: int = 1) -> void:
	await _new_fixture()
	world.get_child(0).free()
	var rise := tan(deg_to_rad(angle)) * length
	var points := PackedVector2Array([Vector2.ZERO, Vector2(length, rise)])
	if not separate:
		points.append(Vector2(length + 180, rise))
		points.append(Vector2(length + 180, rise + 16))
	else:
		points.append(Vector2(length, rise + 16))
	points.append(Vector2(0, rise + 16))
	for index in points.size():
		points[index].x *= direction
	LabSections.polygon(world, "Ramp", Vector2.ZERO, points, RAMP)
	if separate:
		var runout_x := length if direction == 1 else -length - 180.0
		_solid(Rect2(runout_x, rise, 180, 16))
	body.reset_movement(Vector2(6 * direction, -4))
	for i in 30:
		await _tick()
		if body.is_on_floor():
			break
	check(body.is_on_floor(), "Ramp acquires contact")
	body.velocity = Vector2.ZERO
	var start := body.position
	var first := -1
	var finish := -1
	var ungrounded := 0
	var min_angle := 90.0
	var max_angle := 0.0
	var peak := 0.0
	var samples: Array[float] = []
	var previous := 0.0
	var speed_drops := 0
	var first_displacement := 0.0
	var mid_normal_error := 0.0
	for i in 720:
		await _tick()
		var speed := body.tangent_speed() * direction
		if i == 0:
			first_displacement = (body.position.x - start.x) * direction
		if body.is_sliding() and first < 0:
			first = i + 1
		if i in [0, 5, 11, 29, 59]:
			samples.append(snappedf(speed, 0.001))
		if not body.is_on_floor():
			ungrounded += 1
		if body.is_on_floor() and body.slope_degrees() < 1.0:
			finish = i + 1
			break
		min_angle = minf(min_angle, body.slope_degrees())
		max_angle = maxf(max_angle, body.slope_degrees())
		peak = maxf(peak, speed)
		if body.position.x * direction < length - 8.0:
			mid_normal_error = maxf(mid_normal_error, absf(body.slope_degrees() - angle))
		if body.position.x * direction < length - 8.0 and speed + 0.1 < previous:
			speed_drops += 1
		previous = speed
	print("SLOPE %.3f len %.0f: onset=%d finish=%d samples=%s peak=%.3f airborne=%d normals=%.3f..%.3f drops=%d dx=%.3f mid_error=%.3f" % [angle, length, first, finish, samples, peak, ungrounded, min_angle, max_angle, speed_drops, body.position.x - start.x, mid_normal_error])
	if not baseline:
		check(first == 1, "Sliding starts on the first supported tick")
		check(first_displacement > 0.001 and first_displacement < 1.0, "First downhill move is fractional")
		check(samples[2] > samples[0] * 3.0, "Speed builds from rest")
		check(finish > 0, "Traversal reaches flat")
		check(ungrounded == 0, "No hops at ramp seam")
		check(mid_normal_error < 1.0, "Stable ramp face normal away from the seam")
		check(speed_drops == 0, "No speed drops on constant incline")
		check(peak <= RAMP.maximum_slide_speed + 0.01, "Slide cap respected")
		await _ticks(90)
		check(not body.is_sliding(), "Sliding exits on flat after braking")
