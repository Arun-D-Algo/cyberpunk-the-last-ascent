extends Node2D
## Presentation derives poses from gameplay signals and fixed-tick state.

const FRAMES: SpriteFrames = preload("res://resources/visuals/david_frames.tres")
const LAUNCH_SECONDS := 2.0 / 30.0
const IMPACT_SECONDS := 0.10

@onready var player: PlayerController = get_parent() as PlayerController
var sprite: AnimatedSprite2D
var pose: StringName = &"idle"
var _pose_time := 0.0
var _launch_left := 0.0
var _impact_left := 0.0
var _impact_facing := 1


func _ready() -> void:
	sprite = AnimatedSprite2D.new()
	sprite.name = "David"
	sprite.sprite_frames = FRAMES
	sprite.centered = false
	sprite.offset = Vector2(-12, -38)
	add_child(sprite)
	player.jump_started.connect(_on_launch)
	player.rebounded.connect(_on_impact)
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


func _on_reset() -> void:
	_launch_left = 0.0
	_impact_left = 0.0
	_pose_time = 0.0
	pose = &"idle"
	sprite.animation = pose
	sprite.frame = 0
	sprite.flip_h = player.facing_direction < 0
	queue_redraw()


func _on_step(delta: float) -> void:
	var next := _select_pose()
	if next != pose:
		pose = next
		_pose_time = 0.0
		sprite.animation = pose
	var count := FRAMES.get_frame_count(pose)
	var frame := int(_pose_time * FRAMES.get_animation_speed(pose))
	match pose:
		&"charge":
			frame = mini(int(player.charge_fraction() * count), count - 1)
		&"land":
			var recovery := maxf(player.physics_config.landing_recovery_time, delta)
			frame = clampi(int((1.0 - player.landing_remaining / recovery) * count), 0, count - 1)
		_:
			frame = frame % count if FRAMES.get_animation_loop(pose) else mini(frame, count - 1)
	sprite.frame = frame
	var facing := _impact_facing if pose == &"impact" else player.facing_direction
	if pose == &"slide" and absf(player.velocity.x) > 0.01:
		facing = 1 if player.velocity.x > 0.0 else -1
	sprite.flip_h = facing < 0
	var rate := absf(player.tangent_speed()) / maxf(player.physics_config.ground_speed, 1.0) if pose == &"walk" else 1.0
	_pose_time += delta * rate
	_launch_left = maxf(0.0, _launch_left - delta)
	_impact_left = maxf(0.0, _impact_left - delta)
	queue_redraw()


func _select_pose() -> StringName:
	match player.state:
		PlayerController.State.CHARGING:
			return &"charge"
		PlayerController.State.LANDING:
			return &"land"
		PlayerController.State.RISING, PlayerController.State.FALLING:
			if _impact_left > 0.0:
				return &"impact"
			if _launch_left > 0.0 and player.state == PlayerController.State.RISING:
				return &"launch"
			return &"rise" if player.state == PlayerController.State.RISING else &"fall"
	var speed := player.tangent_speed()
	var going_downhill := player.active_surface.gravity_slide and player.surface_normal.x * speed > 0.0
	if player.is_sliding() and (player.selected_direction * speed <= 0.0 or going_downhill):
		return &"slide"
	return &"walk" if absf(speed) > 1.0 else &"idle"


func _draw() -> void:
	if player.state == PlayerController.State.CHARGING:
		draw_rect(Rect2(-7, 3, roundf(14 * player.charge_fraction()), 1), Color("00d9e8"))
		var direction: int = player.selected_direction
		var tip: Vector2 = Vector2(direction * 14, -34 if direction == 0 else -11)
		draw_line(Vector2(0, -11), tip, Color("f5d547"))
		draw_rect(Rect2(tip - Vector2.ONE, Vector2(2, 2)), Color("f5d547"))
