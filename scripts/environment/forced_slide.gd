class_name ForcedSlide
extends Node2D
## Static downhill polyline. The final point marks the start of the runout.

@export var points := PackedVector2Array([Vector2.ZERO, Vector2(128, 56)])
@export_enum("Right:1", "Left:-1") var direction: int = 1
@export var entry_speed := 58.0
@export var minimum_speed := 45.0
@export var acceleration := 145.0
@export var maximum_speed := 156.0
@export var exit_velocity := Vector2(74, 0) # X is in the downhill direction.
@export var exit_clearance := 6.0
@export_range(0.0, 0.2) var transition_seconds := 0.0
var valid := false

func _ready() -> void:
	if not _configuration_valid():
		push_error("Invalid forced slide configuration at " + str(get_path()))
		return
	valid = true
	var base_y := points[-1].y + 10.0
	for index in range(1, points.size()):
		var start := points[index - 1]
		var finish := points[index]
		var segment: PhysicsSurface = preload("res://scenes/environment/physics_surface.tscn").instantiate()
		segment.name = "SlideFace%d" % index
		segment.polygon = PackedVector2Array([start, finish, Vector2(finish.x, base_y), Vector2(start.x, base_y)])
		segment.set_meta("forced_slide", self)
		add_child(segment)

func _configuration_valid() -> bool:
	if points.size() < 2 or absi(direction) != 1 or global_transform.x != Vector2.RIGHT or global_transform.y != Vector2.DOWN:
		return false
	for value in [entry_speed, minimum_speed, acceleration, maximum_speed, exit_clearance, transition_seconds]:
		if not is_finite(value) or value < 0.0:
			return false
	if minimum_speed < 5.0 or entry_speed < minimum_speed or maximum_speed < entry_speed or not exit_velocity.is_finite() or exit_velocity.x <= 0.0 or exit_clearance < 5.0:
		return false
	for index in range(1, points.size()):
		var edge := points[index] - points[index - 1]
		if not edge.is_finite() or edge.x * direction <= 0.0 or edge.y <= 0.0 or edge.y >= absf(edge.x):
			return false
	return true

func passed_exit(world_x: float) -> bool:
	return (world_x - to_global(points[-1]).x) * direction >= exit_clearance

func tangent_at(world_x: float) -> Vector2:
	var local_x := world_x - global_position.x
	for index in range(1, points.size()):
		if (local_x - points[index].x) * direction < 0.0:
			return (points[index] - points[index - 1]).normalized()
	return Vector2(direction, 0)
