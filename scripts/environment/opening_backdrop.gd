class_name OpeningBackdrop
extends Node2D
## Finite authored architecture, camera-relative distant city and restrained fixtures.
var camera: Camera2D
var route: Array[Dictionary]
var far: Sprite2D
var mid: Node2D
var origin_y := 0.0

func _ready() -> void:
	z_index = -20
	origin_y = route[-1].rect.position.y - 240
	far = _sprite(preload("res://assets/environment/opening/city_depth.png"), Vector2(0, origin_y))
	far.show_behind_parent = true
	mid = Node2D.new()
	mid.show_behind_parent = true
	add_child(mid)
	var starts := [144.0, OpeningRoute.BOUNDARIES[0], OpeningRoute.BOUNDARIES[1]]
	var ends := [OpeningRoute.BOUNDARIES[0], OpeningRoute.BOUNDARIES[1], float(route[-1].rect.position.y) - 180]
	var textures := [preload("res://assets/environment/opening/facade.png"), preload("res://assets/environment/opening/ventilation.png"), preload("res://assets/environment/opening/transformers.png")]
	for zone in 3:
		var visual := Sprite2D.new()
		visual.texture = textures[zone]
		visual.centered = false
		visual.region_enabled = true
		visual.region_rect = Rect2(0, 0, 320, starts[zone] - ends[zone])
		visual.position = Vector2(0, ends[zone])
		mid.add_child(visual)
		for y in range(int(ends[zone]) + 50, int(starts[zone]) - 24, 128):
			for x in [38, 272]:
				_fixture("emergency_lamp", Vector2(x, y), zone * 0.7)
			if zone == 1:
				_fixture("fan", Vector2(76, y + 10), 0.5)
				_fixture("fan", Vector2(192, y + 10), 1.7)
				_fixture("steam", Vector2(35, y + 57), 2.0)
			if zone == 2:
				_fixture("monitor", Vector2(38, y + 24), 1.0)
				_fixture("spark", Vector2(266, y + 72), 0.0)
		_sign(OpeningRoute.TITLES[zone], Vector2(38, starts[zone] - 42), false)
		if zone > 0:
			_sign("ARASAKA / FACILITIES %02d" % (zone + 1), Vector2(38, starts[zone] - 30), false)
	_sign("ARASAKA", Vector2(150, 88), true)
	_sign("SECURITY IS PROGRESS", Vector2(150, 107), false)
	_sign("SERVICE / AUTHORIZED STAFF", Vector2(20, -181), false)
	_sign("INTAKE 04", Vector2(28, -368), false)
	_sign("EXHAUST / DOWN", Vector2(225, -492), false)
	_sign("PRESSURE BYPASS", Vector2(25, -537), false)
	_sign("CONDENSATE", Vector2(176, -967), false)
	_sign("HIGH VOLTAGE", Vector2(200, -1075), false)
	_sign("HEADER", Vector2(251, -1260), false)
	_sign("FAN RETURN", Vector2(23, -404), false)
	_sign("CHUTE ACCESS", Vector2(176, -394), false)
	_sign("SUBSTATION / ACCESS COMPLETE", Vector2(64, ends[2] + 133), false)
	# Recessed gates beneath the entrance canopy.
	mid.add_child(IndustrialArt.sprite("door", Vector2(24, 80), Color("637080")))
	mid.add_child(IndustrialArt.sprite("door", Vector2(248, 80), Color("637080")))
	queue_redraw()

