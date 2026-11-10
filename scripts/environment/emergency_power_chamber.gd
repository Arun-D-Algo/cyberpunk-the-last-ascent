class_name EmergencyPowerChamber
extends Node2D
## One composed visual slice. No campaign/region/checkpoint/hazard systems.

const PLATFORM: PackedScene = preload("res://scenes/environment/industrial_platform.tscn")
const FIXTURE: PackedScene = preload("res://scenes/environment/industrial_fixture.tscn")
const SPAWN: Vector2 = Vector2(45, 144)
const ROUTE: Array = [[72, 112, 48], [158, 64, 64], [78, 12, 48], [168, -40, 72], [94, -92, 24], [170, -144, 80]]
@onready var player: PlayerController = $Player
@onready var camera: LabCamera = $LabCamera
@onready var hud: LabHUD = $LabHUD
@onready var backdrop: ChamberBackdrop = $Backdrop
var fixtures: Array[IndustrialFixture] = []
var platforms: Array[IndustrialPlatform] = []
var refined_art: bool = true


func _ready() -> void:
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	camera.process_mode = Node.PROCESS_MODE_PAUSABLE
	$Environment.process_mode = Node.PROCESS_MODE_PAUSABLE
	backdrop.process_mode = Node.PROCESS_MODE_PAUSABLE
	player.position = SPAWN
	player.reset_physics_interpolation()
	player.z_index = 2
	camera.target = player
	camera.world_bounds = Rect2(0, -248, 320, 428)
	camera.reset_tracking()
	backdrop.camera = camera
	hud.bind_player(player)
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	refined_art = not arguments.has("--initial-art")
	$Atmosphere.visible = refined_art
	_add_platform(Vector2(16, 144), 288, false)
	for entry: Array in ROUTE:
		_add_platform(Vector2(entry[0], entry[1]), entry[2], refined_art)
	_boundary(Rect2(8, -240, 8, 400))
	_boundary(Rect2(304, -240, 8, 400))
	_boundary(Rect2(8, -240, 304, 8))
	_compose_environment()
	var title: Label = IndustrialArt.label("SUBLEVEL ZERO\nEMERGENCY POWER CHAMBER", Vector2(8, 30), Color("f5d547"))
	$Titles.add_child(title)
	var tween: Tween = create_tween()
	tween.tween_interval(2.2)
	tween.tween_property(title, "modulate:a", 0.0, 0.8)


func _add_platform(at: Vector2, width: int, warning: bool) -> void:
	var platform: IndustrialPlatform = PLATFORM.instantiate() as IndustrialPlatform
	platform.width = width
	platform.warning_edge = warning
	platform.position = at
	$Geometry.add_child(platform)
	platforms.append(platform)


func _boundary(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = rect.position
	body.collision_layer = 1
	body.collision_mask = 2
	var collider: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rect.size
	collider.shape = shape
	collider.position = rect.size / 2.0
	body.add_child(collider)
	$Geometry.add_child(body)


func _compose_environment() -> void:
	for y: int in range(-240, 145, 64):
		_prop("wall", Vector2(-16, y))
		_prop("wall", Vector2(304, y))
	_prop("door", Vector2(19, 80), Color("8c9eae"))
	_prop("console", Vector2(252, 111))
	_prop("actuator", Vector2(280, -26), Color("a6a9ad"))
	_prop("conduit", Vector2(20, -45), Color("657e8d"))
	_prop("damaged", Vector2(264, 28), Color("677b8c"))
	_prop("vent", Vector2(126, 117), Color("718293"))
	_prop("sign", Vector2(24, 43))
	_prop("panel", Vector2(258, -93), Color("8f9fa9"))
	_prop("pipe", Vector2(47, -174), Color("81929d"))
	_prop("cables", Vector2(131, -180), Color("6a7b89"))
	_prop("door", Vector2(186, -208))
	$Environment.add_child(IndustrialArt.label("AUX / 09", Vector2(199, -54), Color("6b8597")))
	$Environment.add_child(IndustrialArt.label("ISOLATED", Vector2(166, 136), Color("6b8597")))
	$Environment.add_child(IndustrialArt.label("SERVICE 00", Vector2(29, 57), Color("f5d547")))
	$Environment.add_child(IndustrialArt.label("EXIT / UPPER RELAY >", Vector2(170, -224), Color("f5d547")))
	_fixture("fan", Vector2(34, -101))
	_fixture("monitor", Vector2(260, -122))
	_fixture("cyan_lamp", Vector2(188, 18))
	_fixture("cyan_lamp", Vector2(194, -214))
	_fixture("warning_lamp", Vector2(32, 25))
	_fixture("emergency_lamp", Vector2(282, 82))
	_fixture("spark", Vector2(269, 36))
	_fixture("steam", Vector2(130, 101))
	if refined_art:
		# Refinement adds functional framing and removes competing background highlights.
		backdrop.mid_layer.modulate = Color("a7b1bd")
		_prop("cables", Vector2(173, 73), Color("718e9b"))
		_prop("railing", Vector2(210, -160), Color("667e8b"))
		_prop("railing", Vector2(172, -160), Color("667e8b"))
		_prop("beam", Vector2(288, -192), Color("9baab5"))
		$Environment.add_child(IndustrialArt.label("01 / ASCEND", Vector2(76, 127), Color("9bb0ba")))
		$Environment.add_child(IndustrialArt.label("HOLD SPACE / RELEASE", Vector2(22, 167), Color("a9c4cc")))
		$Environment.add_child(IndustrialArt.label("A/D + ARROWS", Vector2(22, 157), Color("6a8a9d")))
		_fixture("warning_lamp", Vector2(263, -185))
	else:
		backdrop.mid_layer.modulate = Color.WHITE


func _prop(part: String, at: Vector2, tint: Color = Color.WHITE) -> void:
	$Environment.add_child(IndustrialArt.sprite(part, at, tint))


func _fixture(kind: String, at: Vector2) -> void:
	var fixture: IndustrialFixture = FIXTURE.instantiate() as IndustrialFixture
	fixture.kind = kind
	fixture.position = at
	fixture.phase = float(fixtures.size()) * 0.37
	$Environment.add_child(fixture)
	fixtures.append(fixture)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("pause_game"):
		player.cancel_input_until_release()
		get_tree().paused = not get_tree().paused
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event.is_action_pressed("debug_reset_lab"):
		reset_chamber()
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event.is_action_pressed("debug_toggle_overlay"):
		hud.toggle_debug()
		get_viewport().set_input_as_handled()


func reset_chamber() -> void:
	get_tree().paused = false
	player.reset_movement(SPAWN)
	camera.reset_tracking()
	hud.refresh_debug()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		player.cancel_input_until_release()
		get_tree().paused = true
