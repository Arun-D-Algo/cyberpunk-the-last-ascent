class_name CollisionResponseProfile
extends Resource
## Contact response, separate from launch tuning. Static wall rebound cannot add energy.

enum WallMode { STOP, REBOUND }
@export var wall_mode: WallMode = WallMode.STOP
@export_range(0.0, 1.0) var wall_restitution: float = 0.25
@export_range(0.0, 100.0) var ceiling_downward_speed: float = 0.0 # px/s, also bounded by impact speed
@export_range(0.0, 1.0) var platform_velocity_inheritance: float = 0.0


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if wall_mode not in [WallMode.STOP, WallMode.REBOUND]:
		errors.append("Unknown wall mode")
	for property: String in ["wall_restitution", "platform_velocity_inheritance"]:
		var value: float = get(property)
		if not is_finite(value) or value < 0.0 or value > 1.0:
			errors.append(property + " must be finite in 0..1")
	if not is_finite(ceiling_downward_speed) or ceiling_downward_speed < 0.0 or ceiling_downward_speed > 100.0:
		errors.append("Ceiling downward speed must be in 0..100 px/s")
	return errors
