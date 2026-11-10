extends Node2D
## Pixel-aligned colored bounce and dust shafts; no lights/shaders/physics overhead.


func _ready() -> void:
	z_index = -10
	queue_redraw()


func _draw() -> void:
	# Broad, faint spill establishes the generator as the cool focal mass.
	draw_colored_polygon(PackedVector2Array([Vector2(202, 20), Vector2(218, 20), Vector2(302, 144), Vector2(130, 144)]), Color(0.0, 0.75, 0.85, 0.045))
	draw_colored_polygon(PackedVector2Array([Vector2(38, 42), Vector2(46, 42), Vector2(105, 144), Vector2(16, 144)]), Color(0.96, 0.7, 0.2, 0.045))
	# Side-lit power trunks run upward behind the landings.
	for y: int in range(-220, 112, 16):
		draw_line(Vector2(296, y), Vector2(296, y + 11), Color("184c60"), 3)
		draw_line(Vector2(295, y), Vector2(295, y + 9), Color("207485"), 1)
	for point: Vector2 in [Vector2(214, 47), Vector2(227, 62), Vector2(242, 89), Vector2(180, 111), Vector2(65, 88), Vector2(80, 120)]:
		draw_rect(Rect2(point, Vector2.ONE), Color(0.4, 0.7, 0.8, 0.3))
