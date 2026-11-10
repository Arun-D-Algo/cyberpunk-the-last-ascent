class_name JumpRecorder
extends Node
## Records solver-observed position at each completed movement tick.

signal measurement_completed(measurement: Dictionary)
var last_jump: Dictionary = {}
var completed_count: int = 0
var _active: Dictionary = {}
var _landing_pending: bool = false
var _just_landed: bool = false
var sliding_distance: float = 0.0
var maximum_sliding_speed: float = 0.0
var trace: PackedVector2Array = PackedVector2Array()
@onready var player: PlayerController = get_parent() as PlayerController


func _ready() -> void:
	player.rebounded.connect(_on_rebound)
	player.jump_started.connect(_on_started)
	player.landed.connect(_on_landed)
	player.physics_stepped.connect(_on_stepped)
	player.movement_reset.connect(clear)
	player.contact_impact.connect(_on_impact)


func clear() -> void:
	last_jump.clear()
	_active.clear()
	completed_count = 0
	_landing_pending = false
	_just_landed = false
	sliding_distance = 0.0
	maximum_sliding_speed = 0.0
	trace.clear()


func _on_started(start: Vector2, seconds: float, strength: float, launch: Vector2) -> void:
	_active = {"start": start, "charge_seconds": seconds, "strength": strength,
		"initial_velocity": launch, "peak_height": 0.0, "displacement": 0.0,
		"airborne_seconds": 0.0, "landing": start, "hit_wall": false, "hit_ceiling": false,
		"rebound_count": 0, "wall_collision_count": 0, "ceiling_collision_count": 0, "launch_surface": String(player.active_surface.id)}
	_landing_pending = false
	trace = PackedVector2Array([start])


func _on_landed(_at: Vector2) -> void:
	_landing_pending = not _active.is_empty()
	_just_landed = true
	sliding_distance = 0.0
	maximum_sliding_speed = absf(player.tangent_speed()) if player.is_sliding() else 0.0
	if _landing_pending:
		_active["landing_velocity"] = player.last_landing_velocity
		_active["landing_surface"] = String(player.surface_body_name)
		_active["surface_type"] = String(player.active_surface.id)


func _on_impact(normal: Vector2, _incoming: Vector2) -> void:
	if _active.is_empty():
		return
	if normal.y >= cos(player.floor_max_angle) - 0.001:
		_active["ceiling_collision_count"] += 1
	else:
		_active["wall_collision_count"] += 1


func _on_stepped(delta: float) -> void:
	var landing_tick: bool = _just_landed
	_just_landed = false
	# This tick's travel was airborne up to contact, not a whole tick of surface sliding.
	if player.is_sliding() and not landing_tick:
		sliding_distance += absf(player.tangent_speed()) * delta
		maximum_sliding_speed = maxf(maximum_sliding_speed, absf(player.tangent_speed()))
		if not last_jump.is_empty():
			last_jump["sliding_distance"] = sliding_distance
			last_jump["maximum_sliding_speed"] = maximum_sliding_speed
	if _active.is_empty():
		return
	var start: Vector2 = _active["start"]
	_active["airborne_seconds"] += delta
	if trace.size() < 2048:
		trace.append(player.global_position)
	_active["peak_height"] = maxf(_active["peak_height"], start.y - player.global_position.y)
	_active["displacement"] = player.global_position.x - start.x
	_active["hit_wall"] = _active["hit_wall"] or player.is_on_wall()
	_active["hit_ceiling"] = _active["hit_ceiling"] or player.is_on_ceiling()
	if _landing_pending:
		_active["landing"] = player.global_position
		last_jump = _active.duplicate()
		last_jump["sliding_distance"] = sliding_distance
		last_jump["maximum_sliding_speed"] = maximum_sliding_speed
		_active.clear()
		_landing_pending = false
		completed_count += 1
		measurement_completed.emit(last_jump)


func _on_rebound(normal: Vector2, impulse: Vector2, kind: String) -> void:
	if not _active.is_empty():
		_active["rebound_count"] += 1
		_active["rebound_normal"] = normal
		_active["rebound_impulse"] = impulse
		_active["rebound_incoming"] = player.velocity - impulse
		_active["rebound_type"] = kind
