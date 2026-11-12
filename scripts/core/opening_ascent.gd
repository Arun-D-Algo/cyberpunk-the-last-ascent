class_name OpeningAscent
extends TowerAscent
## Production opening shares the prototype's input, reset and pause behavior.

func _ready() -> void:
	route = OpeningRoute.entries()
	for child: Node in [player, camera, $Geometry, $Scenery]:
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	var top: float = route[-1].rect.position.y
	camera.world_bounds = Rect2(0, top - 140, 320, 144 - top + 320)
	_platform("Base", Rect2(16, 144, 288, 24), null)
	_platform("LeftWall", Rect2(8, top - 140, 8, 144 - top + 164), null)
	_platform("RightWall", Rect2(304, top - 140, 8, 144 - top + 164), null)
	for row: Dictionary in route:
		_platform(row.id, row.rect, null)
		if row.ricochet:
			var wall_x: float = row.previous_center + row.direction * 74.0
			if row.direction < 0:
				wall_x -= 8
			_platform(row.id + "_ReturnWall", Rect2(wall_x, row.rect.position.y - 56, 8, 40), null)
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

func _platform(id: String, rect: Rect2, _profile: SurfacePhysicsProfile) -> void:
	var machine := OpeningMachine.new()
	machine.name = id
	machine.position = rect.position
	machine.size = rect.size
	for row: Dictionary in route:
		if row.id == id:
			machine.kind = row.kind
			break
	$Geometry.add_child(machine)

func _build_backdrop(_top: float) -> void:
	var backdrop := OpeningBackdrop.new()
	backdrop.camera = camera
	backdrop.route = route
	$Scenery.add_child(backdrop)

func _update_zone(_delta: float) -> void:
	var next_zone := 0
	for index in [10, 22]:
		if player.position.y < route[index - 1].rect.position.y - 1:
			next_zone += 1
	player.world_height = 144 - player.position.y
	player.maximum_height = maxf(player.maximum_height, player.world_height)
	if next_zone != zone_index:
		zone_index = next_zone
		player.current_zone = OpeningRoute.TITLES[zone_index]
		zone_label.text = player.current_zone
