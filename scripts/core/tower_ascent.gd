class_name TowerAscent
extends Node2D

const SPAWN: Vector2 = Vector2(110, 144)
const ICE: SurfacePhysicsProfile = preload("res://resources/surfaces/ice.tres")
var route: Array[Dictionary] = TowerRoute.entries()
var themes: Array[FloorTheme] = []
var zone_index: int = -1
var zone_label: Label
@onready var player: PlayerController = $Player
@onready var camera: LabCamera = $LabCamera
@onready var hud: LabHUD = $LabHUD

func _ready() -> void:
	for child: Node in [player, camera, $Geometry]:
		child.process_mode = Node.PROCESS_MODE_PAUSABLE
	themes.assign([preload("res://resources/floors/zone_1.tres"), preload("res://resources/floors/zone_2.tres"), preload("res://resources/floors/zone_3.tres"), preload("res://resources/floors/zone_4.tres")])
	var top: float = route[-1].rect.position.y
	camera.world_bounds = Rect2(0, top - 140, 320, 144 - top + 320)
	_platform("Base", Rect2(16, 144, 288, 8), null)
	LabSections.box($Geometry, "LeftWall", Rect2(8, top - 140, 8, 144 - top + 156))
	LabSections.box($Geometry, "RightWall", Rect2(304, top - 140, 8, 144 - top + 156))
	for row: Dictionary in route:
		if row.profile == "ramp":
			var width: float = row.rect.size.x
			LabSections.polygon($Geometry, row.id, row.rect.position, PackedVector2Array([Vector2(0, -8), Vector2(24, 0), Vector2(width, 0), Vector2(width, 8), Vector2(0, 8)]), preload("res://resources/surfaces/controlled_ramp.tres"))
		else:
			_platform(row.id, row.rect, ICE if row.profile == "ice" else null)
		if row.ricochet:
			var wall_x: float = row.previous_center + row.direction * 74.0
			if row.direction < 0:
				wall_x -= 8.0
			# Tall raised pads expose a vertical side; their top can also be landed on.
			LabSections.box($Geometry, row.id + "_ReturnWall", Rect2(wall_x, row.rect.position.y - 56, 8, 40))
		var mark: Label = IndustrialArt.label("%02d" % (route.find(row) + 1), row.rect.position + Vector2(0, 10), themes[row.zone].accent)
		$Scenery.add_child(mark)
	_build_backdrop(top)
	player.position = SPAWN
	player.reset_physics_interpolation()
	camera.target = player
	camera.reset_tracking()
	hud.bind_player(player)
	zone_label = IndustrialArt.label("", Vector2(8, 27), Color.WHITE)
	hud.add_child(zone_label)
	player.physics_stepped.connect(_update_zone)
	_update_zone(0)

func _platform(id: String, rect: Rect2, profile: SurfacePhysicsProfile) -> void:
	var platform: IndustrialPlatform = preload("res://scenes/environment/industrial_platform.tscn").instantiate()
	platform.name = id
	platform.position = rect.position
	platform.width = int(rect.size.x)
	platform.warning_edge = true
	platform.surface_profile = profile
	if profile != null:
		platform.modulate = Color("7edfff")
	$Geometry.add_child(platform)

func _build_backdrop(top: float) -> void:
	# Original lossless shaft art, finite repeated panels; no streaming needed for 60 pads.
	for y: int in range(int(top) - 240, 512, 512):
		var far: Sprite2D = Sprite2D.new()
		far.texture = preload("res://assets/environment/backgrounds/shaft_far.png")
		far.centered = false
		far.z_index = -2
		far.position = Vector2(0, y)
		$Scenery.add_child(far)
		var mid: Sprite2D = Sprite2D.new()
		mid.texture = preload("res://assets/environment/backgrounds/shaft_mid.png")
		mid.centered = false
		mid.z_index = -1
		mid.position = Vector2(0, y)
		$Scenery.add_child(mid)
	for y: int in range(int(top) - 64, 145, 64):
		$Scenery.add_child(IndustrialArt.sprite("wall", Vector2(-16, y)))
		$Scenery.add_child(IndustrialArt.sprite("wall", Vector2(304, y)))
	for index: int in 4:
		var boundary: float = 144.0 if index == 0 else route[index * 15 - 1].rect.position.y
		$Scenery.add_child(IndustrialArt.label("FLOOR %02d / %s" % [index + 1, themes[index].title], Vector2(20, boundary - 25), themes[index].accent))
	$Scenery.add_child(IndustrialArt.label("PROTOTYPE SUMMIT", Vector2(80, top - 40), themes[3].accent))

func _update_zone(_delta: float) -> void:
	var next_zone: int = 0
	for index: int in range(1, 4):
		if player.position.y < route[index * 15 - 1].rect.position.y - 1.0:
			next_zone = index
	player.world_height = 144.0 - player.position.y
	player.maximum_height = maxf(player.maximum_height, player.world_height)
	if next_zone != zone_index:
		zone_index = next_zone
		player.current_zone = "%02d %s" % [zone_index + 1, themes[zone_index].title]
		zone_label.text = player.current_zone
		zone_label.modulate = themes[zone_index].accent
		$Scenery.modulate = themes[zone_index].backdrop_tint

func toggle_pause() -> void:
	player.cancel_input_until_release()
	get_tree().paused = not get_tree().paused

func reset_ascent() -> void:
	get_tree().paused = false
	player.reset_movement(SPAWN)
	player.maximum_height = 0.0
	camera.reset_tracking()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("pause_game"):
		toggle_pause()
	elif OS.is_debug_build() and event.is_action_pressed("debug_reset_lab"):
		reset_ascent()
	elif OS.is_debug_build() and event.is_action_pressed("debug_toggle_overlay"):
		hud.toggle_debug()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		player.cancel_input_until_release()
		get_tree().paused = true
