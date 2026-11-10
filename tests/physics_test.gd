extends SceneTree
## Dependency-free real-body tests. --fixed-fps 60 accelerates ticks, not the model.

const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const DEFAULT_CONFIG: PlayerPhysicsConfig = preload("res://resources/physics/default_player_physics.tres")
const DT: float = 1.0 / 60.0
var failures: Array[String] = []
var checks: int = 0
var world: Node2D
var body: PlayerController
var recorder: JumpRecorder
var visited_states: Array[int] = []
var measurement_rows: Array[Dictionary] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)


func near(actual: float, expected: float, tolerance: float, message: String) -> void:
	check(absf(actual - expected) <= tolerance, "%s (got %.5f expected %.5f)" % [message, actual, expected])


func _run() -> void:
	_test_calculations()
	await _test_controller()
	await _test_collisions()
	await _measure_envelope()
	await _test_lab()
	if failures.is_empty():
		print("PASS: %d physics/integration checks" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d physics/integration checks" % [failures.size(), checks])
		quit(1)


func _test_calculations() -> void:
	check(DEFAULT_CONFIG.validation_errors().is_empty(), "Default config valid")
	for fraction: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
		var seconds: float = lerpf(DEFAULT_CONFIG.minimum_charge_time, DEFAULT_CONFIG.maximum_charge_time, fraction)
		near(JumpPhysics.normalized_charge(seconds, DEFAULT_CONFIG), fraction, 0.00001, "Charge normalization")
		near(JumpPhysics.strength(seconds, DEFAULT_CONFIG), fraction, 0.00001, "Default linear curve")
		var launch: Vector2 = JumpPhysics.launch_velocity(seconds, 1, DEFAULT_CONFIG)
		near(launch.y, -lerpf(DEFAULT_CONFIG.minimum_jump_impulse, DEFAULT_CONFIG.maximum_jump_impulse, fraction), 0.00001, "Vertical impulse")
		near(launch.x, lerpf(DEFAULT_CONFIG.minimum_horizontal_impulse, DEFAULT_CONFIG.maximum_horizontal_impulse, fraction), 0.00001, "Horizontal impulse")
	near(JumpPhysics.normalized_charge(-5.0, DEFAULT_CONFIG), 0.0, 0.0, "Negative charge clamped")
	near(JumpPhysics.normalized_charge(10.0, DEFAULT_CONFIG), 1.0, 0.0, "Overcharge clamped")
	near(JumpPhysics.launch_velocity(0.0, 0, DEFAULT_CONFIG).y, -DEFAULT_CONFIG.minimum_jump_impulse, 0.0, "Tap minimum impulse")
	check(JumpPhysics.direction(false, false) == 0, "No direction neutral")
	check(JumpPhysics.direction(true, true) == 0, "Both directions neutral")
	check(JumpPhysics.direction(true, false) == -1, "Left direction")
	check(JumpPhysics.direction(false, true) == 1, "Right direction")
	check(JumpPhysics.launch_velocity(1.0, -1, DEFAULT_CONFIG).x < 0.0, "Left launch")
	check(JumpPhysics.launch_velocity(1.0, 0, DEFAULT_CONFIG).x == 0.0, "Neutral launch")
	var curve_config: PlayerPhysicsConfig = DEFAULT_CONFIG.duplicate(true)
	curve_config.charge_curve = Curve.new()
	curve_config.charge_curve.add_point(Vector2(0, 0), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	curve_config.charge_curve.add_point(Vector2(0.5, 0.25), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	curve_config.charge_curve.add_point(Vector2(1, 1), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR)
	check(curve_config.validation_errors().is_empty(), "Monotone nonlinear config valid")
	near(JumpPhysics.strength(lerpf(curve_config.minimum_charge_time, curve_config.maximum_charge_time, 0.5), curve_config), 0.25, 0.00001, "Configured nonlinear response used")
	for property: String in ["gravity", "ground_speed", "ground_acceleration", "maximum_fall_speed"]:
		var invalid: PlayerPhysicsConfig = DEFAULT_CONFIG.duplicate(true)
		invalid.set(property, -1.0)
		check(not invalid.validation_errors().is_empty(), "Reject negative " + property)
	var invalid: PlayerPhysicsConfig = DEFAULT_CONFIG.duplicate(true)
	invalid.maximum_charge_time = invalid.minimum_charge_time
	check(not invalid.validation_errors().is_empty(), "Reject zero charge denominator")
	invalid = DEFAULT_CONFIG.duplicate(true)
	invalid.minimum_jump_impulse = invalid.maximum_jump_impulse + 1.0
	check(not invalid.validation_errors().is_empty(), "Reject reversed impulse interval")
	invalid = DEFAULT_CONFIG.duplicate(true)
	invalid.air_control_factor = 2.0
	check(not invalid.validation_errors().is_empty(), "Reject excessive air steering")
	invalid = DEFAULT_CONFIG.duplicate(true)
	invalid.gravity = NAN
	check(not invalid.validation_errors().is_empty(), "Reject nonfinite config")
	curve_config.charge_curve.set_point_value(1, -0.2)
	check(not curve_config.validation_errors().is_empty(), "Reject invalid curve")
	check(InputMap.action_get_events("debug_toggle_overlay")[0].physical_keycode == KEY_F3, "Debug toggle F3")
	check(InputMap.action_get_events("debug_reset_lab")[0].physical_keycode == KEY_F6, "Reset F6")


func _new_fixture(at: Vector2 = Vector2.ZERO, floor_rect: Rect2 = Rect2(-1000, 0, 2000, 16)) -> void:
	if world != null:
		world.free()
	world = Node2D.new()
	root.add_child(world)
	_solid(floor_rect)
	body = PLAYER.instantiate() as PlayerController
	body.accepts_live_input = false
	body.physics_config = DEFAULT_CONFIG
	body.position = at
	world.add_child(body)
	recorder = body.get_node("JumpRecorder") as JumpRecorder
	visited_states.clear()
	body.state_changed.connect(func(_previous: int, next: int) -> void: visited_states.append(next))
	await _ticks(8)
	check(body.state == PlayerController.State.GROUNDED, "Fixture settles grounded")


func _solid(rect: Rect2) -> StaticBody2D:
	var solid: StaticBody2D = StaticBody2D.new()
	solid.collision_layer = 1
	solid.collision_mask = 2
	solid.position = rect.position
	var collision: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.position = rect.size / 2.0
	solid.add_child(collision)
	world.add_child(solid)
	return solid


func _tick(direction: int = 0, pressed: bool = false, held: bool = false, released: bool = false) -> void:
	await physics_frame
	body.step_movement(DT, direction, pressed, held, released)


func _ticks(count: int, direction: int = 0) -> void:
	for tick: int in count:
		await _tick(direction)


func _charge(seconds: float, direction: int = 0) -> void:
	var ticks: int = maxi(1, roundi(seconds / DT))
	for tick: int in ticks:
		await _tick(direction, tick == 0, true)


func _land(direction: int = 0) -> bool:
	for tick: int in 240:
		if body.state == PlayerController.State.GROUNDED:
			return true
		await _tick(direction)
	return false


func _jump(seconds: float, direction: int = 1) -> Dictionary:
	await _charge(seconds, direction)
	await _tick(direction, false, false, true)
	check(await _land(), "Jump returns grounded")
	return recorder.last_jump.duplicate()


func _test_controller() -> void:
	await _new_fixture()
	await _ticks(10, 1)
	near(body.velocity.x, DEFAULT_CONFIG.ground_speed, 0.001, "Ground acceleration reaches cap")
	var stop_x: float = body.position.x
	await _ticks(8)
	near(body.velocity.x, 0.0, 0.001, "Ground deceleration stops")
	check(body.position.x - stop_x < 3.0, "Ground stopping distance below 3px")
	var before: Vector2 = body.position
	await _charge(DEFAULT_CONFIG.maximum_charge_time + 0.5, -1)
	check(body.state == PlayerController.State.CHARGING, "Maximum hold never auto-jumps")
	near(body.charge_duration, DEFAULT_CONFIG.maximum_charge_time, 0.00001, "Charge duration capped")
	near(body.position.x, before.x, 0.001, "Charging stationary")
	check(body.selected_direction == -1, "Charge left direction visible")
	await _tick(1, false, true)
	check(body.selected_direction == 1, "Direction may change while charging")
	await _tick(1, false, false, true)
	check(body.state == PlayerController.State.RISING, "Release launches rising")
	near(body.velocity.x, DEFAULT_CONFIG.maximum_horizontal_impulse, 0.001, "Horizontal launch cap")
	near(body.charge_duration, 0.0, 0.0, "Charge clears on release")
	var launched_vx: float = body.velocity.x
	await _tick(-1, true, true)
	check(body.state == PlayerController.State.RISING, "Airborne press cannot charge")
	near(body.velocity.x, launched_vx, 0.001, "No air steering by default")
	await _tick(-1, false, false, true)
	check(body.velocity.y > -DEFAULT_CONFIG.maximum_jump_impulse, "Air release cannot double-jump")
	check(await _land(), "Committed jump lands")
	for required: int in [PlayerController.State.CHARGING, PlayerController.State.RISING, PlayerController.State.FALLING, PlayerController.State.LANDING, PlayerController.State.GROUNDED]:
		check(visited_states.has(required), "Required state observed " + str(required))
	check(recorder.completed_count == 1, "One release produces one measurement")
	var jump: Dictionary = await _jump(0.0, 0)
	near(jump["initial_velocity"].y, -DEFAULT_CONFIG.minimum_jump_impulse, 0.001, "Actual tap uses minimum jump")
	near(jump["displacement"], 0.0, 0.001, "Actual neutral jump vertical")
	await _charge(0.3)
	body.reset_movement(Vector2.ZERO)
	check(body.velocity == Vector2.ZERO and body.charge_duration == 0.0, "Reset charging clears motion/charge")
	check(recorder.last_jump.is_empty() and recorder.completed_count == 0, "Reset clears measurements")
	await _ticks(8)
	check(body.state == PlayerController.State.GROUNDED, "Reset reacquires floor")
	await _charge(0.5)
	await _tick(0, false, false, true)
	body.reset_movement(Vector2(5, 0))
	await _ticks(8)
	near(body.position.x, 5.0, 0.001, "Airborne reset position")
	await _charge(0.2)
	before = body.position
	paused = true
	body.step_movement(DT, 1, false, true, false)
	check(body.position == before, "Paused movement entry does nothing")
	near(body.charge_duration, 0.2, DT, "Pause freezes charge")
	body.cancel_input_until_release()
	paused = false
	await _tick(0, false, false, true)
	check(body.state == PlayerController.State.GROUNDED, "Pause cancellation prevents release jump")
	# Held airborne input through landing must not initiate another charge.
	await _charge(0.1)
	await _tick(0, false, false, true)
	for tick: int in 70:
		await _tick(0, tick == 0, true)
	check(body.state == PlayerController.State.GROUNDED, "Held key through landing does not recharge")
	near(body.charge_duration, 0.0, 0.0, "Held key through landing has no charge")
	# Repeated jumps remain stable across many ticks.
	var rises: Array[float] = []
	for iteration: int in 12:
		await _tick()
		jump = await _jump(0.4, 0)
		rises.append(jump.get("peak_height", -1.0))
	for height: float in rises:
		near(height, rises[0], 0.05, "Repeated arc stable within 0.05px")


func _test_collisions() -> void:
	await _new_fixture()
	_solid(Rect2(-40, -62, 80, 8))
	await _ticks(2)
	var jump: Dictionary = await _jump(0.75, 0)
	check(jump.get("hit_ceiling", false), "Ceiling collision recorded")
	check(jump.get("peak_height", 100.0) <= 30.1, "Ceiling blocks upward travel")
	await _new_fixture()
	_solid(Rect2(38, -150, 8, 200))
	await _ticks(2)
	jump = await _jump(0.75, 1)
	check(jump.get("hit_wall", false), "Rising wall contact recorded")
	check(jump.get("displacement", 100.0) < 33.1, "Wall blocks horizontal travel")
	await _new_fixture()
	_solid(Rect2(110, -120, 8, 150))
	await _ticks(2)
	jump = await _jump(0.75, 1)
	check(jump.get("hit_wall", false), "Falling wall contact recorded")
	await _new_fixture()
	_solid(Rect2(80, -44, 24, 8))
	await _ticks(2)
	jump = await _jump(0.75, 1)
	check(jump.get("landing", Vector2.ZERO).y < -43.9, "Land on 24px narrow platform")
	check(recorder.completed_count == 1, "Narrow landing emits once")
	await _new_fixture(Vector2(9, 0), Rect2(-20, 0, 30, 8))
	await _ticks(10, 1)
	check(body.state == PlayerController.State.FALLING, "Walking off ledge falls")
	await _new_fixture(Vector2(8, 0), Rect2(-20, 0, 30, 8))
	await _charge(0.2, 1)
	check(body.state == PlayerController.State.CHARGING and body.is_on_floor(), "Edge charge retains stable support")
	# Remove support to exercise the same loss-of-floor transition as later movers.
	world.get_child(0).queue_free()
	await _ticks(3)
	check(body.state == PlayerController.State.FALLING and body.charge_duration == 0.0, "Losing support cancels charge")
	await _new_fixture()
	body.reset_movement(Vector2(0, -500))
	check(await _land(), "Long fall lands without tunneling 16px floor")
	near(body.position.y, 0.0, 0.1, "Long fall floor position")
	# Teleport to near the edge then drop onto a thin platform at terminal speed.
	await _new_fixture()
	_solid(Rect2(20, -50, 24, 8))
	body.reset_movement(Vector2(43, -400))
	check(await _land(), "Edge landing from long fall")
	near(body.position.y, -50.0, 0.1, "Platform-edge landing height")
	world.free()
	world = null


func _measure_envelope() -> void:
	# Baseline and revised maximum impulse measured through the actual controller.
	for maximum: float in [330.0, 360.0]:
		await _new_fixture()
		var tuning: PlayerPhysicsConfig = DEFAULT_CONFIG.duplicate(true)
		tuning.maximum_jump_impulse = maximum
		body.physics_config = tuning
		var measured: Dictionary = await _jump(tuning.maximum_charge_time, 1)
		print("TUNING max_vy=%.0f height=%.3f dx=%.3f air=%.3f" % [maximum, measured.get("peak_height", 0), measured.get("displacement", 0), measured.get("airborne_seconds", 0)])
	for fraction: float in [0.0, 0.25, 0.5, 0.75, 1.0]:
		await _new_fixture()
		var seconds: float = lerpf(DEFAULT_CONFIG.minimum_charge_time, DEFAULT_CONFIG.maximum_charge_time, fraction) if fraction > 0.0 else 0.0
		var measured: Dictionary = await _jump(seconds, 1)
		measured["requested_fraction"] = fraction
		measurement_rows.append(measured)
		print("MEASURE %.0f%% charge=%.4f strength=%.4f height=%.3f dx=%.3f air=%.3f" % [fraction * 100, measured.get("charge_seconds", 0), measured.get("strength", 0), measured.get("peak_height", 0), measured.get("displacement", 0), measured.get("airborne_seconds", 0)])
	await _new_fixture()
	var right: Dictionary = await _jump(0.75, 1)
	body.reset_movement(Vector2.ZERO)
	await _ticks(8)
	var left: Dictionary = await _jump(0.75, -1)
	near(left.get("peak_height", 0), right.get("peak_height", 0), 0.05, "Mirrored height")
	near(left.get("displacement", 0), -right.get("displacement", 0), 0.05, "Mirrored displacement")
	var report: FileAccess = FileAccess.open("res://.godot/jump_measurements.json", FileAccess.WRITE)
	check(report != null, "Measurement report writable")
	if report != null:
		report.store_string(JSON.stringify(measurement_rows, "\t"))
		report.close()
	world.free()
	world = null


func _test_lab() -> void:
	var boot: Control = load("res://scenes/main/boot.tscn").instantiate() as Control
	root.add_child(boot)
	current_scene = boot
	boot.get_node("Content/EnterLab").emit_signal("pressed")
	await process_frame
	await process_frame
	check(current_scene is PhysicsLab, "Boot button navigates to real lab")
	if not current_scene is PhysicsLab:
		return
	var lab: PhysicsLab = current_scene as PhysicsLab
	body = lab.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder") as JumpRecorder
	await _ticks(8)
	check(body.is_on_floor(), "Lab spawn on floor")
	check(lab.hud.player == body, "HUD references actual player")
	lab.hud.toggle_debug()
	check(lab.hud.debug_enabled and lab.hud.get_node("DebugPanel").visible, "Debug overlay toggles on")
	lab.hud.toggle_debug()
	check(not lab.hud.debug_enabled, "Debug overlay toggles off")
	await _charge(0.2)
	await process_frame
	check(lab.hud.charge_bar.value > 0.0, "HUD shows charge")
	var position_before: Vector2 = body.position
	lab.toggle_pause()
	check(paused and body.charge_duration == 0.0, "Lab pause cancels charge")
	await process_frame
	await process_frame
	check(body.position == position_before, "Paused lab stays still")
	lab.toggle_pause()
	await _tick(0, false, false, true)
	check(body.state == PlayerController.State.GROUNDED, "Resume release does not launch")
	lab.reset_lab()
	check(body.velocity == Vector2.ZERO and body.position == PhysicsLab.SPAWN, "Lab reset clears velocity and restores spawn")
	check(recorder.last_jump.is_empty(), "Lab reset clears debug measurements")
	await _ticks(8)
	var camera_before: float = lab.camera.position.y
	Input.action_press("look_up")
	await _ticks(12)
	check(lab.camera.position.y < camera_before, "Camera W look moves up")
	var looked_up: float = lab.camera.position.y
	Input.action_release("look_up")
	Input.action_press("look_down")
	await _ticks(24)
	check(lab.camera.position.y > looked_up, "Camera S look moves down within floor limit")
	Input.action_release("look_down")
	lab.camera.reset_tracking()
	check(lab.camera.position == lab.camera.position.round(), "Camera displayed position is pixel rounded")
	lab.reset_lab()
	await _ticks(8)
	await _test_live_input(lab)
	lab.reset_lab()
	await _ticks(8)
	# Execute a complete route with measured jumps on the actual authored solids.
	# Drive ground positioning and held/released intent; never teleport between route landings.
	var route_ok: bool = await _climb_route(lab)
	check(route_ok, "Intended route reaches summit through real collisions")
	check(lab.camera.position.y < -400.0, "Camera follows route vertically")
	var screen_feet: float = body.position.y - lab.camera.position.y + 90.0
	check(screen_feet >= 49.0 and screen_feet <= 175.0, "Camera keeps silhouette clear of HUD and screen edge")
	if route_ok:
		var summit_y: float = body.position.y
		for tick: int in 100:
			await _tick(-1)
			if not body.is_on_floor():
				break
		check(await _land(), "Fall from summit finds recovery without reset")
		check(body.position.y > summit_y + 20.0, "Fall loses altitude and allows another attempt")
	lab.reset_lab()
	await _ticks(8)
	near(body.position.y, PhysicsLab.SPAWN.y, 0.1, "Route reset recovers safely")
	lab.free()
	current_scene = null


func _send_action(action: String, down: bool) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = down
	Input.parse_input_event(event)


func _live_ticks(count: int) -> void:
	for tick: int in count:
		await physics_frame
	await process_frame


func _test_live_input(lab: PhysicsLab) -> void:
	# Dispatch through Godot's input pipeline and the live _physics_process adapter.
	body.accepts_live_input = true
	var before: Vector2 = body.position
	_send_action("move_right", true)
	await _live_ticks(8)
	_send_action("move_right", false)
	await _live_ticks(8)
	check(body.position.x > before.x + 2.0, "Live semantic input walks right")
	_send_action("move_left", true)
	await _live_ticks(8)
	_send_action("move_left", false)
	await _live_ticks(8)
	check(body.position.x < before.x + 2.0, "Live semantic input walks left")
	_send_action("jump_charge", true)
	await _live_ticks(55)
	check(body.state == PlayerController.State.CHARGING and body.charge_fraction() == 1.0, "Live hold caps without launch")
	_send_action("jump_charge", false)
	await _live_ticks(2)
	check(body.state == PlayerController.State.RISING, "Live release launches")
	_send_action("jump_charge", true)
	await _live_ticks(2)
	_send_action("jump_charge", false)
	await _live_ticks(75)
	check(recorder.completed_count == 1, "Live midair press/release cannot double-jump")
	_send_action("debug_toggle_overlay", true)
	_send_action("debug_toggle_overlay", false)
	await process_frame
	check(lab.hud.debug_enabled, "F3 semantic input reaches overlay")
	_send_action("debug_toggle_overlay", true)
	_send_action("debug_toggle_overlay", false)
	_send_action("jump_charge", true)
	await _live_ticks(8)
	_send_action("pause_game", true)
	_send_action("pause_game", false)
	await process_frame
	check(paused and body.charge_duration == 0.0, "Esc semantic input pauses and cancels charge")
	_send_action("jump_charge", false)
	_send_action("pause_game", true)
	_send_action("pause_game", false)
	await _live_ticks(3)
	check(not paused and body.state == PlayerController.State.GROUNDED, "Esc resumes without stale launch")
	_send_action("jump_charge", true)
	await _live_ticks(8)
	_send_action("debug_reset_lab", true)
	_send_action("debug_reset_lab", false)
	await _live_ticks(8)
	check(body.position.distance_to(PhysicsLab.SPAWN) < 0.1 and body.charge_duration == 0.0, "F6 input resets charging player")
	_send_action("jump_charge", false)
	await _live_ticks(2)
	check(body.state == PlayerController.State.GROUNDED, "F6 ignores stale charge release")
	body.accepts_live_input = false


func _climb_route(lab: PhysicsLab) -> bool:
	# A deterministic route recipe is filled after measurements, not a ballistic-only assertion.
	var launches: Array = [
		[45.0, 0.34, 1], [103.0, 0.58, 1], [170.0, 0.75, -1],
		[105.0, 0.75, 1], [180.0, 0.75, -1], [104.0, 0.75, 1],
		[188.0, 0.75, -1], [100.0, 0.75, 1], [185.0, 0.75, -1],
		[108.0, 0.75, 1], [195.0, 0.75, -1], [115.0, 0.75, 1],
	]
	for index: int in launches.size():
		var recipe: Array = launches[index]
		var desired_x: float = recipe[0]
		for tick: int in 120:
			if absf(body.position.x - desired_x) <= 0.8:
				break
			await _tick(1 if body.position.x < desired_x else -1)
		await _charge(recipe[1], recipe[2])
		await _tick(recipe[2], false, false, true)
		if not await _land():
			print("ROUTE FAILED at %d: no landing" % index)
			return false
		print("ROUTE %d landed %s" % [index + 1, body.position])
		if absf(body.position.y - float(PhysicsLab.PLATFORMS[index + 1][2])) > 0.2:
			print("ROUTE FAILED expected y=%s" % PhysicsLab.PLATFORMS[index + 1][2])
			return false
	return body.position.y < -443.0
