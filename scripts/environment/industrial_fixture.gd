class_name IndustrialFixture
extends Node2D
## Reusable decorative fan/light/spark/steam, entirely separate from hazard mechanics.

@export_enum("fan", "cyan_lamp", "warning_lamp", "emergency_lamp", "monitor", "spark", "steam") var kind: String = "fan"
@export var phase: float = 0.0
@export var animation_enabled: bool = true
var elapsed: float = 0.0
var visual: Sprite2D
var animation_frame: int = 0


func _ready() -> void:
	visual = Sprite2D.new()
	visual.centered = false
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if kind in ["fan", "spark", "steam"]:
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = IndustrialArt.EFFECTS
		visual.texture = atlas
	else:
		visual.texture = IndustrialArt.texture(kind)
	add_child(visual)
	_update_art()


func _process(delta: float) -> void:
	if animation_enabled:
		elapsed += delta
		_update_art()


func _update_art() -> void:
	var clock: float = elapsed + phase
	animation_frame = int(clock * (6.0 if kind == "fan" else 4.0)) % 4
	if kind in ["fan", "spark", "steam"]:
		var atlas: AtlasTexture = visual.texture as AtlasTexture
		atlas.region = Rect2(animation_frame * 32, 0, 32, 32) if kind == "fan" else Rect2(animation_frame * 16, 32 if kind == "spark" else 48, 16, 16)
		if kind == "spark":
			visual.visible = fmod(clock, 6.0) < 0.22
	else:
		# Slow state changes, not rapid strobing. No postprocess or global lighting dependency.
		visual.modulate = Color(0.65, 0.72, 0.78) if int(clock * 2) % 11 == 0 else Color.WHITE
	queue_redraw()


func _draw() -> void:
	if kind not in ["cyan_lamp", "warning_lamp", "emergency_lamp", "monitor"]:
		return
	var color: Color = Color("00d9e8") if kind in ["cyan_lamp", "monitor"] else Color("f5d547") if kind == "warning_lamp" else Color("f04775")
	var center: Vector2 = Vector2(16, 4) if kind == "cyan_lamp" else Vector2(16, 10) if kind == "monitor" else Vector2(8, 8)
	for band: int in range(4, 0, -1):
		var size: Vector2 = Vector2(14 + band * 5, 8 + band * 5)
		var glow: Color = color
		glow.a = 0.018
		draw_rect(Rect2(center - size / 2.0, size), glow)