func _sprite(texture: Texture2D, at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.position = at
	add_child(sprite)
	return sprite

func _fixture(kind: String, at: Vector2, phase: float) -> void:
	var fixture := IndustrialFixture.new()
	fixture.kind = kind
	fixture.position = at
	fixture.phase = phase
	fixture.modulate = Color(0.65, 0.65, 0.75)
	mid.add_child(fixture)

func _sign(words: String, at: Vector2, large: bool) -> void:
	var label := IndustrialArt.label(words, at, Color("f02d87"))
	if large:
		label.add_theme_font_size_override("font_size", 14)
	add_child(label)

func _process(_delta: float) -> void:
	if camera != null:
		far.position.y = origin_y + (camera.position.y - 54) * 0.06

func _draw() -> void:
	# Shaded equipment sits behind the solid roof outlines.
	_portal(Rect2(20, -156, 99, 112), Color("182d40"))
	_portal(Rect2(212, -207, 88, 112), Color("202d43"))
	_portal(Rect2(18, 55, 83, 88), Color("142639"))
	_portal(Rect2(249, 55, 52, 88), Color("263143"))
	_fan_bay(Rect2(19, -434, 144, 132))
	_portal(Rect2(145, -515, 28, 191), Color("223547"))
	_portal(Rect2(250, -608, 50, 157), Color("213245"))
	_transformer_bank(Rect2(20, -810, 95, 130))
	_transformer_bank(Rect2(173, -978, 123, 111))
	_transformer_bank(Rect2(75, -1150, 106, 151))
	_portal(Rect2(236, -1281, 64, 108), Color("263348"))
	for row: Dictionary in route:
		var box: Rect2 = row.rect
		var center := box.get_center()
		var anchor := 20.0 if center.x < 160 else 300.0
		if row.zone == 1 and center.x > 68 and center.x < 216:
			anchor = 158
		elif row.zone == 2 and box.position.y < -984 and box.position.y > -1151:
			anchor = 172 if center.x > 120 else 75
		var flange := Vector2(anchor, box.position.y + 25)
		draw_line(Vector2(center.x, box.end.y), flange, Color("283b50"), 4)
		draw_line(Vector2(center.x, box.end.y + 3), flange + Vector2(0, 7), Color("142334"), 2)
		draw_rect(Rect2(anchor - 3, box.position.y + 17, 6, 17), Color("384b5d"))
		draw_rect(Rect2(anchor - 1, box.position.y + 20, 2, 7), Color("a72f62"))
	# Original abstract three-branch corporate emblem and sign surround.
	draw_rect(Rect2(146, 84, 126, 32), Color("090e1c"))
	draw_rect(Rect2(146, 84, 126, 1), Color("f02d87"))
	draw_rect(Rect2(146, 115, 126, 1), Color("6f2747"))
	for x in [119, 129, 139]:
		draw_circle(Vector2(x, 94), 4, Color("f02d87"))
		draw_line(Vector2(x, 98), Vector2(129, 108), Color("f02d87"), 2)

func _portal(box: Rect2, color: Color) -> void:
	draw_rect(box, Color("0b1522"))
	for x in [box.position.x, box.end.x - 6]:
		draw_rect(Rect2(x, box.position.y, 6, box.size.y), color)
		draw_rect(Rect2(x, box.position.y, 1, box.size.y), color.lightened(0.12))
		for y in range(int(box.position.y) + 10, int(box.end.y), 17):
			draw_rect(Rect2(x + 2, y, 2, 3), Color("667384"))
	draw_rect(Rect2(box.position, Vector2(box.size.x, 6)), color)
	draw_line(box.position + Vector2(4, 8), box.position + Vector2(20, 24), color, 3)
	draw_line(box.position + Vector2(box.size.x - 4, 8), box.position + Vector2(box.size.x - 20, 24), color, 3)

func _fan_bay(box: Rect2) -> void:
	_portal(box, Color("2e4358"))
	var center := box.get_center() + Vector2(1, 2)
	draw_circle(center, 57, Color("304455"))
	draw_circle(center, 54, Color("101c29"))
	draw_circle(center, 49, Color("1b2d3e"))
	for angle in [0.3, 1.55, 2.8, 4.05, 5.3]:
		var tip := Vector2.from_angle(angle) * 45
		var trailing := Vector2.from_angle(angle - 0.55) * 29
		draw_colored_polygon(PackedVector2Array([center, center + tip, center + trailing]), Color("334a5c"))
	draw_circle(center, 10, Color("41596a"))
	draw_circle(center, 5, Color("182939"))

func _transformer_bank(box: Rect2) -> void:
	_portal(box, Color("344556"))
	draw_rect(box.grow(-7), Color("162532"))
	for x in range(int(box.position.x) + 12, int(box.end.x) - 9, 7):
		draw_rect(Rect2(x, box.position.y + 16, 3, box.size.y - 30), Color("2d4151"))
		draw_rect(Rect2(x, box.position.y + 16, 1, box.size.y - 30), Color("435563"))
	for y in [box.position.y + 10, box.end.y - 13]:
		draw_rect(Rect2(box.position.x + 7, y, box.size.x - 14, 4), Color("3b4653"))
		draw_rect(Rect2(box.position.x + 12, y + 1, 12, 1), Color("9d7050"))
