extends "res://tests/physics_test.gd"

const ICE: SurfacePhysicsProfile = preload("res://resources/surfaces/ice.tres")
const EXTREME: SurfacePhysicsProfile = preload("res://resources/surfaces/ice_extreme.tres")
var measurements: Dictionary = {}

func _run() -> void:
	await _ice_measurements()
	await _rebounds()
	await _optional_pad_and_repeat()
	await _ricochet_routes()
	await _render_separation()
	var file: FileAccess = FileAccess.open("res://.godot/refinement_measurements.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(measurements, "\t"))
	if failures.is_empty():
		print("PASS: %d refinement checks" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d refinement checks" % [failures.size(), checks])
		quit(1)

func _ice_measurements() -> void:
	for profile: SurfacePhysicsProfile in [EXTREME, ICE, preload("res://resources/surfaces/ice_mild.tres")]:
		check(profile.validation_errors().is_empty(), "Ice profile valid")
		var row: Dictionary = {}
		for reverse: bool in [false, true]:
			await _new_fixture()
			world.get_child(0).set_meta("surface_physics", profile)
			await _ticks(2)
			body.velocity.x = 65.0
			var start: float = body.position.x
			for tick: int in 300:
				await _tick(-1 if reverse else 0)
				if body.velocity.x <= 0.0:
					row["reverse" if reverse else "release"] = {"seconds": (tick + 1) * DT, "distance": body.position.x - start}
					break
			check(row.has("reverse" if reverse else "release"), "Ice stops/reverses finitely")
			if profile == ICE and reverse:
				check(body.position.x - start < 10, "Moderate ice reverse within one collider width")
		await _new_fixture()
		world.get_child(0).set_meta("surface_physics", profile)
		await _ticks(2)
		await _jump(0.75, 1)
		var start: float = body.position.x
		for tick: int in 400:
			await _tick()
			if is_zero_approx(body.velocity.x):
				row["landing_release"] = {"distance_after_recovery": body.position.x - start, "seconds_after_recovery": (tick + 1) * DT}
				break
		check(is_zero_approx(body.velocity.x), "Landing slide reaches exact rest")
		await _charge(0.2)
		check(body.state == PlayerController.State.CHARGING and body.velocity == Vector2.ZERO, "Stopped ice charge remains stationary")
		measurements[String(profile.id)] = row
		print("ICE ", profile.id, " ", row)

func _rebounds() -> void:
	for direction: int in [-1, 1]:
		for speed: float in [20.0, 65.0, 165.0, 500.0]:
			await _new_fixture()
			_solid(Rect2(38 if direction == 1 else -46, -200, 8, 200))
			body.reset_movement(Vector2(direction * 30, -90))
			body.velocity = Vector2(direction * speed, -120)
			body.state = PlayerController.State.RISING
			for tick: int in 30:
				var incoming: Vector2 = body.velocity + Vector2(0, DEFAULT_CONFIG.gravity * DT)
				await _tick()
				if body.is_on_wall():
					near(body.velocity.x, -direction * speed * 0.6 if speed >= 30 else 0.0, 0.1, "Ordinary mirrored side restitution / threshold")
					if speed >= 30:
						near(body.velocity.y, incoming.y, 0.1, "Vertical motion preserved")
						check(body.velocity.length_squared() <= incoming.length_squared() + 0.1, "Static rebound energy bound")
					break
			check(body.is_on_wall(), "Actual collision at tested speed")
			check(body.rebound_count == (1 if speed >= 30 else 0), "One impulse per side contact, no low-speed jitter")
	# Relative velocity against an actual AnimatableBody2D side, not floor carry.
	await _new_fixture()
	var moving: PhysicsSurface = LabSections.box(world, "MovingSide", Rect2(38, -200, 8, 200))
	moving.motion_offset = Vector2(20, 0)
	moving.motion_period = 4.0
	body.reset_movement(Vector2(30, -90))
	body.velocity = Vector2(165, -120)
	body.state = PlayerController.State.RISING
	for tick: int in 30:
		await _tick()
		if body.rebound_count > 0:
			var collision: KinematicCollision2D = body.get_slide_collision(0)
			var carrier: Vector2 = collision.get_collider_velocity()
			check(absf(carrier.x) > 1.0, "Moving side supplies collider velocity")
			near(body.velocity.x, -(165.0 - carrier.x) * 0.6 + carrier.x, 0.1, "Moving side reflects relative velocity once")
			break
	check(body.rebound_count == 1, "Moving side rebound observed")
	# Diagonal is opt-in, rising-only, once per jump and bounded in relative energy.
	for rising: bool in [true, false]:
		await _new_fixture()
		_solid(Rect2(38, -200, 8, 200))
		body.collision_response = CollisionResponseProfile.new()
		body.collision_response.diagonal_energy_fraction = 0.5
		body.reset_movement(Vector2(30, -90))
		body.velocity = Vector2(165, -120 if rising else 120)
		body.state = PlayerController.State.RISING if rising else PlayerController.State.FALLING
		var incoming: Vector2 = body.velocity + Vector2(0, 15)
		await _tick()
		if body.rebound_count == 0:
			await _tick()
		check(body.last_rebound_type == ("diagonal" if rising else "horizontal"), "Explicit rising-only diagonal activation")
		check(body.velocity.length_squared() <= incoming.length_squared() + 0.1, "Diagonal redirects existing energy")

func _ricochet_routes() -> void:
	var lab: PhysicsLab = preload("res://scenes/levels/physics_lab.tscn").instantiate()
	if world != null:
		world.free()
	world = lab
	root.add_child(lab)
	body = lab.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder")
	for section: int in [11, 12, 13, 14, 15, 16]:
		lab.select_section(section)
		await process_frame
		await _ticks(8)
		var jump: Dictionary = await _jump(0.7 if section in [14, 16] else 0.75, 1)
		near(body.position.y, 80.0 if section == 13 else 96.0, 0.15, "Complete intentional ricochet " + LabSections.LABELS[section])
		check(jump.get("rebound_count", 0) >= (2 if section == 13 else 1), "Ricochet requires observed impulses")
		if section == 14:
			check(jump.get("rebound_incoming", Vector2.ZERO).y < 0.0, "Rising route strikes the wall before its apex")
		if section == 16:
			check(jump.get("rebound_type") == "diagonal", "Optional diagonal fixture actually redirects energy")
		measurements[LabSections.LABELS[section]] = {"charge": jump.get("charge_seconds"), "landing": str(body.position), "rebounds": jump.get("rebound_count"), "rise": jump.get("peak_height"), "air": jump.get("airborne_seconds")}

func _render_separation() -> void:
	check(ProjectSettings.get_setting("physics/common/physics_interpolation"), "Engine physics interpolation enabled")
	check(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items", "Window-resolution 2D rendering")
	await _new_fixture()
	var camera: LabCamera = LabCamera.new()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	camera.target = body
	world.add_child(camera)
	body.reset_movement(Vector2(12.375, -100.375))
	camera.reset_tracking()
	await process_frame
	near(body.get_node("Visual").position.x, 0.0, 0.0001, "Visual inherits fractional body transform")
	check(not is_equal_approx(camera.position.y, roundf(camera.position.y)), "Camera retains fractional translation")


func _optional_pad_and_repeat() -> void:
	await _new_fixture()
	var pad: SurfacePhysicsProfile = SurfacePhysicsProfile.new()
	pad.contact_response = CollisionResponseProfile.new()
	pad.contact_response.top_restitution = 0.5
	world.get_child(0).set_meta("surface_physics", pad)
	body.reset_movement(Vector2(0, -80))
	body.velocity = Vector2(0, 100)
	var observed: bool = false
	for tick: int in 50:
		var incoming: float = body.velocity.y + 15.0
		await _tick()
		if body.is_on_floor() and body.state == PlayerController.State.RISING:
			near(body.velocity.y, -incoming * 0.5, 0.1, "Optional top restitution reflects only configured pad")
			observed = true
			break
	check(observed, "Optional vertical pad bounce observed")
	await _new_fixture()
	_solid(Rect2(-24, -200, 8, 200))
	_solid(Rect2(24, -200, 8, 200))
	body.collision_response = CollisionResponseProfile.new()
	body.collision_response.diagonal_energy_fraction = 0.5
	var kinds: Array[String] = []
	body.rebounded.connect(func(_normal: Vector2, _impulse: Vector2, kind: String) -> void: kinds.append(kind))
	await _charge(0.75, 1)
	await _tick(1, false, false, true)
	check(await _land(), "Repeated shaft contacts eventually settle")
	check(kinds.count("diagonal") == 1, "Only one diagonal redirect during a jump")
	check(kinds.size() >= 2 and kinds.size() < 10, "Consecutive opposing wall impulses remain bounded")
	await _ticks(180, 1)
	check(body.velocity == Vector2.ZERO and body.is_on_floor(), "Sustained supported wall pressure does not jitter")
