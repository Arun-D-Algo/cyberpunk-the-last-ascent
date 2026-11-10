class_name TowerRoute
extends RefCounted
## Authored rhythm tables. One entry is one required landing, never a teleport.
const ZONE_NAMES: PackedStringArray = ["PUBLIC ACCESS", "COMMERCIAL ATRIUM", "RESTRICTED INFRASTRUCTURE", "MAINTENANCE ASCENT"]
const RISES: Array = [
	[32, 52, 44, 52, 48, 44, 52, 48, 52, 48, 44, 52, 48, 52, 52],
	[48, 48, 48, 52, 48, 48, 52, 48, 48, 48, 48, 52, 48, 48, 52],
	[48, 48, 48, 48, 48, 48, 52, 48, 48, 48, 48, 52, 48, 48, 52],
	[52, 56, 52, 60, 48, 56, 52, 60, 56, 48, 52, 60, 56, 52, 60]]
const WIDTHS: Array = [[64, 48, 64, 56], [48, 40, 56, 48], [64, 56, 48, 56], [32, 24, 40, 32]]

static func entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var y: float = 144.0
	var center: float = 110.0
	for zone: int in 4:
		for step: int in 15:
			var previous: float = center
			var ricochet: bool = step in [4, 9]
			var direction: int = 1 if previous < 160.0 else -1
			center = previous + direction * 52.0 if ricochet else ([104.0, 112.0, 120.0][step % 3] if previous > 160.0 else [200.0, 208.0, 216.0][step % 3])
			if step in [5, 10]:
				direction = -int(rows[-1].direction)
				center = clampf(previous + direction * 64.0, 64.0, 256.0)
			if step in [6, 11]:
				center = clampf(previous + direction * 96.0, 104.0, 216.0)
			y -= RISES[zone][step]
			var width: int = 28 if ricochet else WIDTHS[zone][step % 4]
			var profile: String = "ice" if zone >= 2 and step in [2, 7, 12] else ("ramp" if zone >= 2 and step == 6 else "normal")
			rows.append({"id": "Z%d_%02d" % [zone + 1, step + 1], "zone": zone, "step": step,
				"rect": Rect2(center - width / 2.0, y, width, 8), "profile": profile,
				"ricochet": ricochet, "direction": direction, "previous_center": previous})
	return rows
