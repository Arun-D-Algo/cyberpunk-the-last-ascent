class_name OpeningRoute
extends RefCounted
## World-pixel geometry in climbing order. Each row is an individual authored decision.
const TITLES := ["CORPORATE SERVICE", "VENTILATION GALLERIES", "TRANSFORMER HALL"]
const BOUNDARIES := [-203.0, -660.0]
const BASE := Rect2(16, 144, 288, 24)

# Name, roof rectangle, casing, architectural profile.
const PLAZA := [
	["SecurityBooth", Rect2(145, 124, 62, 20), "booth", "solid"],
	["BadgeReader", Rect2(216, 96, 35, 18), "cabinet", "stepped"],
	["GateCanopy", Rect2(259, 55, 45, 10), "canopy", "bracket"],
	["SignBeam", Rect2(162, 22, 51, 12), "beam", "bracket"],
	["SignCradle", Rect2(129, 4, 28, 8), "beam", "bracket"],
	["LoadingGantry", Rect2(65, -24, 60, 16), "cargo", "stepped"],
	["GlassLintel", Rect2(16, -60, 41, 12), "canopy", "bracket"],
	["InspectionPocket", Rect2(81, -82, 34, 9), "cabinet", "stepped"],
	["GateRail", Rect2(132, -116, 53, 12), "beam", "bracket"],
	["ServiceDuct", Rect2(191, -158, 73, 20), "duct", "stepped"],
	["ServiceGate", Rect2(237, -203, 53, 14), "canopy", "bracket"],
]
const VENTILATION := [
	["Manifold", Rect2(154, -235, 60, 18), "duct", "stepped"],
	["OuterDuct", Rect2(82, -283, 50, 20), "duct", "stepped"],
	["PipeSaddle", Rect2(39, -309, 33, 21), "duct", "slope"],
	["FanSill", Rect2(90, -349, 40, 12), "fan", "bracket"],
	["FanReturn", Rect2(69, -393, 38, 10), "fan", "bracket"],
	["FanRim", Rect2(22, -425, 42, 18), "fan", "stepped"],
	["PillarSill", Rect2(86, -460, 35, 12), "cabinet", "bracket"],
	["HousingRoof", Rect2(145, -505, 66, 22), "duct", "stepped"],
	["TransferBridge", Rect2(215, -527, 43, 12), "beam", "bracket"],
	["ValveCabinet", Rect2(259, -578, 45, 25), "cabinet", "stepped"],
	["PressureBypass", Rect2(90, -560, 43, 10), "fan", "bracket"],
	["ExitVent", Rect2(174, -621, 50, 16), "duct", "stepped"],
	["LiftDeck", Rect2(101, -660, 52, 12), "lift", "bracket"],
	["ChuteCatch", Rect2(173, -410, 48, 13), "duct", "bracket"],
	["FanColumn", Rect2(146, -429, 24, 93), "fan", "solid"],
]
const TRANSFORMER := [
	["RelayBox", Rect2(67, -696, 38, 23), "cabinet", "stepped"],
	["CoolingShelf", Rect2(16, -740, 41, 12), "transformer", "bracket"],
	["TowerFin", Rect2(77, -777, 31, 12), "transformer", "bracket"],
	["BusCabinet", Rect2(128, -825, 57, 24), "cabinet", "stepped"],
	["CopperBeam", Rect2(185, -872, 57, 12), "beam", "bracket"],
	["ElevatorShoe", Rect2(245, -901, 46, 16), "lift", "stepped"],
	["CondensationTray", Rect2(171, -946, 52, 14), "duct", "slick"],
	["CoilCrown", Rect2(102, -1001, 38, 24), "transformer", "stepped"],
	["BankTongue", Rect2(96, -1050, 31, 10), "transformer", "bracket"],
	["ReturnTongue", Rect2(118, -1097, 35, 10), "transformer", "bracket"],
	["CableRail", Rect2(174, -1143, 32, 13), "beam", "bracket"],
	["RadiatorHead", Rect2(213, -1191, 54, 25), "transformer", "stepped"],
	["HeaderPocket", Rect2(248, -1224, 56, 14), "lift", "bracket"],
	["Summit", Rect2(116, -1251, 55, 22), "transformer", "stepped"],
]

# Each pair is a validated jump. Direction 0 is reserved for vertical jumps.
# An optional fourth field gives the required number of side impacts.
const MAIN := [
	["Base", "SecurityBooth", 1], ["SecurityBooth", "BadgeReader", 1],
	["BadgeReader", "GateCanopy", 1], ["GateCanopy", "SignBeam", -1],
	["SignBeam", "LoadingGantry", -1], ["LoadingGantry", "GlassLintel", -1],
	["GlassLintel", "InspectionPocket", 1], ["InspectionPocket", "GateRail", 1],
	["GateRail", "ServiceDuct", 1], ["ServiceDuct", "ServiceGate", 1],
	["ServiceGate", "Manifold", -1], ["Manifold", "OuterDuct", -1],
	["OuterDuct", "PipeSaddle", -1], ["PipeSaddle", "FanSill", 1],
	["FanSill", "FanReturn", 1, 1], ["FanReturn", "FanRim", -1],
	["FanRim", "PillarSill", 1], ["PillarSill", "HousingRoof", 1],
	["HousingRoof", "TransferBridge", 1], ["TransferBridge", "ValveCabinet", 1, 1],
	["ValveCabinet", "ExitVent", -1], ["ExitVent", "LiftDeck", -1],
	["LiftDeck", "RelayBox", -1], ["RelayBox", "CoolingShelf", -1],
	["CoolingShelf", "TowerFin", 1], ["TowerFin", "BusCabinet", 1],
	["BusCabinet", "CopperBeam", 1], ["CopperBeam", "ElevatorShoe", 1],
	["ElevatorShoe", "CondensationTray", -1], ["CondensationTray", "CoilCrown", -1],
	["CoilCrown", "BankTongue", 1, 1], ["BankTongue", "ReturnTongue", -1, 1],
	["ReturnTongue", "CableRail", 1], ["CableRail", "RadiatorHead", 1, 1],
	["RadiatorHead", "HeaderPocket", 1], ["HeaderPocket", "Summit", -1],
]
const BRANCHES := [
	[["SignBeam", "SignCradle", -1], ["SignCradle", "LoadingGantry", -1]],
	[["HousingRoof", "PressureBypass", -1], ["PressureBypass", "ExitVent", 1]],
	[["RadiatorHead", "Summit", -1]],
	[["ChuteCatch", "FanColumn", -1], ["FanColumn", "PillarSill", -1]],
]
const STRUCTURES := [
	["PocketCeiling", Rect2(16, -137, 83, 11), "beam", "solid"],
	["RightReboundPier", Rect2(158, -1100, 14, 60), "transformer", "solid"],
	["LeftReboundPier", Rect2(61, -1150, 14, 100), "transformer", "solid"],
	["HeaderCeiling", Rect2(269, -1281, 35, 15), "lift", "solid"],
]

static func entries() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for zone in 3:
		for surface: Array in [PLAZA, VENTILATION, TRANSFORMER][zone]:
			rows.append({"id": surface[0], "rect": surface[1], "kind": surface[2],
				"shape": surface[3], "zone": zone})
	return rows
