class_name IndustrialPlatform
extends StaticBody2D
## Whole-pixel top edge is the collision surface. Art is below it, never above it.

@export_range(16, 320, 1) var width: int = 64
@export var warning_edge: bool = false
@export var support_depth: int = 12


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	var collision: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(width, 8)
	collision.shape = rectangle
	collision.position = Vector2(width / 2.0, 4)
	add_child(collision)
	# Tile cropped end sections instead of stretching pixels to arbitrary platform widths.
	for x: int in range(0, width, 16):
		var tile: Sprite2D = IndustrialArt.sprite("platform" if warning_edge and (x == 0 or x + 16 >= width) else "walkway", Vector2(x, 0))
		var tex: AtlasTexture = tile.texture as AtlasTexture
		tex.region.size.x = mini(16, width - x)
		add_child(tile)
	queue_redraw()


func _draw() -> void:
	# Under-brackets imply load-bearing construction and do not add invisible collision.
	for x: int in [3, maxi(3, width - 10)]:
		draw_line(Vector2(x, 8), Vector2(x, support_depth), Color("34475a"), 2)
		draw_line(Vector2(x, support_depth), Vector2(x + 6, 8), Color("172638"), 2)
