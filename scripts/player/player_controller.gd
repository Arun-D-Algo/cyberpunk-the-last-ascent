class_name PlayerController
extends CharacterBody2D

signal rebounded(normal: Vector2, impulse: Vector2, kind: String)
signal state_changed(previous: int, current: int)
signal jump_started(start: Vector2, charge_seconds: float, effective_strength: float, launch: Vector2)
signal landed(at: Vector2)
signal movement_reset
signal physics_stepped(delta: float)
signal contact_impact(normal: Vector2, incoming: Vector2)
signal surface_changed(previous: SurfacePhysicsProfile, current: SurfacePhysicsProfile)

enum State { GROUNDED, CHARGING, RISING, FALLING, LANDING }

@export var physics_config: PlayerPhysicsConfig
@export var collision_response: CollisionResponseProfile = preload("res://resources/physics/default_collision_response.tres")
const NORMAL: SurfacePhysicsProfile = preload("res://resources/surfaces/normal.tres")
var active_surface: SurfacePhysicsProfile = NORMAL
var surface_normal: Vector2 = Vector2.UP
var surface_body_name: StringName = &"world"
var last_landing_velocity: Vector2 = Vector2.ZERO
var charge_blocked: bool = false
var rebound_count: int = 0
var last_rebound_impulse: Vector2 = Vector2.ZERO
var last_rebound_type: String = "none"
var wall_contact_normal: Vector2 = Vector2.ZERO
var current_zone: String = "LAB"
var world_height: float = 0.0
var maximum_height: float = 0.0
var last_landing_surface: StringName = &"none"
var _diagonal_used: bool = false
var _previous_wall_body: int = 0
var _previous_wall: Vector2 = Vector2.ZERO
var _previous_ceiling: bool = false
var state: State = State.FALLING
var charge_duration: float = 0.0
var selected_direction: int = 0
var facing_direction: int = 1
var landing_remaining: float = 0.0
var accepts_live_input: bool = true
var _charge_press: bool = false
var _charge_release: bool = false
var _jump_armed: bool = true
var _discard_floor_once: bool = false


func _ready() -> void:
	if physics_config == null:
		push_error("Player requires PlayerPhysicsConfig")
		set_physics_process(false)
		return
	var errors: PackedStringArray = physics_config.validation_errors()
	if collision_response == null:
		push_error("Player requires CollisionResponseProfile")
		set_physics_process(false)
		return
	errors.append_array(collision_response.validation_errors())
	if not errors.is_empty():
		push_error("Invalid player config: " + "; ".join(errors))
		set_physics_process(false)
	# Carry while supported, but no engine-injected launch velocity on departure.
	platform_on_leave = CharacterBody2D.PLATFORM_ON_LEAVE_DO_NOTHING


func _unhandled_input(event: InputEvent) -> void:
	if not accepts_live_input or get_tree().paused:
		return
	if event.is_action_pressed("jump_charge") and not event.is_echo():
		_charge_press = true
	if event.is_action_released("jump_charge"):
		_charge_release = true


func _physics_process(delta: float) -> void:
	if not accepts_live_input:
		return
	step_movement(delta, JumpPhysics.direction(Input.is_action_pressed("move_left"), Input.is_action_pressed("move_right")), _charge_press, Input.is_action_pressed("jump_charge"), _charge_release)
	_charge_press = false
	_charge_release = false


