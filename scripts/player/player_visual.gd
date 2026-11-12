extends Node2D
## Presentation derives poses from gameplay signals and fixed-tick state.

const FRAMES: SpriteFrames = preload("res://resources/visuals/david_frames_cinematic.tres")
const LAUNCH_SECONDS := 0.08
const LAND_KEY_SECONDS := 0.05
const HARD_LANDING_SPEED := 285.0
const IMPACT_SECONDS := 0.10
const APEX_SPEED := 40.0
const FALL_HYSTERESIS := 24.0

enum FallPhase { EARLY, NORMAL, FAST }

@export_range(40.0, 150.0) var normal_fall_speed := 75.0
@export_range(175.0, 600.0) var fast_fall_speed := 315.0

@onready var player: PlayerController = get_parent() as PlayerController
var sprite: AnimatedSprite2D
var pose: StringName = &"idle"
var _pose_time := 0.0
var _launch_left := 0.0
var _impact_left := 0.0
var _impact_facing := 1
var _landing_start := 0
var _landing_active := false
var _fall_phase := FallPhase.EARLY


func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "David"
	sprite.sprite_frames = FRAMES
	sprite.centered = false
	sprite.offset = Vector2(-20, -38)
	add_child(sprite)
	player.jump_started.connect(_on_launch)
	player.rebounded.connect(_on_impact)
	player.landed.connect(_on_land)
	player.movement_reset.connect(_on_reset)
	player.physics_stepped.connect(_on_step)
	_on_reset()


func _on_launch(_start: Vector2, _seconds: float, _strength: float, _velocity: Vector2) -> void:
	_launch_left = LAUNCH_SECONDS
	_impact_left = 0.0


func _on_impact(normal: Vector2, _impulse: Vector2, _kind: String) -> void:
	_impact_left = IMPACT_SECONDS
	_impact_facing = -1 if normal.x > 0.0 else 1
	_launch_left = 0.0


func _on_land(_at: Vector2) -> void:
	if player.state == PlayerController.State.LANDING:
		var impact_speed := -player.last_landing_velocity.dot(player.surface_normal)
		_landing_start = 0 if impact_speed >= HARD_LANDING_SPEED else 2
		_landing_active = true
		_pose_time = 0.0


func _on_reset() -> void:
	_landing_active = false
	_fall_phase = FallPhase.EARLY
	_launch_left = 0.0
	_impact_left = 0.0
	_pose_time = 0.0
	pose = &"idle"
	sprite.animation = pose
	sprite.frame = 0
	sprite.flip_h = player.facing_direction < 0
	queue_redraw()


func _on_step(delta: float) -> void:
	_update_fall_phase()
	var next := _select_pose()
	if next != &"land":
		_landing_active = false
	if next != pose:
		pose = next
		_pose_time = 0.0
		sprite.animation = pose
	var count := FRAMES.get_frame_count(pose)
	var frame := int(_pose_time * FRAMES.get_animation_speed(pose))
	match pose:
		&"charge":
			frame = mini(int(player.charge_fraction() * count), count - 1)
		&"launch":
			frame = int(_pose_time >= 0.016) + int(_pose_time >= 0.049)
		&"land":
			frame = mini(_landing_start + int(_pose_time / LAND_KEY_SECONDS), count - 1)
		_:
			frame = frame % count if FRAMES.get_animation_loop(pose) else mini(frame, count - 1)
	sprite.frame = frame
	var facing := _impact_facing if pose == &"impact" else player.facing_direction
	if pose in [&"slide", &"forced"] and absf(player.velocity.x) > 0.01:
		facing = 1 if player.velocity.x > 0.0 else -1
	sprite.flip_h = facing < 0
	var rate := absf(player.tangent_speed()) / maxf(player.physics_config.ground_speed, 1.0) if pose == &"walk" else 1.0
	_pose_time += delta * rate
	_launch_left = maxf(0.0, _launch_left - delta)
	_impact_left = maxf(0.0, _impact_left - delta)
	queue_redraw()


func _update_fall_phase() -> void:
	if player.state != PlayerController.State.FALLING:
		_fall_phase = FallPhase.EARLY
		return
	var descent := player.velocity.y
	if descent >= fast_fall_speed or (_fall_phase == FallPhase.FAST and descent >= fast_fall_speed - FALL_HYSTERESIS):
		_fall_phase = FallPhase.FAST
	elif descent >= normal_fall_speed or (_fall_phase != FallPhase.EARLY and descent >= normal_fall_speed - FALL_HYSTERESIS):
		_fall_phase = FallPhase.NORMAL
	else:
		_fall_phase = FallPhase.EARLY


func _select_pose() -> StringName:
	match player.state:
		PlayerController.State.FORCED_SLIDING:
			return &"forced"
		PlayerController.State.CHARGING:
			return &"charge"
		PlayerController.State.LANDING:
			if _landing_active:
				return &"land"
		PlayerController.State.RISING, PlayerController.State.FALLING:
			if _impact_left > 0.0:
				return &"impact"
			if _launch_left > 0.0 and player.state == PlayerController.State.RISING:
				return &"launch"
			if player.state == PlayerController.State.RISING:
				return &"apex" if player.velocity.y >= -APEX_SPEED else &"rise"
			match _fall_phase:
				FallPhase.FAST:
					return &"fall_fast"
				FallPhase.NORMAL:
					return &"fall"
				_:
					return &"fall_early"
	var speed := player.tangent_speed()
	var going_downhill := player.active_surface.gravity_slide and player.surface_normal.x * speed > 0.0
	if player.is_sliding() and (player.selected_direction * speed <= 0.0 or going_downhill):
		return &"slide"
	if _landing_active and absf(speed) <= 1.0:
		var remaining_keys := FRAMES.get_frame_count(&"land") - _landing_start
		if _pose_time < remaining_keys * LAND_KEY_SECONDS:
			return &"land"
	return &"walk" if absf(speed) > 1.0 else &"idle"


func _draw() -> void:
	if player.state == PlayerController.State.CHARGING:
		draw_rect(Rect2(-7, 3, roundf(14 * player.charge_fraction()), 1), Color("00d9e8"))
		var direction: int = player.selected_direction
		var tip: Vector2 = Vector2(direction * 14, -34 if direction == 0 else -11)
		draw_line(Vector2(0, -11), tip, Color("f5d547"))
		draw_rect(Rect2(tip - Vector2.ONE, Vector2(2, 2)), Color("f5d547"))
