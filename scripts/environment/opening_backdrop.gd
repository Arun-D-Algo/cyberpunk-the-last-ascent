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
	var starts := [144.0, float(route[9].rect.position.y), float(route[21].rect.position.y)]
	var ends := [float(route[9].rect.position.y), float(route[21].rect.position.y), float(route[-1].rect.position.y) - 180]
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
	_sign("SERVICE / AUTHORIZED STAFF", Vector2(54, -300), false)
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
	# Recessed wall attachments show each casing's connection to the building.
	for row: Dictionary in route:
		var box: Rect2 = row.rect
		var center := box.get_center()
		var wall_x := 20.0 if center.x < 160 else 300.0
		var end := Vector2(wall_x, box.position.y + 32)
		draw_line(Vector2(center.x, box.end.y), end, Color("243349"), 3)
		draw_line(Vector2(center.x, box.end.y + 2), end + Vector2(0, 8), Color("142334"), 2)
		draw_rect(Rect2(wall_x - 3, box.position.y + 25, 6, 18), Color("334156"))
		# A narrow emissive strip and local spill identify attached service equipment.
		for band in range(3, 0, -1):
			draw_rect(Rect2(wall_x - 7 - band * 2, box.position.y + 20 - band * 2, 14 + band * 4, 28 + band * 4), Color(0.94, 0.18, 0.53, 0.018))
		draw_rect(Rect2(wall_x - 1, box.position.y + 29, 2, 8), Color("a72f62"))
	# Original abstract three-branch corporate emblem and sign surround.
	draw_rect(Rect2(146, 84, 126, 32), Color("090e1c"))
	draw_rect(Rect2(146, 84, 126, 1), Color("f02d87"))
	draw_rect(Rect2(146, 115, 126, 1), Color("6f2747"))
	for x in [119, 129, 139]:
		draw_circle(Vector2(x, 94), 4, Color("f02d87"))
		draw_line(Vector2(x, 98), Vector2(129, 108), Color("f02d87"), 2)
