extends "res://tests/physics_test.gd"
## Real solver scenarios using the same fixed-tick controller entry point as M01.

const ICE: SurfacePhysicsProfile = preload("res://resources/surfaces/ice.tres")
const RAMP: SurfacePhysicsProfile = preload("res://resources/surfaces/sliding_ramp.tres")
const NORMAL: SurfacePhysicsProfile = preload("res://resources/surfaces/normal.tres")
const REBOUND: SurfacePhysicsProfile = preload("res://resources/surfaces/rebound_wall.tres")
var comparison: Dictionary = {}


func _run() -> void:
	_test_profiles()
	await _normal_baseline()
	await _walls_and_ceilings()
	await _ice_and_transitions()
	await _slide_measurement()
	await _slopes_and_ramps()
	await _transition_chains()
	await _moving_platforms()
	await _lab_navigation()
	var report: FileAccess = FileAccess.open("res://.godot/surface_measurements.json", FileAccess.WRITE)
	check(report != null, "Surface comparison report writable")
	if report != null:
		report.store_string(JSON.stringify(comparison, "\t"))
		report.close()
	if failures.is_empty():
		print("PASS: %d surface/mechanics checks" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d surface/mechanics checks" % [failures.size(), checks])
		quit(1)


func _test_profiles() -> void:
	for profile: SurfacePhysicsProfile in [NORMAL, ICE, RAMP, REBOUND]:
		check(profile.validation_errors().is_empty(), "Valid profile " + String(profile.id))
	for property: String in ["friction", "maximum_slide_speed", "charge_speed_limit", "landing_momentum_retention"]:
		var invalid: SurfacePhysicsProfile = ICE.duplicate(true)
		invalid.set(property, -1.0)
		check(not invalid.validation_errors().is_empty(), "Reject invalid " + property)
	var response: CollisionResponseProfile = CollisionResponseProfile.new()
	response.wall_restitution = 1.1
	check(not response.validation_errors().is_empty(), "Reject energy-adding restitution")
	response.wall_restitution = NAN
	check(not response.validation_errors().is_empty(), "Reject nonfinite contact parameter")
	var legacy: PlayerPhysicsConfig = load("res://resources/physics/m01_baseline.tres")
	near(legacy.maximum_jump_impulse, DEFAULT_CONFIG.maximum_jump_impulse, 0.0, "Baseline snapshot available")


func _normal_baseline() -> void:
	var expected: Array = [[0.0, 11.267, 15.006], [0.233333, 21.196, 33.822], [0.4, 33.610, 57.279], [0.583333, 50.607, 92.950], [0.75, 69.015, 132.007]]
	var rows: Array = []
	for row: Array in expected:
		await _new_fixture()
		var jump: Dictionary = await _jump(row[0], 1)
		near(jump["peak_height"], row[1], 0.05, "Preserved normal jump rise")
		near(jump["displacement"], row[2], 0.05, "Preserved normal jump displacement")
		check(jump.has("landing_velocity") and jump["surface_type"] == "normal", "Extended landing measurements")
		rows.append({"hold": jump["charge_seconds"], "height": jump["peak_height"], "dx": jump["displacement"], "air": jump["airborne_seconds"]})
	comparison["normal_jumps"] = rows
	for profile: SurfacePhysicsProfile in [NORMAL, ICE]:
		await _new_fixture()
		world.get_child(0).set_meta("surface_physics", profile)
		await _ticks(2)
		body.velocity = Vector2(65, 0)
		var start_x: float = body.position.x
		var stop_ticks: int = 0
		for tick: int in 240:
			await _tick()
			stop_ticks += 1
			if is_zero_approx(body.velocity.x):
				break
		var distance: float = body.position.x - start_x
		comparison[String(profile.id) + "_stop"] = {"distance": distance, "seconds": stop_ticks * DT}
		print("STOP %s dx=%.3f seconds=%.3f" % [profile.id, distance, stop_ticks * DT])
		check(is_zero_approx(body.velocity.x), "No residual drift on " + String(profile.id))
		check(distance < 3.0 if profile == NORMAL else 10.0 < distance and distance < 20.0, "Distinct measured friction " + String(profile.id))


func _walls_and_ceilings() -> void:
	for rebound: bool in [false, true]:
		await _new_fixture()
		var wall: StaticBody2D = _solid(Rect2(38, -160, 8, 200))
		if not rebound:
			body.collision_response = CollisionResponseProfile.new()
			body.collision_response.wall_mode = CollisionResponseProfile.WallMode.STOP
		if rebound:
			wall.set_meta("surface_physics", REBOUND)
		await _ticks(2)
		await _charge(0.75, 1)
		await _tick(1, false, false, true)
		var before_impact: Vector2 = Vector2.ZERO
		for tick: int in 60:
			before_impact = body.velocity + Vector2(0, DEFAULT_CONFIG.gravity * DT)
			await _tick()
			if body.is_on_wall():
				break
		check(body.is_on_wall(), "Actual rising wall contact")
		near(body.velocity.x, -41.25 if rebound else 0.0, 0.05, "Bounded selected wall response")
		check(body.velocity.length_squared() <= before_impact.length_squared() + 0.1, "Wall cannot increase kinetic energy")
		comparison["rebound" if rebound else "wall_stop"] = {"incoming_vx": 165.0, "outgoing_vx": body.velocity.x}
		check(await _land(), "Land after wall response")
		check(recorder.last_jump.get("wall_collision_count", 0) == 1, "One impact counted, not one per contact tick")
	# Wall+floor contact never rebounds the player off a supported ledge.
	await _new_fixture()
	var wall: StaticBody2D = _solid(Rect2(38, -100, 8, 116))
	wall.set_meta("surface_physics", REBOUND)
	await _ticks(70, 1)
	check(body.is_on_floor() and body.state == PlayerController.State.GROUNDED, "Stable floor/wall corner")
	near(body.velocity.x, 0.0, 0.01, "No grounded rebound")
	await _new_fixture()
	_solid(Rect2(-40, -34, 80, 8))
	var ceiling_response: CollisionResponseProfile = CollisionResponseProfile.new()
	ceiling_response.ceiling_downward_speed = 5.0
	body.collision_response = ceiling_response
	await _ticks(2)
	await _charge(0.75)
	await _tick(0, false, false, true)
	for tick: int in 10:
		if body.is_on_ceiling():
			break
		await _tick()
	check(body.is_on_ceiling() and body.state == PlayerController.State.FALLING, "Immediate ceiling interrupts rise")
	near(body.velocity.y, 5.0, 0.01, "Configured conservative ceiling response")
	for clearance: float in [26.0, 40.0, 78.0, 90.0]:
		for direction: int in [0, 1]:
			await _new_fixture()
			_solid(Rect2(-80, -clearance - 8, 240, 8))
			await _ticks(2)
			var jump: Dictionary = await _jump(0.75, direction)
			check(jump.get("hit_ceiling", false), "Low/diagonal/near-apex ceiling hit")
			check(jump.get("ceiling_collision_count", 0) == 1, "Ceiling impact counted once")
			check(jump.get("peak_height", 999) <= clearance - 24.0 + 0.1, "Head never passes ceiling")
	# Actual partial collider overlap versus a miss, no ledge grab/corner assistance.
	for center: float in [44.0, 45.2]:
		await _new_fixture()
		_solid(Rect2(32, -40, 8, 8))
		body.reset_movement(Vector2(center, -150))
		check(await _land(), "Narrow drop eventually recovers")
		near(body.position.y, -40.0 if center == 44.0 else 0.0, 0.1, "Partial overlap or true miss")


func _ice_and_transitions() -> void:
	await _new_fixture()
	world.get_child(0).set_meta("surface_physics", ICE)
	await _ticks(2)
	var jump: Dictionary = await _jump(0.75, 1)
	check(body.velocity.x > 100.0, "Ice retains landing momentum through recovery")
	near(jump["landing_velocity"].x, 165.0, 0.01, "Landing velocity measured before damping")
	check(jump["surface_type"] == "ice", "Recorder identifies landing surface")
	body.velocity = Vector2(65, 0)
	await _charge(0.2)
	check(body.state == PlayerController.State.GROUNDED and body.charge_duration == 0.0, "High-speed ice charge rejected")
	for tick: int in 160:
		await _tick(0, false, true)
	check(body.state == PlayerController.State.GROUNDED, "Rejected hold does not silently buffer a charge")
	await _tick()
	var start: Vector2 = body.position
	await _charge(0.2, 1)
	check(body.state == PlayerController.State.CHARGING, "Fresh low-speed ice press accepted")
	near(body.position.x, start.x, 0.05, "Accepted ice charging is stationary")
	check(recorder.sliding_distance > 0 and recorder.maximum_sliding_speed > 0, "Slide metrics collected")
	for profile: SurfacePhysicsProfile in [NORMAL, ICE]:
		await _new_fixture()
		world.get_child(0).set_meta("surface_physics", profile)
		await _ticks(2)
		body.velocity = Vector2(65, 0)
		var ticks_to_reverse: int = 0
		for tick: int in 80:
			await _tick(-1)
			ticks_to_reverse += 1
			if body.velocity.x < 0:
				break
		comparison[String(profile.id) + "_reverse_seconds"] = ticks_to_reverse * DT
		print("REVERSE %s seconds=%.3f" % [profile.id, ticks_to_reverse * DT])
		check(ticks_to_reverse <= 6 if profile == NORMAL else 4 <= ticks_to_reverse and ticks_to_reverse <= 8, "Deliberate surface reversal")
	await _new_fixture(Vector2(-20, 0), Rect2(-500, 0, 500, 16))
	world.get_child(0).set_meta("surface_physics", ICE)
	_solid(Rect2(0, 0, 500, 16))
	await _ticks(2)
	body.velocity = Vector2(100, 0)
	var crossed: bool = false
	for tick: int in 80:
		var previous_speed: float = body.velocity.x
		var previous_surface: StringName = body.active_surface.id
		await _tick()
		check(body.velocity.x <= previous_speed + 0.01, "Seam cannot accelerate released player")
		if previous_surface == &"ice" and body.active_surface.id == &"normal":
			crossed = true
			check(body.velocity.x > 20.0, "Surface seam preserves velocity, applies new drag next tick")
			break
	check(crossed, "Walk/slide across real adjacent collision shapes")
	await _ticks(20)
	near(body.velocity.x, 0.0, 0.01, "Normal surface stops incoming ice momentum")
	body.reset_movement(Vector2(-20, 0))
	await _ticks(8)
	check(body.velocity == Vector2.ZERO and not body.is_sliding(), "Reset clears sliding motion")
	await _new_fixture(Vector2(20, 0), Rect2(0, 0, 40, 8))
	world.get_child(0).set_meta("surface_physics", ICE)
	await _ticks(2)
	body.velocity = Vector2(100, 0)
	await _ticks(30)
	check(body.state == PlayerController.State.FALLING and body.velocity.x > 40.0, "Ice runoff retains bounded horizontal momentum in air")
	await _tick(0, true, true)
	check(body.state == PlayerController.State.FALLING and body.charge_duration == 0.0, "Ice runoff cannot charge in air")
	body.reset_movement(Vector2(20, 0))
	await _ticks(8)
	check(body.position.distance_to(Vector2(20, 0)) < 0.1 and not body.is_sliding(), "Reset from ice runoff safely reacquires support")


func _slopes_and_ramps() -> void:
	for rise: float in [45.0, 126.0]:
		await _new_fixture()
		LabSections.polygon(world, "Slope", Vector2.ZERO, PackedVector2Array([Vector2.ZERO, Vector2(180, -rise), Vector2(180, 16), Vector2(0, 16)]))
		body.reset_movement(Vector2(25, -rise * 30.0 / 180.0 - 20))
		await _ticks(40)
		check(body.is_on_floor(), "Slope acquires floor contact")
		near(body.slope_degrees(), rad_to_deg(atan(rise / 180.0)), 0.2, "Solver slope normal matches polygon")
		var rest: Vector2 = body.position
		await _ticks(30)
		check(body.position.distance_to(rest) < 0.1, "Normal slope does not drift at rest")
		print("SLOPE %.2fdeg rest drift=%.4fpx" % [body.slope_degrees(), body.position.distance_to(rest)])
		for tick: int in 45:
			await _tick(1)
			check(body.is_on_floor(), "Uphill support stays continuous")
		check(body.position.y < rest.y - 5, "Uphill movement climbs")
		for tick: int in 35:
			await _tick(-1)
			check(body.is_on_floor(), "Downhill support stays continuous")
		var jump: Dictionary = await _jump(0.75, 1)
		near(jump.get("initial_velocity", Vector2.ZERO).y, -360.0, 0.01, "Slope jump uses baseline vertical impulse")
		check(body.state == PlayerController.State.GROUNDED, "Slope jump lands/recovery completes")
	await _new_fixture()
	LabSections.polygon(world, "LongRamp", Vector2(0, -600), PackedVector2Array([Vector2.ZERO, Vector2(1200, 600), Vector2(1200, 616), Vector2(0, 16)]), RAMP)
	body.reset_movement(Vector2(25, -610))
	await _ticks(40)
	check(body.active_surface == RAMP and body.is_on_floor(), "Designated gravity ramp identified")
	var initial_speed: float = absf(body.tangent_speed())
	for tick: int in 180:
		await _tick()
		check(body.is_on_floor(), "Gravity ramp support stays continuous")
	check(absf(body.tangent_speed()) > initial_speed + 20, "Downhill gravity builds momentum")
	check(absf(body.tangent_speed()) <= RAMP.maximum_slide_speed + 0.1, "Ramp speed cap respected")
	comparison["ramp_speed"] = body.tangent_speed()
	print("RAMP speed=%.3f angle=%.3f" % [body.tangent_speed(), body.slope_degrees()])
	await _charge(0.2)
	check(body.state != PlayerController.State.CHARGING, "High-speed ramp charge rejected")
	await _ticks(180, -1)
	comparison["ramp_counter_3s"] = body.tangent_speed()
	print("RAMP counter after 3s=%.3f" % body.tangent_speed())
	check(body.tangent_speed() < 10.0, "Counter-input can control ramp speed")
	# Reproduce the first ramp-control trial without mutating an authored Resource.
	var trial: SurfacePhysicsProfile = RAMP.duplicate(true)
	trial.input_influence = 0.4
	world.get_node("LongRamp").set_meta("surface_physics", trial)
	body.reset_movement(Vector2(25, -610))
	await _ticks(40)
	body.velocity = Vector2(-body.surface_normal.y, body.surface_normal.x) * 150.0
	await _ticks(180, -1)
	comparison["trial_ramp_counter_3s"] = body.tangent_speed()
	print("RAMP initial influence 0.40 counter after 3s=%.3f" % body.tangent_speed())
	check(body.tangent_speed() > 40.0, "Initial trial documents insufficient braking authority")
	world.free()
	world = null


func _slide_measurement() -> void:
	await _new_fixture()
	world.get_child(0).set_meta("surface_physics", ICE)
	await _ticks(2)
	await _charge(0.75, 1)
	await _tick(1, false, false, true)
	for tick: int in 100:
		if recorder.completed_count > 0:
			break
		await _tick()
	check(recorder.completed_count == 1, "Sliding measurement has completed actual landing")
	var landing_x: float = body.position.x
	near(recorder.sliding_distance, 0.0, 0.00001, "Airborne landing tick is not counted as sliding travel")
	near(recorder.maximum_sliding_speed, 165.0 * ICE.landing_momentum_retention, 0.05, "Initial retained landing speed recorded")
	await _ticks(12)
	near(recorder.sliding_distance, body.position.x - landing_x, 0.05, "Flat slide integral matches actual relative displacement")


func _transition_chains() -> void:
	await _new_fixture(Vector2(-20, 0), Rect2(-500, 0, 500, 16))
	var ice: StaticBody2D = _solid(Rect2(0, 0, 500, 16))
	ice.set_meta("surface_physics", ICE)
	await _ticks(40, 1)
	check(body.active_surface == ICE and body.is_on_floor(), "Normal-to-ice transition")
	near(body.velocity.x, 65.0, 0.1, "Entering ice does not inject momentum")
	await _new_fixture(Vector2(-20, 0), Rect2(-500, 0, 500, 16))
	world.get_child(0).set_meta("surface_physics", ICE)
	LabSections.polygon(world, "IceToSlope", Vector2.ZERO, PackedVector2Array([Vector2.ZERO, Vector2(160, -40), Vector2(160, 16), Vector2(0, 16)]))
	LabSections.box(world, "SlopeToFlat", Rect2(160, -40, 200, 16))
	await _ticks(200, 1)
	check(body.position.x > 160 and body.is_on_floor(), "Ice-to-slope-to-flat traversable")
	near(body.position.y, -40.0, 0.15, "Slope exit aligns with flat surface")
	near(body.slope_degrees(), 0.0, 0.1, "Slope normal clears on flat")
	await _new_fixture()
	world.get_child(0).free()
	_solid(Rect2(-1000, 100, 3000, 16))
	LabSections.polygon(world, "Runoff", Vector2(0, -100), PackedVector2Array([Vector2.ZERO, Vector2(200, 100), Vector2(200, 116), Vector2(0, 16)]), RAMP)
	LabSections.box(world, "IceRunout", Rect2(200, 0, 200, 16), ICE)
	LabSections.box(world, "NormalBrake", Rect2(400, 0, 500, 16))
	var landing_count: Array[int] = [0]
	body.landed.connect(func(_at: Vector2) -> void: landing_count[0] += 1)
	body.reset_movement(Vector2(15, -110))
	await _ticks(40)
	var saw_ice: bool = false
	var saw_normal: bool = false
	for tick: int in 480:
		await _tick(1)
		if body.active_surface == ICE:
			saw_ice = true
		if saw_ice and body.active_surface == NORMAL:
			saw_normal = true
			break
	check(saw_ice and saw_normal, "Gravity ramp momentum carries across ice into normal brake")
	await _ticks(30)
	near(body.velocity.x, 0.0, 0.1, "Runout normal ground stops retained momentum")
	near(body.position.y, 0.0, 0.15, "Runout did not fall through seam to recovery floor")
	check(landing_count[0] == 1, "No extra landing events at surface seams")


func _moving_platforms() -> void:
	for profile: SurfacePhysicsProfile in [NORMAL, ICE]:
		await _moving_case(profile, Vector2(30, 0))
	await _moving_case(NORMAL, Vector2(0, 12))


func _moving_case(profile: SurfacePhysicsProfile, offset: Vector2) -> void:
	await _new_fixture()
	# Use the live controller so platform -20 priority runs before player 0 priority.
	var mover: PhysicsSurface = LabSections.box(world, "Mover", Rect2(-80, -48, 160, 8), profile)
	mover.motion_offset = offset
	mover.motion_period = 2.0
	body.reset_movement(Vector2(0, -48))
	body.accepts_live_input = true
	await _live_ticks(20)
	check(body.is_on_floor(), "Moving platform supports passenger")
	var relative_position: Vector2 = body.position - mover.position
	await _live_ticks(80)
	check(body.is_on_floor(), "Direction reversal retains passenger")
	check((body.position - mover.position).distance_to(relative_position) < 2.0, "Platform carries without input")
	paused = true
	var paused_body: Vector2 = body.position
	var paused_platform: Vector2 = mover.position
	await process_frame
	await process_frame
	check(body.position == paused_body and mover.position == paused_platform, "Pause freezes moving platform and passenger")
	paused = false
	_send_action("jump_charge", true)
	await _live_ticks(45)
	_send_action("jump_charge", false)
	await _live_ticks(2)
	near(body.velocity.x, 0.0, 0.1, "Default departure has no injected horizontal platform velocity")
	await _live_ticks(60)
	check(body.is_on_floor(), "Player lands back on moving platform")
	body.reset_movement(Vector2(0, 0))
	await _live_ticks(8)
	check(body.is_on_floor() and body.active_surface == NORMAL, "Reset away from mover reacquires normal floor")
	check(body.position.distance_to(Vector2.ZERO) < 0.1, "Reset does not carry stale platform velocity to new spawn")
	body.accepts_live_input = false
	world.free()
	world = null


func _lab_navigation() -> void:
	var lab: PhysicsLab = load("res://scenes/levels/physics_lab.tscn").instantiate() as PhysicsLab
	root.add_child(lab)
	current_scene = lab
	body = lab.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder") as JumpRecorder
	check(lab.section_selector.item_count == LabSections.LABELS.size(), "Classic + A-G + three H challenges accessible")
	for index: int in range(1, LabSections.LABELS.size()):
		lab.section_selector.item_selected.emit(index)
		await process_frame
		await process_frame
		await _ticks(12)
		check(lab.section_index == index, "Section selected " + str(index))
		check(body.is_on_floor(), "Section has accessible supported spawn " + str(index))
		check(lab.get_node("Geometry").get_child_count() >= 3, "Section contains actual fixtures")
		lab.reset_lab()
		check(body.velocity == Vector2.ZERO and body.charge_duration == 0.0, "Section reset clears transient physics")
	lab.hud.toggle_debug()
	await process_frame
	await process_frame
	check(lab.hud.debug_label.text.contains("friction") and lab.hud.debug_label.text.contains("normal"), "F3 reports surface fields")
	lab.diagnostics.set_enabled(true)
	check(lab.diagnostics.enabled, "Trace/normal/collider toggle available")
	await _challenge_routes(lab)
	lab.free()
	current_scene = null


func _select(lab: PhysicsLab, index: int) -> void:
	lab.select_section(index)
	await process_frame
	await process_frame
	await _ticks(8)


func _walk_to(x: float) -> void:
	for tick: int in 180:
		if absf(body.position.x - x) < 0.8:
			return
		await _tick(1 if body.position.x < x else -1)
	check(false, "Reference launch position reachable on foot")


func _challenge_routes(lab: PhysicsLab) -> void:
	await _select(lab, 4)
	for recipe: Array in [[45.0, 0.5, 1, 112.0], [110.0, 0.6, 1, 64.0], [183.0, 0.65, -1, 12.0]]:
		await _walk_to(recipe[0])
		await _jump(recipe[1], recipe[2])
		near(body.position.y, recipe[3], 0.15, "Actual narrow-ledge reference route")
	await _select(lab, 8)
	await _walk_to(30.0)
	await _jump(0.45, 1)
	near(body.position.y, 112.0, 0.15, "H1 lands on ice approach")
	for tick: int in 120:
		if absf(body.tangent_speed()) <= ICE.charge_speed_limit:
			break
		await _tick(-1)
	check(body.is_on_floor() and body.active_surface == ICE, "H1 brakes on ice before edge")
	await _walk_to(108.0)
	for tick: int in 30:
		if absf(body.velocity.x) <= ICE.charge_speed_limit:
			break
		await _tick(-1)
	await _jump(0.62, 1)
	near(body.position.y, 64.0, 0.15, "H1 reaches narrow target after deliberate braking")
	await _select(lab, 9)
	await _walk_to(126.0)
	var rebound: Dictionary = await _jump(0.75, 1)
	near(body.position.y, 96.0, 0.15, "H2 rebound reaches return ledge")
	check(rebound.get("wall_collision_count", 0) == 1, "H2 uses exactly one controlled rebound")
	await _select(lab, 10)
	for tick: int in 360:
		await _tick()
		if body.position.x > 190 and body.active_surface == NORMAL and absf(body.velocity.x) < 0.5:
			break
	check(body.is_on_floor() and body.position.x > 190 and body.position.y < 136.1, "H3 ramp runs onto safe brake pad")
	await _walk_to(221.0)
	await _jump(0.5, 1)
	near(body.position.y, 104.0, 0.15, "H3 normal brake pad launches onto ice target")
