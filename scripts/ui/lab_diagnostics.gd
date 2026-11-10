class_name LabDiagnostics
extends Node2D
## Opt-in actual trace, velocity, collider and support normal; no prediction formula.

var player: PlayerController
var enabled: bool = false


func _process(_delta: float) -> void:
	if enabled:
		queue_redraw()
	elif visible:
		hide()


func set_enabled(value: bool) -> void:
	enabled = value
	visible = value
	queue_redraw()


func _draw() -> void:
	if not enabled or player == null:
		return
	draw_rect(Rect2(player.global_position - Vector2(5, 24), Vector2(10, 24)), Color("f04775"), false)
	draw_line(player.global_position, player.global_position + player.surface_normal * 20, Color("f5d547"))
	draw_line(player.global_position - Vector2(0, 12), player.global_position - Vector2(0, 12) + player.velocity * 0.15, Color("00d9e8"))
	var recorder: JumpRecorder = player.get_node("JumpRecorder") as JumpRecorder
	if recorder.trace.size() >= 2:
		draw_polyline(recorder.trace, Color(0.0, 0.85, 0.9, 0.5), 1.0)
