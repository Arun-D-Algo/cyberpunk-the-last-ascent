class_name LabSections
extends RefCounted
## Mechanics fixtures, not production levels. Coordinates match visible polygon boundaries.

const LABELS: PackedStringArray = ["CLASSIC", "A JUMPS", "B WALLS", "C CEILING", "D LEDGES", "E ICE", "F SLOPES", "G RAMPS", "H1 ICE", "H2 REBOUND", "H3 RUNOFF"]
const DESCRIPTIONS: PackedStringArray = ["CLASSIC / ORIGINAL ASCENT", "A / JUMP CALIBRATION", "B / STOP AND CONTROLLED REBOUND", "C / LOW CEILINGS AND CORNERS", "D / NARROW LEDGES AND RECOVERY", "E / ICE AND NORMAL TRANSITIONS", "F / SHALLOW AND STEEP SLOPES", "G / BRAKE THEN CHARGE ON RAMPS", "H1 / ICE APPROACH TO NARROW TARGET", "H2 / WALL REBOUND UNDER OVERHANG", "H3 / RAMP RUNOFF AND RECOVERY"]
const NORMAL: SurfacePhysicsProfile = preload("res://resources/surfaces/normal.tres")
const ICE: SurfacePhysicsProfile = preload("res://resources/surfaces/ice.tres")
const RAMP: SurfacePhysicsProfile = preload("res://resources/surfaces/sliding_ramp.tres")
const REBOUND: SurfacePhysicsProfile = preload("res://resources/surfaces/rebound_wall.tres")


static func box(parent: Node, id: String, rect: Rect2, profile: SurfacePhysicsProfile = NORMAL) -> PhysicsSurface:
	return polygon(parent, id, rect.position, PackedVector2Array([Vector2.ZERO, Vector2(rect.size.x, 0), rect.size, Vector2(0, rect.size.y)]), profile)


static func polygon(parent: Node, id: String, at: Vector2, points: PackedVector2Array, profile: SurfacePhysicsProfile = NORMAL) -> PhysicsSurface:
	var surface: PhysicsSurface = preload("res://scenes/environment/physics_surface.tscn").instantiate() as PhysicsSurface
	surface.name = id
	surface.position = at
	surface.polygon = points
	surface.surface_profile = profile
	parent.add_child(surface)
	return surface


static func populate(parent: Node, section: int) -> Vector2:
	box(parent, "Recovery", Rect2(16, 176 if section == 10 else 144, 288, 16))
	box(parent, "LeftBoundary", Rect2(8, -240, 8, 400))
	box(parent, "RightBoundary", Rect2(304, -240, 8, 400))
	match section:
		1: pass # Free launch lane and painted rulers, no hidden calibration collision.
		2:
			box(parent, "StopWall", Rect2(140, 44, 8, 60))
			box(parent, "ReboundWall", Rect2(272, 4, 8, 140), REBOUND)
			box(parent, "PassageRoof", Rect2(176, 94, 48, 8))
		3:
			box(parent, "LowCeiling", Rect2(64, 104, 64, 8))
			box(parent, "Overhang", Rect2(180, 64, 100, 8))
			box(parent, "CornerWall", Rect2(272, 64, 8, 80))
		4:
			box(parent, "Ledge24", Rect2(88, 112, 24, 8))
			box(parent, "Ledge16", Rect2(170, 64, 16, 8))
			box(parent, "Ledge8", Rect2(108, 12, 8, 8))
		5:
			box(parent, "NormalEntry", Rect2(16, 112, 80, 8))
			box(parent, "IceLane", Rect2(96, 112, 144, 8), ICE)
			box(parent, "NormalExit", Rect2(240, 112, 64, 8))
			return Vector2(45, 112)
		6:
			polygon(parent, "Shallow14", Vector2(56, 144), PackedVector2Array([Vector2(0, 0), Vector2(100, -24), Vector2(100, 16), Vector2(0, 16)]))
			box(parent, "ShallowTop", Rect2(156, 120, 20, 8))
			polygon(parent, "Steep34", Vector2(178, 144), PackedVector2Array([Vector2(0, 0), Vector2(70, -48), Vector2(70, 16), Vector2(0, 16)]))
			box(parent, "SteepTop", Rect2(248, 96, 40, 8))
		7:
			polygon(parent, "GravityRamp", Vector2(40, 80), PackedVector2Array([Vector2.ZERO, Vector2(180, 64), Vector2(180, 80), Vector2(0, 80)]), RAMP)
			box(parent, "BrakePad", Rect2(220, 144, 68, 16))
			return Vector2(55, 80 + 15 * 64.0 / 180.0)
		8:
			box(parent, "IceApproach", Rect2(72, 112, 56, 8), ICE)
			box(parent, "NarrowTarget", Rect2(158, 64, 24, 8))
			polygon(parent, "SlopeExit", Vector2(200, 64), PackedVector2Array([Vector2.ZERO, Vector2(70, -24), Vector2(70, 16), Vector2(0, 16)]))
			box(parent, "Overhang", Rect2(230, 0, 64, 8))
		9:
			box(parent, "ReboundWall", Rect2(200, 40, 8, 104), REBOUND)
			box(parent, "ReturnLedge", Rect2(164, 96, 28, 8))
			box(parent, "HighRoof", Rect2(142, 28, 68, 8))
		10:
			polygon(parent, "RunoffRamp", Vector2(40, 80), PackedVector2Array([Vector2.ZERO, Vector2(150, 56), Vector2(150, 64), Vector2(0, 64)]), RAMP)
			box(parent, "BrakePad", Rect2(190, 136, 40, 8))
			box(parent, "ExitTarget", Rect2(256, 104, 24, 8), ICE)
			# Catch a missed transfer below the route; do not pinch the runner against the ramp.
			var mover: PhysicsSurface = box(parent, "MovingRecovery", Rect2(230, 152, 48, 8))
			mover.motion_offset = Vector2(20, 0)
			mover.motion_period = 3.0
			return Vector2(55, 80 + 15 * 56.0 / 150.0)
	return Vector2(45, 144)
