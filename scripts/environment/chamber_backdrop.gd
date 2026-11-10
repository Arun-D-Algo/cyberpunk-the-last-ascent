class_name ChamberBackdrop
extends Node2D
## Finite oversized layers cover the whole chamber; no repeat boundary can enter view.

@export var camera: Camera2D
var far_layer: Sprite2D
var mid_layer: Node2D
const REST: Vector2 = Vector2(0, -272)


func _ready() -> void:
	z_index = -20
	far_layer = Sprite2D.new()
	far_layer.texture = preload("res://assets/environment/backgrounds/shaft_far.png")
	far_layer.centered = false
	add_child(far_layer)
	mid_layer = Node2D.new()
	add_child(mid_layer)
	var structure: Sprite2D = Sprite2D.new()
	structure.texture = preload("res://assets/environment/backgrounds/shaft_mid.png")
	structure.centered = false
	mid_layer.add_child(structure)
	# Deliberate background masses, not repeated foreground tilework.
	mid_layer.add_child(IndustrialArt.sprite("generator", Vector2(189, 240), Color("77919a")))
	mid_layer.add_child(IndustrialArt.sprite("generator", Vector2(40, 110), Color("3d566b")))
	mid_layer.add_child(IndustrialArt.sprite("door", Vector2(128, 20), Color("657688")))
	for at: Vector2 in [Vector2(43, 288), Vector2(261, 95), Vector2(128, 176)]:
		mid_layer.add_child(IndustrialArt.sprite("cables", at, Color("5c7187")))
	for y: int in range(12, 460, 64):
		mid_layer.add_child(IndustrialArt.sprite("pipe", Vector2(12, y), Color("82919a")))
		mid_layer.add_child(IndustrialArt.sprite("beam", Vector2(290, y), Color("5d7182")))
	_process(0.0)


func _process(_delta: float) -> void:
	var offset_y: float = (camera.global_position.y - 54.0) if camera != null else 0.0
	far_layer.position = REST + Vector2(0, roundf(offset_y * 0.12))
	mid_layer.position = REST + Vector2(0, roundf(offset_y * 0.045))
