class_name OpeningAscent
extends TowerAscent
## Production opening shares the prototype's input, reset and pause behavior.
var surfaces: Dictionary = {}

func _ready() -> void:
	route = OpeningRoute.entries()
	for child: Node in [player, camera, $Geometry, $Scenery]:
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	var top: float = route[-1].rect.position.y
	camera.world_bounds = Rect2(0, top - 140, 320, 144 - top + 320)
	_machine("Base", OpeningRoute.BASE, "beam", "solid")
	_machine("LeftWall", Rect2(8, top - 140, 8, 144 - top + 164), "beam", "solid")
	_machine("RightWall", Rect2(304, top - 140, 8, 144 - top + 164), "beam", "solid")
	for row: Dictionary in route:
		_machine(row.id, row.rect, row.kind, row.shape)
	for structure: Array in OpeningRoute.STRUCTURES:
		_machine(structure[0], structure[1], structure[2], structure[3])
	var chute := ForcedSlide.new()
	chute.name = "ExhaustChute"
	chute.position = Vector2(292, -472)
	chute.points = PackedVector2Array([Vector2.ZERO, Vector2(-70, 33), Vector2(-87, 45)])
	chute.direction = -1
	$Geometry.add_child(chute)
	_build_backdrop(top)
	player.position = SPAWN
	player.reset_physics_interpolation()
	camera.target = player
	camera.reset_tracking()
	hud.bind_player(player)
	zone_label = IndustrialArt.label("", Vector2(8, 27), Color("f02d87"))
	hud.add_child(zone_label)
	player.physics_stepped.connect(_update_zone)
	_update_zone(0)

func _machine(id: String, rect: Rect2, kind: String, profile: String) -> void:
	var machine := OpeningMachine.new()
	machine.name = id
	machine.position = rect.position
	machine.size = rect.size
	machine.kind = kind
	machine.profile = profile
	surfaces[id] = rect
	$Geometry.add_child(machine)

func _build_backdrop(_top: float) -> void:
	var backdrop := OpeningBackdrop.new()
	backdrop.camera = camera
	backdrop.route = route
	$Scenery.add_child(backdrop)

func _update_zone(_delta: float) -> void:
	var next_zone := 0
	for boundary: float in OpeningRoute.BOUNDARIES:
		if player.position.y < boundary - 1:
			next_zone += 1
	player.world_height = 144 - player.position.y
	player.maximum_height = maxf(player.maximum_height, player.world_height)
	if next_zone != zone_index:
		zone_index = next_zone
		player.current_zone = OpeningRoute.TITLES[zone_index]
		zone_label.text = player.current_zone
