class_name PlayerPhysicsConfig
extends Resource
## Authored tuning only. Never store a player's live charge/velocity in this Resource.

@export_group("Ground (pixels, seconds)")
@export_range(1.0, 200.0) var ground_speed: float = 65.0
@export_range(1.0, 4000.0) var ground_acceleration: float = 900.0
@export_range(1.0, 4000.0) var ground_deceleration: float = 1200.0
@export_group("Jump (seconds, pixels/second)")
@export_range(0.0, 1.0) var minimum_charge_time: float = 0.06
@export_range(0.01, 3.0) var maximum_charge_time: float = 0.75
@export_range(1.0, 600.0) var minimum_jump_impulse: float = 150.0
@export_range(1.0, 600.0) var maximum_jump_impulse: float = 360.0
@export_range(0.0, 400.0) var minimum_horizontal_impulse: float = 45.0
@export_range(0.0, 400.0) var maximum_horizontal_impulse: float = 165.0
@export var charge_curve: Curve
@export_group("Air and landing")
@export_range(1.0, 3000.0) var gravity: float = 900.0
@export_range(1.0, 1500.0) var maximum_fall_speed: float = 600.0
@export_range(0.0, 0.5) var landing_recovery_time: float = 0.06
@export_range(0.0, 1.0) var air_control_factor: float = 0.0


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	for property: String in ["ground_speed", "ground_acceleration", "ground_deceleration", "gravity", "maximum_fall_speed", "minimum_charge_time", "maximum_charge_time", "minimum_jump_impulse", "maximum_jump_impulse", "minimum_horizontal_impulse", "maximum_horizontal_impulse", "landing_recovery_time", "air_control_factor"]:
		var value: float = get(property)
		if not is_finite(value):
			errors.append(property + " must be finite")
	if ground_speed <= 0.0 or ground_acceleration <= 0.0 or ground_deceleration <= 0.0:
		errors.append("Ground speeds/accelerations must be positive")
	if gravity <= 0.0 or maximum_fall_speed <= 0.0:
		errors.append("Gravity and fall cap must be positive")
	if minimum_charge_time < 0.0 or maximum_charge_time <= minimum_charge_time:
		errors.append("Charge times require 0 <= minimum < maximum")
	if minimum_jump_impulse <= 0.0 or maximum_jump_impulse < minimum_jump_impulse:
		errors.append("Vertical impulses require 0 < minimum <= maximum")
	if minimum_horizontal_impulse < 0.0 or maximum_horizontal_impulse < minimum_horizontal_impulse:
		errors.append("Horizontal impulses require 0 <= minimum <= maximum")
	if landing_recovery_time < 0.0 or air_control_factor < 0.0 or air_control_factor > 1.0:
		errors.append("Invalid recovery or air-control range")
	if charge_curve != null:
		if charge_curve.point_count < 2:
			errors.append("Charge curve needs at least two points")
		else:
			if not is_equal_approx(charge_curve.get_point_position(0).x, 0.0) or not is_equal_approx(charge_curve.get_point_position(charge_curve.point_count - 1).x, 1.0):
				errors.append("Charge curve must span x=0 to x=1")
			var previous: float = -1.0
			for sample: int in range(101):
				var value: float = charge_curve.sample(float(sample) / 100.0)
				if not is_finite(value) or value < 0.0 or value > 1.0 or value < previous - 0.00001:
					errors.append("Charge curve must stay monotone within 0..1")
					break
				previous = value
			if not is_zero_approx(charge_curve.sample(0.0)) or not is_equal_approx(charge_curve.sample(1.0), 1.0):
				errors.append("Charge curve must map endpoints to 0 and 1")
	return errors
