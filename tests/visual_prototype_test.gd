extends "res://tests/physics_test.gd"
## Reuses the M01 real-tick helpers and assertion reporting, not a new test framework.


func _run() -> void:
	for invariant: Array in [
		["res://scripts/player/jump_physics.gd", "ebd43593c9a8a1279eadfe96995f3c4b3dc151b7eb5f794c851ea34110e6b0ca"],
		["res://resources/physics/default_player_physics.tres", "590ffd44d20e79392b1cb1abcc29c552ed017a20842b3fbe384ca7bf4c11a24e"],
		["res://scenes/player/player.tscn", "92d1543961d12bd0080b29011ec60dde3436742dcaf48ad1fed0bc1684a949a0"],
		["res://scripts/camera/lab_camera.gd", "ae3c9fb79cc76d89e1d91f134f973427c30e696d00426ad7868069bd6cc52158"],
	]:
		check(FileAccess.get_sha256(invariant[0]) == invariant[1], "Approved M01 source unchanged: " + invariant[0])
	_test_assets()
	await _test_arrow_input()
	await _test_chamber()
	if failures.is_empty():
		print("PASS: %d visual-prototype/input checks" % checks)
		quit(0)
	else:
		printerr("FAIL: %d / %d visual-prototype checks" % [failures.size(), checks])
		quit(1)


func _test_assets() -> void:
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility renderer preserved")
	check(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0, "Nearest global filtering")
	for path: String in ["res://assets/environment/industrial/industrial_atlas.png", "res://assets/environment/backgrounds/shaft_far.png", "res://assets/environment/backgrounds/shaft_mid.png", "res://assets/environment/effects/effects_atlas.png", "res://assets/player/maintenance_runner.png", "res://assets/ui/industrial_micro.png"]:
		var texture: Texture2D = load(path) as Texture2D
		check(texture != null and texture.get_width() > 0, "Texture loads with pixels: " + path)
		if texture != null:
			check(not texture.get_image().has_mipmaps(), "No pixel-art mipmaps: " + path)
		var settings: ConfigFile = ConfigFile.new()
		check(settings.load(path + ".import") == OK, "Texture source metadata loads")
		check(settings.get_value("params", "compress/mode") == 0, "Lossless texture import")
		check(not settings.get_value("params", "mipmaps/generate"), "Mipmaps disabled in import")
	for part: String in IndustrialArt.PARTS:
		var atlas: AtlasTexture = IndustrialArt.texture(part)
		check(Rect2(Vector2.ZERO, atlas.atlas.get_size()).encloses(atlas.region), "Atlas region valid: " + part)
	check(IndustrialArt.FONT.get_string_size("SUBLEVEL ZERO", HORIZONTAL_ALIGNMENT_LEFT, -1, 7).x < 100.0, "Bitmap title has native compact metrics")


func _key(code: Key, down: bool) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)


func _test_arrow_input() -> void:
	# Let the initial viewport/focus flush finish before injecting physical events.
	await process_frame
	await process_frame
	for binding: Array in [["move_left", KEY_A, KEY_LEFT], ["move_right", KEY_D, KEY_RIGHT], ["look_up", KEY_W, KEY_UP], ["look_down", KEY_S, KEY_DOWN]]:
		var keys: Array[InputEvent] = InputMap.action_get_events(binding[0])
		check(keys.size() == 2, "Two semantic bindings: " + binding[0])
		for code: int in [binding[1], binding[2]]:
			_key(code as Key, true)
			await process_frame
			check(Input.is_action_pressed(binding[0]), "Physical input mapping: " + str(code))
			_key(code as Key, false)
			await process_frame
			check(not Input.is_action_pressed(binding[0]), "Physical input releases action")
	for combo: Array in [[KEY_A, KEY_RIGHT], [KEY_LEFT, KEY_D]]:
		_key(combo[0] as Key, true)
		_key(combo[1] as Key, true)
		await process_frame
		check(JumpPhysics.direction(Input.is_action_pressed("move_left"), Input.is_action_pressed("move_right")) == 0, "Mixed opposite keys neutral")
		_key(combo[0] as Key, false)
		_key(combo[1] as Key, false)
		await process_frame


