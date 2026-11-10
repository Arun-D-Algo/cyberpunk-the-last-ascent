extends Control


func _ready() -> void:
	$Content/EnterLab.pressed.connect(enter_lab)


func enter_lab() -> void:
	var error: Error = get_tree().change_scene_to_file("res://scenes/levels/physics_lab.tscn")
	if error != OK:
		push_error("Could not enter Physics Lab: " + error_string(error))