## Same fixed-tick entry point used by live input and the isolated physics harness.
## Call only once per physics tick; owns the single move_and_slide invocation.
func step_movement(delta: float, direction: int, pressed: bool, held: bool, released: bool) -> void:
	if get_tree().paused:
		return
	var reacquiring_floor: bool = _discard_floor_once
	var floor_before: bool = is_on_floor() and not reacquiring_floor
	_discard_floor_once = false
	charge_blocked = floor_before and absf(tangent_speed()) > active_surface.charge_speed_limit
	floor_stop_on_slope = not active_surface.gravity_slide or state == State.CHARGING
	# We already integrate along the tangent. Godot's constant-speed reprojection would
	# reinterpret inward contact pressure as travel speed (and can reverse a slow ramp slide).
	floor_constant_speed = false
	selected_direction = clampi(direction, -1, 1)
	if selected_direction != 0:
		facing_direction = selected_direction
	if not held and not pressed:
		_jump_armed = true
	if (state == State.GROUNDED or state == State.CHARGING or state == State.LANDING) and not floor_before:
		_cancel_charge()
		_transition(State.FALLING)
	if state == State.LANDING:
		landing_remaining = maxf(0.0, landing_remaining - delta)
		if landing_remaining <= 0.0:
			_transition(State.GROUNDED)
	if state == State.GROUNDED:
		if pressed and _jump_armed and floor_before:
			_jump_armed = false
			if not charge_blocked:
				charge_duration = 0.0
				if not active_surface.moving_charge_allowed:
					velocity = Vector2.ZERO
				_transition(State.CHARGING)
			else:
				_ground_motion(delta, selected_direction)
		else:
			_ground_motion(delta, selected_direction)
	elif state == State.LANDING:
		_ground_motion(delta, 0)
	var launched: bool = false
	if state == State.CHARGING:
		if not active_surface.moving_charge_allowed:
			velocity = Vector2.ZERO
		else:
			_ground_motion(delta, 0)
		if held:
			charge_duration = minf(charge_duration + delta, physics_config.maximum_charge_time)
		if released:
			var launch: Vector2 = JumpPhysics.launch_velocity(charge_duration, selected_direction, physics_config)
			launch += velocity * active_surface.jump_momentum_retention
			launch += get_platform_velocity() * collision_response.platform_velocity_inheritance
			_diagonal_used = false
			velocity = launch
			jump_started.emit(global_position, charge_duration, JumpPhysics.strength(charge_duration, physics_config), launch)
			charge_duration = 0.0
			_transition(State.RISING)
			launched = true
	var intended_ground_velocity: Vector2 = velocity
	if not floor_before or launched:
		velocity.y = minf(velocity.y + physics_config.gravity * delta, physics_config.maximum_fall_speed)
		if not launched and physics_config.air_control_factor > 0.0:
			velocity.x = move_toward(velocity.x, selected_direction * physics_config.maximum_horizontal_impulse, physics_config.ground_acceleration * physics_config.air_control_factor * delta)
	else:
		# Downward pressure refreshes the solver's floor classification every tick.
		var resting: bool = velocity.length_squared() < 0.01 and floor_stop_on_slope
		velocity += (Vector2.DOWN if resting else -surface_normal) * physics_config.gravity * delta
	var incoming: Vector2 = velocity
	var carry_layers: int = platform_floor_layers
	if reacquiring_floor:
		# The engine also caches the old supporting body's carry velocity. Suppress
		# that cache for the teleport's first move, then restore normal floor detection.
		platform_floor_layers = 0
	move_and_slide()
	platform_floor_layers = carry_layers
	_resolve_contacts(incoming)
	if floor_before and not launched and state in [State.GROUNDED, State.CHARGING, State.LANDING]:
		# Godot clears the vertical component on floor contact. Restore our tangential
		# state, not the inward solver pressure, so slope momentum is neither lost nor inverted.
		if is_on_floor():
			var tangent: Vector2 = Vector2(-surface_normal.y, surface_normal.x)
			var blocked: bool = is_on_wall() and intended_ground_velocity.dot(wall_contact_normal) < -0.01
			velocity = Vector2.ZERO if blocked else tangent * intended_ground_velocity.dot(tangent)
		else:
			velocity = intended_ground_velocity + Vector2.DOWN * physics_config.gravity * delta
	if is_on_floor():
		if state == State.RISING or state == State.FALLING:
			last_landing_surface = surface_body_name
			last_landing_velocity = incoming
			var tangent: Vector2 = Vector2(-surface_normal.y, surface_normal.x)
			var retained: float = clampf(incoming.dot(tangent) * active_surface.landing_momentum_retention, -active_surface.maximum_slide_speed, active_surface.maximum_slide_speed)
			velocity = tangent * retained
			_cancel_charge()
			landing_remaining = physics_config.landing_recovery_time
			_transition(State.LANDING)
			landed.emit(global_position)
			var top_response: CollisionResponseProfile = active_surface.contact_response
			var relative: Vector2 = incoming - get_platform_velocity()
			if top_response != null and top_response.top_restitution > 0.0 and relative.dot(surface_normal) < -30.0:
				velocity = (relative - surface_normal * (1.0 + top_response.top_restitution) * relative.dot(surface_normal)).limit_length(relative.length()) + get_platform_velocity()
				_transition(State.RISING)

	else:
		if state == State.GROUNDED or state == State.CHARGING or state == State.LANDING:
			_cancel_charge()
			_transition(State.FALLING)
		elif state == State.RISING and velocity.y >= 0.0:
			_transition(State.FALLING)
	physics_stepped.emit(delta)


