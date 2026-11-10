class_name LabHUD
extends CanvasLayer

var player: PlayerController
var recorder: JumpRecorder
var debug_enabled: bool = false
var _debug_elapsed: float = 0.0
@onready var summary: Label = $Summary
@onready var charge_bar: ProgressBar = $ChargeBar
@onready var debug_label: Label = $DebugPanel/Readout
@onready var pause_label: Label = $PauseLabel


func bind_player(body: PlayerController) -> void:
	player = body
	recorder = body.get_node("JumpRecorder") as JumpRecorder


func toggle_debug() -> void:
	debug_enabled = not debug_enabled
	$DebugPanel.visible = debug_enabled
	_debug_elapsed = 1.0


func refresh_debug() -> void:
	_debug_elapsed = 1.0


func _process(delta: float) -> void:
	if player == null:
		return
	pause_label.visible = get_tree().paused
	var direction_text: String = ["LEFT", "UP", "RIGHT"][player.selected_direction + 1]
	var charge: float = player.charge_fraction()
	summary.text = "SYS/00  %s  /  %s  /  %03d%%" % [player.state_name(), direction_text, roundi(charge * 100.0)]
	charge_bar.value = charge * 100.0
	if not debug_enabled:
		return
	_debug_elapsed += delta
	if _debug_elapsed < 0.1:
		return
	_debug_elapsed = 0.0
	var jump: Dictionary = recorder.last_jump
	debug_label.text = "%s floor:%s\npos %.1f,%.1f vel %.1f,%.1f\ncharge %.3fs %.0f%% dir:%d blocked:%s\nsurface:%s friction:%.3f\nnormal %.2f,%.2f slope %.1fdeg\nslide:%s wall:%s ceiling:%s\nlanding vel %.1f,%.1f\nlast %.2f rise %.1f dx %.1f\nair %.3fs hits wall:%d ceiling:%d\nslide dx %.1f max %.1f / %dHz %dFPS" % [
		player.state_name(), player.is_on_floor(), player.position.x, player.position.y,
		player.velocity.x, player.velocity.y, player.charge_duration, charge * 100.0,
		player.selected_direction, player.charge_blocked, player.active_surface.id, player.active_surface.friction,
		player.surface_normal.x, player.surface_normal.y, player.slope_degrees(),
		player.is_sliding(), player.is_on_wall(), player.is_on_ceiling(), player.last_landing_velocity.x, player.last_landing_velocity.y,
		jump.get("strength", 0.0), jump.get("peak_height", 0.0), jump.get("displacement", 0.0), jump.get("airborne_seconds", 0.0),
		jump.get("wall_collision_count", 0), jump.get("ceiling_collision_count", 0), recorder.sliding_distance, recorder.maximum_sliding_speed,
		Engine.physics_ticks_per_second, Engine.get_frames_per_second()]
