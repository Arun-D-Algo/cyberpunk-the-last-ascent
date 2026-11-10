extends Node2D
## Presentation reads state; it never changes the body or movement parameters.

@onready var player: PlayerController = get_parent() as PlayerController


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if player == null:
		return
	var accent: Color = Color("59e8ee")
	match player.state:
		PlayerController.State.CHARGING: accent = Color("ffe078")
		PlayerController.State.RISING: accent = Color("94ffbf")
		PlayerController.State.FALLING: accent = Color("c19bff")
		PlayerController.State.LANDING: accent = Color("ffffff")
	draw_rect(Rect2(-7, -26, 14, 26), Color("121c30"))
	draw_rect(Rect2(-7, -26, 14, 26), accent, false, 1.0)
	draw_rect(Rect2(-4, -22, 8, 5), accent)
	draw_line(Vector2(0, -15), Vector2(player.facing_direction * 6, -15), accent, 2.0)
	if player.state == PlayerController.State.GROUNDED and absf(player.velocity.x) > 1.0:
		draw_line(Vector2(-4, -2), Vector2(4, -2), accent, 2.0)
	if player.state == PlayerController.State.CHARGING:
		draw_rect(Rect2(-7, 3, 14 * player.charge_fraction(), 2), accent)
		var direction: int = player.selected_direction
		var tip: Vector2 = Vector2(direction * 14, -34 if direction == 0 else -11)
		draw_line(Vector2(0, -11), tip, accent)
		draw_circle(tip, 2.0, accent)
