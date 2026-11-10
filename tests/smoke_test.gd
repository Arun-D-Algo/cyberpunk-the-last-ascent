extends SceneTree
## Run with --headless --path . --script res://tests/smoke_test.gd

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func _run() -> void:
	var main_path: String = ProjectSettings.get_setting("application/run/main_scene", "")
	_check(main_path == "res://scenes/main/boot.tscn", "Unexpected main scene")
	_check(ResourceLoader.exists(main_path), "Main scene missing")
	_check(ProjectSettings.get_setting("display/window/size/viewport_width") == 320, "Viewport width")
	_check(ProjectSettings.get_setting("display/window/size/viewport_height") == 180, "Viewport height")
	_check(ProjectSettings.get_setting("display/window/stretch/mode") == "canvas_items", "Stretch mode")
	_check(ProjectSettings.get_setting("display/window/stretch/aspect") == "keep", "Aspect mode")
	_check(ProjectSettings.get_setting("display/window/stretch/scale_mode") == "integer", "Integer scaling")
	_check(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Nearest filtering")
	_check(Engine.physics_ticks_per_second == 60, "Physics tick rate")
	var bindings: Dictionary = {
		"move_left": [KEY_A, KEY_LOCATION_UNSPECIFIED],
		"move_right": [KEY_D, KEY_LOCATION_UNSPECIFIED],
		"look_up": [KEY_W, KEY_LOCATION_UNSPECIFIED],
		"look_down": [KEY_S, KEY_LOCATION_UNSPECIFIED],
		"jump_charge": [KEY_SPACE, KEY_LOCATION_UNSPECIFIED],
		"cyberware_primary": [KEY_SHIFT, KEY_LOCATION_LEFT],
		"cyberware_secondary": [KEY_CTRL, KEY_LOCATION_LEFT],
		"interact": [KEY_E, KEY_LOCATION_UNSPECIFIED],
		"pause_game": [KEY_ESCAPE, KEY_LOCATION_UNSPECIFIED],
		"retry_boss": [KEY_R, KEY_LOCATION_UNSPECIFIED],
	}
	for action: String in bindings:
		_check(InputMap.has_action(action), "Missing action: " + action)
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		var expected_count: int = 2 if action in ["move_left", "move_right", "look_up", "look_down"] else 1
		_check(events.size() == expected_count, "Expected keyboard bindings: " + action)
		if events.is_empty():
			continue
		var key: InputEventKey = events[0] as InputEventKey
		_check(key != null, "Expected InputEventKey: " + action)
		if key != null:
			_check(key.physical_keycode == bindings[action][0], "Physical key: " + action)
			_check(key.location == bindings[action][1], "Key location: " + action)
			_check(not key.alt_pressed and not key.ctrl_pressed and not key.shift_pressed and not key.meta_pressed, "Unexpected chord: " + action)
	var packed: PackedScene = load(main_path) as PackedScene
	_check(packed != null, "Main scene failed to load")
	if packed != null:
		var boot: Node = packed.instantiate()
		root.add_child(boot)
		await process_frame
		await process_frame
		var labels: Dictionary = {
			"Content/Title": "CYBERPUNK: THE LAST ASCENT",
			"Content/Subtitle": "Milestone 02D / Continuous Ascent",
			"Content/Status": "Four floors / 60 landings / one tower",
		}
		for path: String in labels:
			var label: Label = boot.get_node_or_null(path) as Label
			_check(label != null, "Missing label: " + path)
			if label != null:
				_check(label.text == labels[path], "Label text: " + path)
				var bounds: Rect2 = label.get_global_rect()
				_check(root.get_visible_rect().encloses(bounds), "Label outside viewport: " + path)
		boot.free()
	if failures.is_empty():
		print("PASS: foundation smoke test")
		quit(0)
	else:
		printerr("FAIL: %d foundation checks" % failures.size())
		quit(1)
