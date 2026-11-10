class_name IndustrialArt
extends RefCounted
## Shared atlas vocabulary. Decorative parts never contain collision shapes.

const ATLAS: Texture2D = preload("res://assets/environment/industrial/industrial_atlas.png")
const EFFECTS: Texture2D = preload("res://assets/environment/effects/effects_atlas.png")
const FONT: Font = preload("res://assets/ui/industrial_micro.fnt")
const PARTS: Dictionary = {
	"floor": Rect2(0, 0, 16, 16), "platform": Rect2(16, 0, 16, 16),
	"walkway": Rect2(32, 0, 16, 16), "edge": Rect2(48, 0, 16, 16),
	"wall": Rect2(0, 32, 32, 64), "beam": Rect2(32, 32, 16, 64),
	"pipe": Rect2(48, 32, 16, 64), "actuator": Rect2(48, 96, 16, 64),
	"railing": Rect2(0, 112, 32, 16), "generator": Rect2(64, 0, 96, 160),
	"fan": Rect2(0, 144, 32, 32), "panel": Rect2(0, 176, 32, 32),
	"console": Rect2(0, 208, 48, 32), "door": Rect2(160, 0, 48, 64),
	"sign": Rect2(160, 64, 48, 24), "monitor": Rect2(160, 96, 32, 24),
	"cables": Rect2(208, 0, 32, 64), "damaged": Rect2(208, 80, 32, 32),
	"conduit": Rect2(208, 112, 32, 32), "cyan_lamp": Rect2(160, 128, 32, 8),
	"warning_lamp": Rect2(192, 128, 16, 16), "emergency_lamp": Rect2(208, 128, 16, 16),
	"vent": Rect2(160, 144, 32, 16),
}


static func texture(part: String) -> AtlasTexture:
	assert(PARTS.has(part), "Unknown industrial part: " + part)
	var result: AtlasTexture = AtlasTexture.new()
	result.atlas = ATLAS
	result.region = PARTS[part]
	return result


static func sprite(part: String, at: Vector2, tint: Color = Color.WHITE) -> Sprite2D:
	var result: Sprite2D = Sprite2D.new()
	result.texture = texture(part)
	result.centered = false
	result.position = at
	result.modulate = tint
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return result


static func label(text: String, at: Vector2, color: Color = Color("a9c4cc")) -> Label:
	var result: Label = Label.new()
	result.text = text
	result.position = at
	result.add_theme_font_override("font", FONT)
	result.add_theme_font_size_override("font_size", 7)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result
