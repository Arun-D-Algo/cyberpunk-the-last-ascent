class_name PlayerController
extends CharacterBody2D

signal state_changed(previous: int, current: int)
signal jump_started(start: Vector2, charge_seconds: float, effective_strength: float, launch: Vector2)
signal landed(at: Vector2)
signal movement_reset
signal physics_stepped(delta: float)

enum State { GROUNDED, CHARGING, RISING, FALLING, LANDING }

@export var physics_config: PlayerPhysicsConfig
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
	if not errors.is_empty():
		push_error("Invalid player config: " + "; ".join(errors))
		set_physics_process(false)


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
	var floor_before: bool = is_on_floor() and not _discard_floor_once
	_discard_floor_once = false
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
		velocity.x = 0.0
		if landing_remaining <= 0.0:
			_transition(State.GROUNDED)
	if state == State.GROUNDED:
		if pressed and _jump_armed and floor_before:
			_jump_armed = false
			charge_duration = 0.0
			velocity.x = 0.0
			_transition(State.CHARGING)
		else:
			var target: float = selected_direction * physics_config.ground_speed
			var acceleration: float = physics_config.ground_acceleration if selected_direction != 0 else physics_config.ground_deceleration
			velocity.x = move_toward(velocity.x, target, acceleration * delta)
	var launched: bool = false
	if state == State.CHARGING:
		velocity.x = 0.0
		if held:
			charge_duration = minf(charge_duration + delta, physics_config.maximum_charge_time)
		if released:
			var launch: Vector2 = JumpPhysics.launch_velocity(charge_duration, selected_direction, physics_config)
			velocity = launch
			jump_started.emit(global_position, charge_duration, JumpPhysics.strength(charge_duration, physics_config), launch)
			charge_duration = 0.0
			_transition(State.RISING)
			launched = true
	if not floor_before or launched:
		velocity.y = minf(velocity.y + physics_config.gravity * delta, physics_config.maximum_fall_speed)
		if not launched and physics_config.air_control_factor > 0.0:
			velocity.x = move_toward(velocity.x, selected_direction * physics_config.maximum_horizontal_impulse, physics_config.ground_acceleration * physics_config.air_control_factor * delta)
	else:
		# Downward pressure refreshes the solver's floor classification every tick.
		velocity.y = physics_config.gravity * delta
	move_and_slide()
	if is_on_floor():
		if state == State.RISING or state == State.FALLING:
			velocity = Vector2.ZERO
			_cancel_charge()
			landing_remaining = physics_config.landing_recovery_time
			_transition(State.LANDING)
			landed.emit(global_position)
	else:
		if state == State.GROUNDED or state == State.CHARGING or state == State.LANDING:
			_cancel_charge()
			_transition(State.FALLING)
		elif state == State.RISING and velocity.y >= 0.0:
			_transition(State.FALLING)
	physics_stepped.emit(delta)


func cancel_input_until_release() -> void:
	_cancel_charge()
	_charge_press = false
	_charge_release = false
	_jump_armed = false
	if state == State.CHARGING:
		_transition(State.GROUNDED if is_on_floor() else State.FALLING)


func reset_movement(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	landing_remaining = 0.0
	selected_direction = 0
	facing_direction = 1
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
