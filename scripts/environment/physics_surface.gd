class_name PhysicsSurface
extends AnimatableBody2D
## Reusable solid polygon with a data profile; optional minimal moving-platform fixture.

@export var surface_profile: SurfacePhysicsProfile = preload("res://resources/surfaces/normal.tres")
@export var polygon: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(96, 0), Vector2(96, 16), Vector2(0, 16)])
@export var motion_offset: Vector2 = Vector2.ZERO
@export_range(0.2, 20.0) var motion_period: float = 4.0
var elapsed: float = 0.0
var origin: Vector2


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	process_physics_priority = -20
	origin = position
	if surface_profile == null or polygon.size() < 3 or not is_finite(motion_period) or motion_period <= 0.0 or not motion_offset.is_finite():
		push_error("PhysicsSurface requires a profile, polygon and finite positive motion period")
		set_physics_process(false)
		return
	var errors: PackedStringArray = surface_profile.validation_errors()
	if not errors.is_empty():
		push_error("Invalid surface: " + "; ".join(errors))
		set_physics_process(false)
		return
	set_meta("surface_physics", surface_profile)
	var shape: CollisionPolygon2D = CollisionPolygon2D.new()
	shape.polygon = polygon
	add_child(shape)
	queue_redraw()


## Use the authored face for tangent integration after the solver confirms support.
## Long edges can return slightly different normals at different contact positions.
func ramp_face_normal(contact: Vector2, solver_normal: Vector2) -> Vector2:
	var best_distance := 1.0
	var result := solver_normal
	for i in polygon.size():
		var start := to_global(polygon[i])
		var finish := to_global(polygon[(i + 1) % polygon.size()])
		var edge := finish - start
		if edge.is_zero_approx():
			continue
		var face := Vector2(edge.y, -edge.x).normalized()
		if face.y > 0.0:
			face = -face
		if face.dot(solver_normal) < 0.99:
			continue
		var closest := Geometry2D.get_closest_point_to_segment(contact, start, finish)
		var distance := contact.distance_squared_to(closest)
		if distance < best_distance:
			best_distance = distance
			result = face
	return result


func _physics_process(delta: float) -> void:
	if not motion_offset.is_zero_approx():
		elapsed += delta
		position = origin + motion_offset * sin(TAU * elapsed / motion_period)


func reset_motion() -> void:
	elapsed = 0.0
	position = origin
	reset_physics_interpolation()


func _draw() -> void:
	var color: Color = Color("34475a")
	var edge: Color = Color("a9c4cc")
	if has_meta("forced_slide"):
		color = Color("50303a")
		edge = Color("ff8f73")
	elif surface_profile.id == &"ice":
		color = Color("193d52")
		edge = Color("00d9e8")
	elif surface_profile.gravity_slide:
		color = Color("443729")
		edge = Color("f5d547")
	elif surface_profile.contact_response != null:
		edge = Color("f04775")
	draw_colored_polygon(polygon, color)
	draw_polyline(polygon + PackedVector2Array([polygon[0]]), edge, 1.0)
	# Repeated markings distinguish surfaces by pattern as well as color.
	if polygon.size() >= 2:
		for step: int in range(1, 8):
			var point: Vector2 = polygon[0].lerp(polygon[1], float(step) / 8.0)
			draw_line(point + Vector2(0, 3), point + Vector2(3, 6), edge, 1.0)
