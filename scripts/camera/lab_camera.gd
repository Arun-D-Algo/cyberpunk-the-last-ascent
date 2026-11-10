class_name LabCamera
extends Camera2D

@export var target: Node2D
@export var vertical_dead_zone: float = 10.0
@export var tracking_speed: float = 14.0
@export var look_distance: float = 42.0
@export var world_bounds: Rect2 = Rect2(0, -590, 320, 770)
var _center: Vector2 = Vector2(160, 54)
var _look: float = 0.0


func _ready() -> void:
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = false
	process_physics_priority = 10
	reset_tracking()


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var look_input: int = JumpPhysics.direction(Input.is_action_pressed("look_up"), Input.is_action_pressed("look_down"))
	_look = lerpf(_look, look_input * look_distance, 1.0 - exp(-tracking_speed * delta))
	var desired_y: float = target.global_position.y - 52.0
	var gap: float = desired_y - _center.y
	if absf(gap) > vertical_dead_zone:
		_center.y = lerpf(_center.y, desired_y - signf(gap) * vertical_dead_zone, 1.0 - exp(-tracking_speed * delta))
	_place_camera()


func reset_tracking() -> void:
	if target == null:
		return
	_look = 0.0
	_center = Vector2(world_bounds.get_center().x, target.global_position.y - 52.0)
	_place_camera()
	reset_physics_interpolation()
	reset_smoothing()
	force_update_scroll()


func _place_camera() -> void:
	# Fractional transforms render at physical window resolution with nearest textures.
	var center_y: float = clampf(_center.y + _look, world_bounds.position.y + 90.0, world_bounds.end.y - 90.0)
	if target != null:
		# Keep feet above the bottom edge and the silhouette below the HUD, even in fast falls/look.
		center_y = clampf(center_y, target.global_position.y - 84.0, target.global_position.y + 40.0)
	global_position = Vector2(_center.x, center_y)