func tangent_speed() -> float:
	return velocity.dot(Vector2(-surface_normal.y, surface_normal.x))


func slope_degrees() -> float:
	return rad_to_deg(acos(clampf(surface_normal.dot(Vector2.UP), -1.0, 1.0)))


func is_sliding() -> bool:
	if not is_on_floor() or state == State.CHARGING:
		return false
	var speed := absf(tangent_speed())
	if _downhill_drive() != 0.0:
		return not is_zero_approx(speed)
	return (active_surface.landing_momentum_retention > 0.0 or active_surface.gravity_slide) and speed > active_surface.stop_speed


func _downhill_drive() -> float:
	if active_surface.gravity_slide and slope_degrees() >= active_surface.minimum_slide_angle:
		return surface_normal.x * active_surface.downhill_acceleration
	return 0.0


func _ground_motion(delta: float, direction: int) -> void:
	var tangent: Vector2 = Vector2(-surface_normal.y, surface_normal.x)
	var speed: float = velocity.dot(tangent)
	var drive := _downhill_drive()
	var target: float = direction * physics_config.ground_speed * active_surface.ground_speed_scale
	if direction != 0:
		# Inertia above walking speed is reduced with acceleration; never snap-clamped on entry.
		var braking: float = active_surface.reverse_braking_scale if direction * speed < 0.0 else 1.0
		speed = move_toward(speed, target, physics_config.ground_acceleration * active_surface.acceleration_scale * active_surface.input_influence * braking * delta)
	else:
		var drag := physics_config.ground_deceleration * active_surface.friction
		if drive != 0.0 and speed * drive >= 0.0:
			# Keep at least one quarter of projected gravity available to build downhill speed.
			drag = minf(drag, absf(drive) * 0.75)
		speed = move_toward(speed, 0.0, drag * delta)
	speed += drive * delta
	if active_surface.gravity_slide or active_surface.landing_momentum_retention > 0.0:
		speed = clampf(speed, -active_surface.maximum_slide_speed, active_surface.maximum_slide_speed)
	if drive == 0.0 and absf(speed) < active_surface.stop_speed:
		speed = 0.0
	velocity = tangent * speed


func _profile(collider: Object) -> SurfacePhysicsProfile:
	if collider == null or not collider.has_meta("surface_physics"):
		return NORMAL
	var profile: SurfacePhysicsProfile = collider.get_meta("surface_physics", null) as SurfacePhysicsProfile
	return profile if profile != null else NORMAL


func _set_surface(profile: SurfacePhysicsProfile) -> void:
	if profile == active_surface:
		return
	var errors: PackedStringArray = profile.validation_errors()
	if not errors.is_empty():
		push_error("Invalid contacted surface: " + "; ".join(errors))
		profile = NORMAL
	var previous: SurfacePhysicsProfile = active_surface
	active_surface = profile
	surface_changed.emit(previous, active_surface)


