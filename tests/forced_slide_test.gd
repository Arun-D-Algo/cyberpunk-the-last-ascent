extends "res://tests/physics_test.gd"

func _run() -> void:
	await _traverse(20, 0)
	await _traverse(21, -1)
	await _traverse(22, 1)
	await _traverse(23, -1)
	await _traverse(24, 0)
	await _open_mirror()
	await _obstruction()
	await _reject_non_floor_contact()
	await _brief_gap()
	print("Forced slide checks: %d, failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _load_lab(section: int) -> PhysicsLab:
	if world != null:
		world.free()
	var lab: PhysicsLab = load("res://scenes/levels/physics_lab.tscn").instantiate()
	world = lab
	root.add_child(lab)
	body = lab.player
	body.accepts_live_input = false
	lab.select_section(section)
	await process_frame
	return lab

func _traverse(section: int, direction: int) -> void:
	var lab := await _load_lab(section)
	if section == 21:
		for tick in 60:
			await _tick(1)
			if body.state == PlayerController.State.FORCED_SLIDING:
				break
	if section == 24:
		await _ticks(9)
		await _charge(0.38, 1)
		await _tick(1, false, false, true)
	for tick in 100:
		if body.state == PlayerController.State.FORCED_SLIDING:
			break
		await _tick(0, false, section == 22)
	check(body.state == PlayerController.State.FORCED_SLIDING, "Lab section enters from its intended approach")
	if body.state != PlayerController.State.FORCED_SLIDING:
		return
	var slide: ForcedSlide = lab.get_node("Geometry/ForcedSlide")
	var launches := [0]
	body.jump_started.connect(func(_p: Vector2, _s: float, _n: float, _v: Vector2) -> void: launches[0] += 1)
	var from := body.position
	paused = true
	await _tick(-1, true, true)
	check(body.position == from and body.state == PlayerController.State.FORCED_SLIDING, "Pause preserves slide")
	paused = false
	var elapsed := 0
	var saw_second := false
	var continuous := true
	var locked := true
	while body.state == PlayerController.State.FORCED_SLIDING and elapsed < 200:
		var previous := body.position
		var press := section == 22 and elapsed % 4 == 0
		await _tick(direction, press, section == 22 and elapsed % 4 < 2, section == 22 and elapsed % 4 == 2)
		continuous = continuous and body.position.x > previous.x and body.position.distance_to(previous) < 4.0
		locked = locked and body.charge_duration == 0.0
		saw_second = saw_second or (body.is_on_floor() and body.slope_degrees() > 25.0 and body.slope_degrees() < 35.0)
		elapsed += 1
	check(continuous, "Continuous positive displacement at configured speed")
	check(locked and launches[0] == 0, "Space accumulates no charge and emits no jump")
	check(slide.passed_exit(body.position.x) and elapsed < 200, "Restores control at the designated exit")
	check(body.velocity == slide.exit_velocity, "Applies exit velocity once")
	if section == 22:
		await _tick(0, true, true)
		check(body.state != PlayerController.State.CHARGING, "Held Space does not carry through the exit")
		await _tick(0, false, false, true)
		await _tick(0, true, true)
		check(body.state == PlayerController.State.CHARGING, "Fresh Space press charges on the runout")
	if section == 23:
		check(saw_second, "Second face shares the committed route")
	if section == 24:
		await _ticks(30)
		check(body.is_on_floor() and body.surface_body_name == &"Recovery", "Open end lands on the recovery floor")
	lab.reset_lab()
	check(body.state != PlayerController.State.FORCED_SLIDING and body.velocity == Vector2.ZERO, "Reset clears commitment")
	print("Forced slide section %d exit after %d fixed ticks" % [section, elapsed])

func _open_mirror() -> void:
	await _new_fixture()
	var slide := ForcedSlide.new()
	slide.direction = -1
	slide.position = Vector2(80, -95)
	slide.points = PackedVector2Array([Vector2.ZERO, Vector2(-70, 40)])
	world.add_child(slide)
	body.reset_movement(Vector2(50, -112))
	for tick in 25:
		await _tick(1, false, true)
		if body.state == PlayerController.State.FORCED_SLIDING:
			break
	check(body.state == PlayerController.State.FORCED_SLIDING and body.facing_direction == -1, "Fall onto left-facing route with Space held")
	for tick in 100:
		await _tick(1, false, true)
		if body.state != PlayerController.State.FORCED_SLIDING:
			break
	check(slide.passed_exit(body.position.x) and body.velocity.x < 0.0, "Mirrored slide exits left with uphill input")
	await _ticks(40)
	check(body.is_on_floor(), "Mirrored open slide recovers")

func _obstruction() -> void:
	await _new_fixture()
	var slide := ForcedSlide.new()
	slide.position = Vector2(0, -100)
	world.add_child(slide)
	_solid(Rect2(68, -120, 10, 120))
	body.reset_movement(Vector2(24, -94))
	var entered := false
	for tick in 140:
		await _tick()
		entered = entered or body.state == PlayerController.State.FORCED_SLIDING
		if entered and body.state != PlayerController.State.FORCED_SLIDING:
			break
	check(entered and body.state != PlayerController.State.FORCED_SLIDING, "Blocked route warns and restores controls")
	check(body.position.x < 68.0, "Wall is never penetrated")
	await _ticks(8, -1)
	check(body.velocity.x < 0.0, "Player can leave obstructed slide")

func _reject_non_floor_contact() -> void:
	await _new_fixture()
	var slide := ForcedSlide.new()
	slide.position = Vector2(12, -112)
	world.add_child(slide)
	body.reset_movement(Vector2(0, -87))
	body.velocity.x = 120.0
	var hit_side := false
	for tick in 12:
		await _tick(1)
		hit_side = hit_side or body.is_on_wall()
	check(hit_side and body.state != PlayerController.State.FORCED_SLIDING, "Side-only contact leaves normal wall handling")
	body.reset_movement(Vector2(45, 0))
	await _ticks(8)
	await _charge(0.8)
	await _tick(0, false, false, true)
	var hit_ceiling := false
	for tick in 25:
		await _tick()
		hit_ceiling = hit_ceiling or body.is_on_ceiling()
	check(hit_ceiling and body.state != PlayerController.State.FORCED_SLIDING, "Underside contact never commits")

func _brief_gap() -> void:
	var lab := await _load_lab(23)
	var slide: ForcedSlide = lab.get_node("Geometry/ForcedSlide")
	# Introduce a drop larger than the 1 px snap at the connected seam.
	var second: PhysicsSurface = slide.get_node("SlideFace2")
	second.position.y += 3.0
	await _ticks(6)
	check(body.state == PlayerController.State.FORCED_SLIDING, "Gap fixture enters")
	var lost_contact := false
	var regained_contact := false
	var escaped_early := false
	for tick in 120:
		await _tick(-1, true, true)
		lost_contact = lost_contact or not body.is_on_floor()
		regained_contact = regained_contact or (lost_contact and body.is_on_floor() and not slide.passed_exit(body.position.x))
		if body.state != PlayerController.State.FORCED_SLIDING:
			escaped_early = not slide.passed_exit(body.position.x)
			break
	check(lost_contact and regained_contact, "A short support loss reacquires the lower face")
	check(not escaped_early and slide.passed_exit(body.position.x), "Airborne seam does not release commitment")
