class_name OpeningRoute
extends RefCounted
## Editable destinations. Full machinery bodies participate in reachability.
const TITLES := ["CORPORATE SERVICE", "VENTILATION GALLERIES", "TRANSFORMER HALL"]
const COUNTS := [10, 12, 14]
const RISES := [
	[16, 52, 44, 52, 48, 44, 52, 48, 52, 48],
	[44, 48, 44, 48, 48, 44, 52, 48, 44, 48, 48, 52],
	[48, 52, 48, 56, 48, 52, 56, 52, 48, 52, 56, 52, 56, 60]]
const WIDTHS := [[64, 56, 64, 56], [48, 40, 56, 48], [40, 32, 48, 40]]
const DEPTHS := {"booth": 16, "cargo": 16, "cabinet": 16, "transformer": 24}
const KINDS := [
	["booth", "cargo", "canopy", "beam", "cabinet"],
	["duct", "fan", "beam", "duct", "cabinet"],
	["transformer", "cabinet", "beam", "transformer", "lift"]]

static func entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var y := 144.0
	var center := 110.0
	for zone in 3:
		for step in COUNTS[zone]:
			var previous := center
			var bank: bool = zone > 0 and step in [4, 9]
			var direction := 1 if center < 160 else -1
			var centers := [104.0, 112.0, 120.0] if previous > 160 else [200.0, 208.0, 216.0]
			center = previous + direction * 52 if bank else centers[step % 3]
			if zone > 0 and step in [5, 10]:
				direction = -int(rows[-1].direction)
				center = clampf(previous + direction * 64, 64, 256)
			if zone > 0 and step in [6, 11]:
				center = clampf(previous + direction * 96, 104, 216)
			y -= RISES[zone][step]
			var width: int = 32 if bank else WIDTHS[zone][step % 4]
			var kind: String = KINDS[zone][step % 5]
			var depth: int = 8 if bank else DEPTHS.get(kind, 12)
			rows.append({"id": "A%d_%02d" % [zone + 1, step + 1], "zone": zone, "step": step,
				"rect": Rect2(center - width / 2.0, y, width, depth), "profile": "normal",
				"ricochet": bank, "direction": direction, "previous_center": previous, "kind": kind})
	return rows