func _resolve_contacts(incoming: Vector2) -> void:
	var wall_normal: Vector2 = Vector2.ZERO
	var wall_velocity: Vector2 = Vector2.ZERO
	var wall_body: int = 0
	var ceiling: bool = false
	var response: CollisionResponseProfile = collision_response
	var floor_distance: float = INF
	var floor_profile: SurfacePhysicsProfile = active_surface
	var found_floor: bool = false
	for index: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		var normal: Vector2 = collision.get_normal()
		var up_dot: float = normal.dot(Vector2.UP)
		if up_dot >= cos(floor_max_angle) - 0.001:
			var distance: float = absf(collision.get_position().x - global_position.x)
			if distance < floor_distance:
				floor_distance = distance
				floor_profile = _profile(collision.get_collider())
				surface_normal = normal
				var collider: Node = collision.get_collider() as Node
				if floor_profile.gravity_slide and collider is PhysicsSurface:
					surface_normal = collider.ramp_face_normal(collision.get_position(), normal)
				surface_body_name = collider.name if collider != null else &"world"
				found_floor = true
		elif up_dot <= -cos(floor_max_angle) + 0.001:
			ceiling = true
		else:
			if absf(normal.x) > absf(wall_normal.x):
				wall_normal = normal
				wall_velocity = collision.get_collider_velocity()
				wall_body = collision.get_collider_id()
				var wall_profile: SurfacePhysicsProfile = _profile(collision.get_collider())
				response = wall_profile.contact_response if wall_profile.contact_response != null else collision_response
	if found_floor:
		_set_surface(floor_profile)
	elif not is_on_floor():
		surface_normal = Vector2.UP
		surface_body_name = &"air"
		_set_surface(NORMAL)
	wall_contact_normal = wall_normal
	if not wall_normal.is_zero_approx() and (incoming - wall_velocity).dot(wall_normal) < -0.01:
		if wall_body != _previous_wall_body or not wall_normal.is_equal_approx(_previous_wall):
			contact_impact.emit(wall_normal, incoming)
			var relative: Vector2 = incoming - wall_velocity
			if not is_on_floor() and not ceiling and absf(relative.x) >= response.minimum_impact_speed and response.wall_mode == CollisionResponseProfile.WallMode.REBOUND:
				var outgoing: Vector2 = Vector2(signf(wall_normal.x) * absf(relative.x) * response.wall_restitution, relative.y)
				last_rebound_type = "horizontal"
				if response.diagonal_energy_fraction > 0.0 and relative.y < 0.0 and not _diagonal_used:
					var transfer: float = outgoing.x * outgoing.x * response.diagonal_energy_fraction
					var rise: float = minf(sqrt(relative.y * relative.y + transfer), maxf(absf(relative.y), response.diagonal_vertical_limit))
					var used: float = rise * rise - relative.y * relative.y
					outgoing.x = signf(outgoing.x) * sqrt(maxf(0.0, outgoing.x * outgoing.x - used))
					outgoing.y = -rise
					_diagonal_used = true
					last_rebound_type = "diagonal"
				velocity = outgoing.limit_length(relative.length()) + wall_velocity
				last_rebound_impulse = velocity - incoming
				_rebound_event(wall_normal)
	_previous_wall_body = wall_body
	if ceiling:
		if not _previous_ceiling and incoming.y < 0.0:
			contact_impact.emit(Vector2.DOWN, incoming)
		velocity.y = maxf(velocity.y, minf(response.ceiling_downward_speed, absf(incoming.y)))
	_previous_wall = wall_normal
	_previous_ceiling = ceiling


func _rebound_event(normal: Vector2) -> void:
	rebound_count += 1
	rebounded.emit(normal, last_rebound_impulse, last_rebound_type)


func cancel_input_until_release() -> void:
	_cancel_charge()
	_charge_press = false
	_charge_release = false
	_jump_armed = false
	if state == State.CHARGING:
		_transition(State.GROUNDED if is_on_floor() else State.FALLING)


func reset_movement(at: Vector2) -> void:
	global_position = at
	reset_physics_interpolation()
	rebound_count = 0
	last_rebound_impulse = Vector2.ZERO
	last_rebound_type = "none"
	last_landing_surface = &"none"
	wall_contact_normal = Vector2.ZERO
	_previous_wall_body = 0
	_diagonal_used = false
	velocity = Vector2.ZERO
	landing_remaining = 0.0
	selected_direction = 0
	facing_direction = 1
	_set_surface(NORMAL)
	surface_normal = Vector2.UP
	surface_body_name = &"air"
	last_landing_velocity = Vector2.ZERO
	charge_blocked = false
	_previous_wall = Vector2.ZERO
	_previous_ceiling = false
	cancel_input_until_release()
	# is_on_floor belongs to the previous move; reacquire contact at the new position.
	_discard_floor_once = true
	_transition(State.FALLING)
	movement_reset.emit()


func charge_fraction() -> float:
	return JumpPhysics.normalized_charge(charge_duration, physics_config) if state == State.CHARGING else 0.0


func state_name() -> String:
	return State.keys()[state]


func _cancel_charge() -> void:
	charge_duration = 0.0


func _transition(next: State) -> void:
	if next == state:
		return
	var previous: State = state
	state = next
	state_changed.emit(previous, state)
