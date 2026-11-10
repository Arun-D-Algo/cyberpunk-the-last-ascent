extends Node2D
## Presentation reads state; it never changes the body or movement parameters.

const SPRITES: Texture2D = preload("res://assets/player/maintenance_runner.png")

@onready var player: PlayerController = get_parent() as PlayerController


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if player == null:
		return
	var frame: int = 0
	match player.state:
		PlayerController.State.CHARGING: frame = 2
		PlayerController.State.RISING: frame = 3
		PlayerController.State.FALLING: frame = 4
		PlayerController.State.LANDING: frame = 5
		PlayerController.State.GROUNDED:
			if absf(player.velocity.x) > 1.0:
				frame = int(Time.get_ticks_msec() / 120) % 2
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(player.facing_direction, 1))
	draw_texture_rect_region(SPRITES, Rect2(-8, -32, 16, 32), Rect2(frame * 16, 0, 16, 32))
	draw_set_transform(Vector2.ZERO)
	if player.state == PlayerController.State.CHARGING:
		draw_rect(Rect2(-7, 3, roundf(14 * player.charge_fraction()), 1), Color("00d9e8"))
		var direction: int = player.selected_direction
		var tip: Vector2 = Vector2(direction * 14, -34 if direction == 0 else -11)
		draw_line(Vector2(0, -11), tip, Color("f5d547"))
		draw_rect(Rect2(tip - Vector2.ONE, Vector2(2, 2)), Color("f5d547"))
