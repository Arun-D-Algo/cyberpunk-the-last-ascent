class_name SurfacePhysicsProfile
extends Resource
## Multipliers modify baseline walking only; no implicit jump impulse/gravity modifiers.

@export var id: StringName = &"normal"
@export_range(0.0, 2.0) var acceleration_scale: float = 1.0
@export_range(1.0, 4.0) var reverse_braking_scale: float = 1.0
@export_range(0.0, 2.0) var friction: float = 1.0 # released-input drag / baseline deceleration
@export_range(0.1, 2.0) var ground_speed_scale: float = 1.0
@export_range(0.0, 1.0) var landing_momentum_retention: float = 0.0
@export_range(1.0, 600.0) var maximum_slide_speed: float = 180.0 # px/s along floor tangent
@export_range(0.0, 5.0) var stop_speed: float = 0.5 # px/s; snap tiny residual drift to zero
@export_range(0.0, 1000.0) var charge_speed_limit: float = 1000.0 # normal allows immediate braking
@export var moving_charge_allowed: bool = false
@export_range(0.0, 1.0) var jump_momentum_retention: float = 0.0 # opt-in, only useful with moving charge
@export_group("Designated gravity ramps only")
@export var gravity_slide: bool = false
@export_range(0.0, 44.0) var minimum_slide_angle: float = 10.0 # degrees
@export_range(0.0, 1500.0) var downhill_acceleration: float = 260.0 # px/s² times sin(angle)
@export_range(0.0, 1.0) var input_influence: float = 1.0
@export var contact_response: CollisionResponseProfile # null uses player's response


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id.is_empty():
		errors.append("Surface needs a stable ID")
	var ranges: Dictionary = {"acceleration_scale": Vector2(0, 2), "friction": Vector2(0, 2),
		"ground_speed_scale": Vector2(0.1, 2), "landing_momentum_retention": Vector2(0, 1),
		"maximum_slide_speed": Vector2(1, 600), "stop_speed": Vector2(0, 5),
		"charge_speed_limit": Vector2(0, 1000), "jump_momentum_retention": Vector2(0, 1),
		"minimum_slide_angle": Vector2(0, 44), "downhill_acceleration": Vector2(0, 1500),
		"input_influence": Vector2(0, 1), "reverse_braking_scale": Vector2(1, 4)}
	for property: String in ranges:
		var value: float = get(property)
		if not is_finite(value) or value < ranges[property].x or value > ranges[property].y:
			errors.append("Invalid " + property)
	if contact_response != null:
		errors.append_array(contact_response.validation_errors())
	return errors
