class_name JumpPhysics
extends RefCounted
## Pure calculations shared by controller, HUD normalization and tests.


static func direction(left: bool, right: bool) -> int:
	return int(right) - int(left)


static func normalized_charge(seconds: float, config: PlayerPhysicsConfig) -> float:
	return clampf((seconds - config.minimum_charge_time) / (config.maximum_charge_time - config.minimum_charge_time), 0.0, 1.0)


static func strength(seconds: float, config: PlayerPhysicsConfig) -> float:
	var charge: float = normalized_charge(seconds, config)
	return clampf(config.charge_curve.sample(charge), 0.0, 1.0) if config.charge_curve != null else charge


static func launch_velocity(seconds: float, selected_direction: int, config: PlayerPhysicsConfig) -> Vector2:
	var effective: float = strength(seconds, config)
	return Vector2(
		clampi(selected_direction, -1, 1) * lerpf(config.minimum_horizontal_impulse, config.maximum_horizontal_impulse, effective),
		-lerpf(config.minimum_jump_impulse, config.maximum_jump_impulse, effective)
	)
