class_name OpeningMachine
extends StaticBody2D
## Render and collision share the complete casing dimensions.
const ATLAS: Texture2D = preload("res://assets/environment/opening/machinery.png")
const TYPES := ["booth", "cargo", "canopy", "beam", "cabinet", "duct", "fan", "transformer", "lift"]
var size := Vector2(64, 16)
var kind := "beam"

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	collider.position = size / 2
	add_child(collider)
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
