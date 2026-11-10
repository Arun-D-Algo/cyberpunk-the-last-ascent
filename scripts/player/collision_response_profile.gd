class_name CollisionResponseProfile
extends Resource
## Contact response, separate from launch tuning. Static wall rebound cannot add energy.

enum WallMode { STOP, REBOUND }
@export var wall_mode: WallMode = WallMode.REBOUND
@export_range(0.0, 1.0) var wall_restitution: float = 0.6
@export_range(0.0, 200.0) var minimum_impact_speed: float = 30.0
## Once per jump, rising only. Redirect energy rather than adding it.
@export_range(0.0, 1.0) var diagonal_energy_fraction: float = 0.0
@export_range(0.0, 360.0) var diagonal_vertical_limit: float = 300.0
@export_range(0.0, 100.0) var ceiling_downward_speed: float = 0.0 # px/s, also bounded by impact speed
@export_range(0.0, 1.0) var top_restitution: float = 0.0 # optional special pads only
@export_range(0.0, 1.0) var platform_velocity_inheritance: float = 0.0


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if wall_mode not in [WallMode.STOP, WallMode.REBOUND]:
		errors.append("Unknown wall mode")
	for property: String in ["wall_restitution", "platform_velocity_inheritance", "diagonal_energy_fraction", "top_restitution"]:
		var value: float = get(property)
		if not is_finite(value) or value < 0.0 or value > 1.0:
			errors.append(property + " must be finite in 0..1")
	if not is_finite(ceiling_downward_speed) or ceiling_downward_speed < 0.0 or ceiling_downward_speed > 100.0:
		errors.append("Ceiling downward speed must be in 0..100 px/s")
	for property: String in ["minimum_impact_speed", "diagonal_vertical_limit"]:
		var value: float = get(property)
		var limit: float = 200.0 if property == "minimum_impact_speed" else 360.0
		if not is_finite(value) or value < 0.0 or value > limit:
			errors.append("Invalid " + property)
	return errors
