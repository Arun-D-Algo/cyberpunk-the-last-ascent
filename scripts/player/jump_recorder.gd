class_name JumpRecorder
extends Node
## Records solver-observed position at each completed movement tick.

signal measurement_completed(measurement: Dictionary)
var last_jump: Dictionary = {}
var completed_count: int = 0
var _active: Dictionary = {}
var _landing_pending: bool = false
@onready var player: PlayerController = get_parent() as PlayerController


func _ready() -> void:
	player.jump_started.connect(_on_started)
	player.landed.connect(_on_landed)
	player.physics_stepped.connect(_on_stepped)
	player.movement_reset.connect(clear)


func clear() -> void:
	last_jump.clear()
	_active.clear()
	completed_count = 0
	_landing_pending = false


func _on_started(start: Vector2, seconds: float, strength: float, launch: Vector2) -> void:
	_active = {"start": start, "charge_seconds": seconds, "strength": strength,
		"initial_velocity": launch, "peak_height": 0.0, "displacement": 0.0,
		"airborne_seconds": 0.0, "landing": start, "hit_wall": false, "hit_ceiling": false}
	_landing_pending = false


func _on_landed(_at: Vector2) -> void:
	_landing_pending = not _active.is_empty()


func _on_stepped(delta: float) -> void:
	if _active.is_empty():
		return
	var start: Vector2 = _active["start"]
	_active["airborne_seconds"] += delta
	_active["peak_height"] = maxf(_active["peak_height"], start.y - player.global_position.y)
	_active["displacement"] = player.global_position.x - start.x
	_active["hit_wall"] = _active["hit_wall"] or player.is_on_wall()
	_active["hit_ceiling"] = _active["hit_ceiling"] or player.is_on_ceiling()
	if _landing_pending:
		_active["landing"] = player.global_position
		last_jump = _active.duplicate()
		_active.clear()
		_landing_pending = false
		completed_count += 1
		measurement_completed.emit(last_jump)
