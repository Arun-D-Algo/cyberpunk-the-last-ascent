extends Control


func _ready() -> void:
	$Content/EnterLab.pressed.connect(enter_lab)
	$Content/EnterChamber.pressed.connect(enter_chamber)


func enter_chamber() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/regions/sublevel_zero/emergency_power_chamber.tscn")
	if error != OK:
		push_error("Could not enter Emergency Power Chamber: " + error_string(error))


func enter_lab() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/levels/physics_lab.tscn")
	if error != OK:
		push_error("Could not enter Physics Lab: " + error_string(error))
