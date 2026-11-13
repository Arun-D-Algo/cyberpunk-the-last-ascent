class_name OpeningMachine
extends StaticBody2D
## Render and collision share the complete casing dimensions.
const ATLAS: Texture2D = preload("res://assets/environment/opening/machinery.png")
const TYPES := ["booth", "cargo", "canopy", "beam", "cabinet", "duct", "fan", "transformer", "lift"]
var size := Vector2(64, 16)
var kind := "beam"
var profile := "solid"
var silhouette: PackedVector2Array

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	if profile in ["stepped", "bracket", "slope"]:
		silhouette = _outline()
		var polygon := CollisionPolygon2D.new()
		polygon.polygon = silhouette
		add_child(polygon)
		return
	if profile == "slick":
		set_meta("surface_physics", preload("res://resources/surfaces/ice.tres"))
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	collider.position = size / 2
	add_child(collider)
	if profile == "slick":
		return
	if size.x == 8 and size.y > 64:
		var wall := Sprite2D.new()
		wall.texture = preload("res://assets/environment/opening/wall.png")
		wall.centered = false
		wall.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		wall.region_enabled = true
		wall.region_rect = Rect2(Vector2.ZERO, size)
		add_child(wall)
		return
	for y in range(0, int(size.y), 16):
		for x in range(0, int(size.x), 64):
			var visual := Sprite2D.new()
			var texture := AtlasTexture.new()
			texture.atlas = ATLAS
			texture.region = Rect2(0, TYPES.find(kind) * 32 + mini(y, 16), mini(64, int(size.x) - x), mini(16, int(size.y) - y))
			visual.texture = texture
			visual.centered = false
			visual.position = Vector2(x, y)
			add_child(visual)

func _outline() -> PackedVector2Array:
	var w := size.x
	var h := size.y
	match profile:
		"stepped":
			return PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, 6),
				Vector2(w - 5, 6), Vector2(w - 5, h), Vector2(5, h), Vector2(5, 6), Vector2(0, 6)])
		"bracket":
			var anchor := 8.0 if position.x + w / 2 < 160 else w - 8
			return PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w, 4),
				Vector2(anchor, h), Vector2(0, 4)])
		_:
			return PackedVector2Array([Vector2.ZERO, Vector2(w, 0), Vector2(w + 16, 12),
				Vector2(w + 16, h), Vector2(0, h)])

func _draw() -> void:
	if silhouette.is_empty():
		if profile == "slick":
			draw_rect(Rect2(0, 0, size.x, size.y), Color("193d52"))
			draw_line(Vector2.ZERO, Vector2(size.x, 0), Color("68e6ef"))
			for x in range(4, int(size.x) - 4, 8):
				draw_line(Vector2(x, 3), Vector2(x - 3, 8), Color("4796a7"))
		return
	var materials := {"cargo": Color("4a454c"), "cabinet": Color("324857"), "canopy": Color("395365"),
		"fan": Color("354354"), "transformer": Color("434957"), "lift": Color("374e5d")}
	var metal: Color = materials.get(kind, Color("34475a"))
	draw_colored_polygon(silhouette, metal)
	# Give each casing its own panel treatment inside the collision silhouette.
	if kind in ["fan", "duct"]:
		for y in range(5, int(size.y) - 1, 4):
			for x in range(6, int(size.x) - 6, 10):
				_inset(Rect2(x, y, 7, 2), metal.darkened(0.35))
	elif kind in ["transformer", "cargo"]:
		for x in range(6, int(size.x) - 4, 5):
			_inset(Rect2(x, 5, 2, size.y - 8), metal.darkened(0.35))
	elif kind == "cabinet":
		for x in range(7, int(size.x) - 7, 17):
			_inset(Rect2(x, 6, 11, size.y - 9), metal.darkened(0.38))
			_inset(Rect2(x + 2, 7, 2, 1), Color("49a8b5"))
	else:
		for x in range(6, int(size.x) - 4, 9):
			_inset(Rect2(x, 5, 3, 2), metal.darkened(0.24))
	draw_polyline(silhouette + PackedVector2Array([Vector2.ZERO]), Color("182637"))
	draw_line(Vector2.ZERO, Vector2(size.x, 0), Color("adc7d2"))
	if profile == "slope":
		draw_line(Vector2(size.x, 0), Vector2(size.x + 16, 12), Color("adc7d2"))
	for x in range(5, int(size.x) - 4, 8):
		draw_rect(Rect2(x, 2, 2, 2), Color("6e8b9b"))

func _inset(detail: Rect2, color: Color) -> void:
	for corner: Vector2 in [detail.position, detail.end, Vector2(detail.end.x, detail.position.y),
			Vector2(detail.position.x, detail.end.y)]:
		if not Geometry2D.is_point_in_polygon(corner, silhouette):
			return
	draw_rect(detail, color)