func _test_chamber() -> void:
	var boot: Control = load("res://scenes/main/boot.tscn").instantiate() as Control
	root.add_child(boot)
	current_scene = boot
	boot.get_node("Content/EnterChamber").emit_signal("pressed")
	await process_frame
	await process_frame
	check(current_scene is EmergencyPowerChamber, "Boot button enters actual chamber")
	if not current_scene is EmergencyPowerChamber:
		return
	var room: EmergencyPowerChamber = current_scene as EmergencyPowerChamber
	body = room.player
	body.accepts_live_input = false
	recorder = body.get_node("JumpRecorder") as JumpRecorder
	await _ticks(8)
	check(body.is_on_floor(), "Chamber spawn grounded")
	check(room.platforms.size() == 7, "Floor plus six route platforms instantiated")
	for platform: IndustrialPlatform in room.platforms:
		var collider: CollisionShape2D = platform.get_child(0) as CollisionShape2D
		check(collider != null and collider.shape is RectangleShape2D, "Reusable platform has real rectangular collision")
		near(collider.position.y - collider.shape.size.y / 2.0, 0.0, 0.001, "Art and collision top aligned")
		check(platform.collision_layer == 1 and platform.collision_mask == 2, "Platform collision layer contract")
	for fixture: IndustrialFixture in room.fixtures:
		check(fixture.visual != null and fixture.visual.texture != null, "Fixture animation initialized: " + fixture.kind)
		var initial_elapsed: float = fixture.elapsed
		var initial_region: Rect2 = (fixture.visual.texture as AtlasTexture).region
		fixture._process(0.4)
		check(fixture.elapsed > initial_elapsed, "Fixture animation clock advances")
		if fixture.kind in ["fan", "steam", "spark"]:
			check((fixture.visual.texture as AtlasTexture).region != initial_region, "Fixture selects a different atlas frame")
		check(fixture.get_children().all(func(node: Node) -> bool: return not node is CollisionObject2D), "Decoration contains no hazards/collision")
	check(room.hud.player == body and room.hud.charge_bar.get_theme_stylebox("fill") is StyleBoxFlat, "Styled HUD bound to production player")
	await _charge(0.3)
	await process_frame
	check(room.hud.charge_bar.value > 0.0 and room.hud.summary.text.contains("CHARGING"), "Chamber HUD shows actual charge/state")
	_send_action("pause_game", true)
	_send_action("pause_game", false)
	await process_frame
	check(paused and body.charge_duration == 0.0, "Chamber Esc cancels charge and pauses")
	var paused_clock: float = room.fixtures[0].elapsed
	await process_frame
	await process_frame
	near(room.fixtures[0].elapsed, paused_clock, 0.0, "Decorative clocks pause with gameplay")
	_send_action("pause_game", true)
	_send_action("pause_game", false)
	await process_frame
	check(not paused, "Chamber Esc resumes")
	room.reset_chamber()
	await _ticks(8)
	var recipes: Array = [[45.0, 0.5, 1], [109.0, 0.75, 1], [183.0, 0.75, -1], [114.0, 0.75, 1], [194.0, 0.75, -1], [106.0, 0.75, 1]]
	for index: int in recipes.size():
		var recipe: Array = recipes[index]
		for tick: int in 120:
			if absf(body.position.x - float(recipe[0])) <= 0.8:
				break
			await _tick(1 if body.position.x < float(recipe[0]) else -1)
		await _charge(recipe[1], recipe[2])
		await _tick(recipe[2], false, false, true)
		check(await _land(), "Chamber jump returns grounded")
		print("CHAMBER ROUTE %d landed %s" % [index + 1, body.position])
		near(body.position.y, float(EmergencyPowerChamber.ROUTE[index][1]), 0.15, "Chamber route reaches platform " + str(index + 1))
		if absf(body.position.y - float(EmergencyPowerChamber.ROUTE[index][1])) > 0.15:
			break
	check(body.position.y < -143.0, "Chamber upper exit reached without teleporting")
	var top_y: float = body.position.y
	for tick: int in 100:
		await _tick(1)
		if not body.is_on_floor():
			break
	check(await _land(), "Chamber fall finds recovery without reset")
	check(body.position.y > top_y + 20.0, "Chamber fall loses altitude without trapping player")
	# Full field-of-view coverage at all stops and both manual look directions.
	for at: Vector2 in [Vector2(45, 144), Vector2(194, -40), Vector2(210, -144)]:
		body.reset_movement(at)
		room.camera.reset_tracking()
		await _ticks(8)
		for action: String in ["look_up", "look_down"]:
			Input.action_press(action)
			await _ticks(12)
			var camera_y: float = room.camera.position.y
			for layer: Node2D in [room.backdrop.far_layer, room.backdrop.mid_layer]:
				check(layer.global_position.y <= camera_y - 90 and layer.global_position.y + 512 >= camera_y + 90, "Parallax covers look view without seams")
			Input.action_release(action)
	room.reset_chamber()
	await _ticks(8)
	check(body.position.distance_to(EmergencyPowerChamber.SPAWN) < 0.1 and recorder.last_jump.is_empty(), "Chamber reset preserves controller contract")
	room.free()
	current_scene = null
