extends SceneTree
const OUT := "res://docs/visual-review/milestone-03b/"
const LEVEL := preload("res://scenes/levels/opening_ascent.tscn")
var game: OpeningAscent

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	root.mode = Window.MODE_WINDOWED
	root.size = Vector2i(320, 180)
	game = LEVEL.instantiate()
	root.add_child(game)
	game.player.accepts_live_input = false
	var shots := {"exterior": "Base", "plaza_overhang": "GlassLintel", "service_gate": "ServiceGate",
		"fan_rebound": "FanSill", "slope": "PipeSaddle", "ventilation_fork": "HousingRoof",
		"exhaust": "ChuteCatch", "slick": "CondensationTray", "transformer_shaft": "BankTongue",
		"header": "RadiatorHead", "summit": "Summit"}
	for title: String in shots:
		var rect: Rect2 = game.surfaces[shots[title]]
		var at := Vector2(rect.get_center().x, rect.position.y)
		if shots[title] == "Base":
			at = OpeningAscent.SPAWN
		game.player.reset_movement(at)
		game.camera.reset_tracking()
		for tick in 12:
			await physics_frame
			game.player.step_movement(1.0 / 60, 0, false, false, false)
		await _capture_pair(title)
	await _capture_summit_fall()
	game.free()

	var overview := SubViewport.new()
	overview.size = Vector2i(320, 1590)
	overview.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(overview)
	var whole := LEVEL.instantiate() as OpeningAscent
	overview.add_child(whole)
	whole.player.accepts_live_input = false
	whole.camera.enabled = false
	whole.hud.hide()
	var top_y := -1400
	overview.canvas_transform = Transform2D(0, Vector2(0, -top_y))
	await process_frame
	await RenderingServer.frame_post_draw
	var layout := overview.get_texture().get_image()
	_save(layout, "full_layout")
	var ends := [top_y, int(OpeningRoute.BOUNDARIES[1]), int(OpeningRoute.BOUNDARIES[0]), 168]
	for section in 3:
		var section_start: int = ends[section]
		var height: int = ends[section + 1] - section_start
		_save(layout.get_region(Rect2i(0, section_start - top_y, 320, height)), "section_%d" % (3 - section))
	var before := Image.load_from_file("res://docs/visual-review/milestone-03a/full_layout.png")
	var old_ends := [0, 960, 1528, 2008]
	for section in 3:
		var start: int = old_ends[section]
		var height: int = old_ends[section + 1] - start
		_save(before.get_region(Rect2i(0, start, 320, height)), "before_section_%d" % (3 - section))
	print("Rendered 03B review captures")
	quit()

func _capture_summit_fall() -> void:
	var summit: Rect2 = game.surfaces["Summit"]
	game.player.reset_movement(Vector2(summit.get_center().x, summit.position.y - 1))
	game.camera.reset_tracking()
	for tick in 8:
		await _step(0)
	for tick in 110:
		await _step(-1)
		if not game.player.is_on_floor():
			break
	var captured := false
	for tick in 220:
		await _step(0)
		if not captured and game.player.position.y > summit.position.y + 150:
			await _capture_pair("fall_lane")
			captured = true
		if game.player.is_on_floor() and game.player.surface_body_name == &"TowerFin":
			for settle in 12:
				await _step(0)
			await _capture_pair("fall_recovery")
			return
	push_error("The summit capture did not reach Tower Fin")

func _step(direction: int) -> void:
	await physics_frame
	game.player.step_movement(1.0 / 60, direction, false, false, false)

func _capture_pair(title: String) -> void:
	await RenderingServer.frame_post_draw
	var frame := root.get_texture().get_image()
	assert(frame.get_size() == Vector2i(320, 180), "Review window must render at native resolution")
	_save(frame, title + "_native")
	frame.resize(1280, 720, Image.INTERPOLATE_NEAREST)
	_save(frame, title + "_4x")

func _save(image: Image, title: String) -> void:
	assert(image.save_png(OUT + title + ".png") == OK)
