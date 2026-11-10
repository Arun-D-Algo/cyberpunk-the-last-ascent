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
	summary.text = "%s  |  %s  |  %d%%" % [player.state_name(), direction_text, roundi(charge * 100.0)]
	charge_bar.value = charge * 100.0
	if not debug_enabled:
		return
	_debug_elapsed += delta
	if _debug_elapsed < 0.1:
		return
	_debug_elapsed = 0.0
	var jump: Dictionary = recorder.last_jump
	debug_label.text = "%s  floor:%s\npos %.1f, %.1f  vel %.1f, %.1f\ncharge %.3fs / %.0f%%  dir:%d\nlast %.2f  rise %.1fpx  dx %.1fpx\nair %.3fs  wall:%s ceil:%s\nphysics %dHz  render %dFPS" % [
		player.state_name(), player.is_on_floor(), player.position.x, player.position.y,
		player.velocity.x, player.velocity.y, player.charge_duration, charge * 100.0,
		player.selected_direction, jump.get("strength", 0.0), jump.get("peak_height", 0.0),
		jump.get("displacement", 0.0), jump.get("airborne_seconds", 0.0),
		jump.get("hit_wall", false), jump.get("hit_ceiling", false),
		Engine.physics_ticks_per_second, Engine.get_frames_per_second()]
