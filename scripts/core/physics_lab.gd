class_name PhysicsLab
extends Node2D
## Debug lab only: no campaign, save, region or retry-boss responsibilities.

const SPAWN: Vector2 = Vector2(45, 144)
# [id, left, surface_y, width]. Rectangles are solid, never one-way.
const PLATFORMS: Array = [
	["floor", 16, 144, 288],
	["01 / TAP", 64, 128, 48],
	["02 / LOW", 136, 96, 58],
	["03 / CLIMB", 56, 44, 58],
	["04 / RECOVER", 154, -8, 88],
	["05 / CLIMB", 70, -60, 58],
	["06 / EDGE", 160, -116, 44],
	["07 / NARROW", 88, -168, 24],
	["08 / RECOVER", 166, -220, 78],
	["09 / CLIMB", 68, -276, 64],
	["10 / CLIMB", 164, -332, 48],
	["11 / CLIMB", 82, -388, 64],
	["12 / SUMMIT", 170, -444, 80],
	["ALT / VERTICAL", 254, 88, 34],
	["ALT / LONG GAP", 22, -8, 28],
]

@onready var player: PlayerController = $Player
@onready var camera: LabCamera = $LabCamera
@onready var hud: LabHUD = $LabHUD
var section_index: int = 0
var section_spawn: Vector2 = SPAWN
var section_selector: OptionButton
var section_title: Label
var diagnostics: LabDiagnostics


func _ready() -> void:
	# The root can receive Esc while paused; simulation children remain pausable.
	for node: Node in [player, camera, $Geometry]:
		node.process_mode = Node.PROCESS_MODE_PAUSABLE
	for platform: Array in PLATFORMS:
		_add_solid(platform[0], Rect2(platform[1], platform[2], platform[3], 8))
	_add_solid("LeftWall", Rect2(8, -560, 8, 720))
	_add_solid("RightWall", Rect2(304, -560, 8, 720))
	_add_solid("CeilingTest", Rect2(224, 78, 26, 8))
	_add_solid("TopBoundary", Rect2(8, -552, 304, 8))
	player.position = SPAWN
	camera.target = player
	camera.reset_tracking()
	hud.bind_player(player)
	_setup_section_controls()
	queue_redraw()


func _setup_section_controls() -> void:
	section_selector = OptionButton.new()
	section_selector.theme = preload("res://resources/ui/industrial_theme.tres")
	section_selector.position = Vector2(230, 0)
	section_selector.size.x = 90
	section_selector.focus_mode = Control.FOCUS_NONE
	for label: String in LabSections.LABELS:
		section_selector.add_item(label)
	section_selector.item_selected.connect(select_section)
	hud.add_child(section_selector)
	section_title = Label.new()
	section_title.theme = section_selector.theme
	section_title.position = Vector2(6, 27)
	section_title.text = LabSections.DESCRIPTIONS[0]
	section_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(section_title)
	diagnostics = preload("res://scripts/ui/lab_diagnostics.gd").new() as LabDiagnostics
	diagnostics.player = player
	diagnostics.z_index = 5
	add_child(diagnostics)
	var trace_button: CheckButton = CheckButton.new()
	trace_button.theme = section_selector.theme
	trace_button.text = "TRACE"
	trace_button.position = Vector2(265, 20)
	trace_button.focus_mode = Control.FOCUS_NONE
	trace_button.toggled.connect(diagnostics.set_enabled)
	hud.add_child(trace_button)


func select_section(index: int) -> void:
	if index < 0 or index >= LabSections.LABELS.size():
		push_error("Invalid Physics Lab section")
		return
	call_deferred("_build_section", index)


func _build_section(index: int) -> void:
	section_index = index
	for child: Node in $Geometry.get_children():
		$Geometry.remove_child(child)
		child.queue_free()
	if index == 0:
		for platform: Array in PLATFORMS:
			_add_solid(platform[0], Rect2(platform[1], platform[2], platform[3], 8))
		_add_solid("LeftWall", Rect2(8, -560, 8, 720))
		_add_solid("RightWall", Rect2(304, -560, 8, 720))
		_add_solid("CeilingTest", Rect2(224, 78, 26, 8))
		_add_solid("TopBoundary", Rect2(8, -552, 304, 8))
		section_spawn = SPAWN
	else:
		section_spawn = LabSections.populate($Geometry, index)
	section_selector.select(index)
	section_title.text = LabSections.DESCRIPTIONS[index]
	reset_lab()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("pause_game"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event.is_action_pressed("debug_reset_lab"):
		reset_lab()
		get_viewport().set_input_as_handled()
	elif OS.is_debug_build() and event.is_action_pressed("debug_toggle_overlay"):
		hud.toggle_debug()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		player.cancel_input_until_release()
		get_tree().paused = true


func toggle_pause() -> void:
	player.cancel_input_until_release()
	get_tree().paused = not get_tree().paused


func reset_lab() -> void:
	get_tree().paused = false
	for child: Node in $Geometry.get_children():
		if child is PhysicsSurface:
			child.reset_motion()
	player.reset_movement(section_spawn)
	camera.reset_tracking()
	hud.refresh_debug()


func _add_solid(id: String, rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.name = id.replace(" / ", "_")
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


func _draw() -> void:
	draw_rect(Rect2(0, -560, 320, 740), Color("080f20"))
	for y: int in range(-544, 145, 16):
		draw_line(Vector2(16, y), Vector2(304, y), Color("101d31"))
	for x: int in range(16, 305, 16):
		draw_line(Vector2(x, -544), Vector2(x, 144), Color("10182a"))
	if section_index != 0:
		if section_index == 1:
			for entry: Array in [[11, "MIN"], [21, "25"], [34, "50"], [51, "75"], [69, "MAX"]]:
				var y: float = 144.0 - entry[0]
				draw_line(Vector2(274, y), Vector2(290, y), Color("f5d547"))
				draw_string(ThemeDB.fallback_font, Vector2(246, y), entry[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("a9c4cc"))
		draw_string(ThemeDB.fallback_font, Vector2(22, 168), "F6 RESET / SELECT ANY SECTION ABOVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("a9c4cc"))
		return
	for platform: Array in PLATFORMS:
		var rect: Rect2 = Rect2(platform[1], platform[2], platform[3], 8)
		draw_rect(rect, Color("243c55"))
		draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color("60dce2"), 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(1, 16), platform[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("9cacc3"))
	for wall: Rect2 in [Rect2(8, -560, 8, 720), Rect2(304, -560, 8, 720), Rect2(224, 78, 26, 8), Rect2(8, -552, 304, 8)]:
		draw_rect(wall, Color("36516c"))
	draw_string(ThemeDB.fallback_font, Vector2(22, 116), "A/D + ARROWS   HOLD / RELEASE SPACE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("e6cb70"))
	draw_string(ThemeDB.fallback_font, Vector2(179, -461), "LAB COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("e6cb70"))
