extends SceneTree
const OUT := "res://docs/visual-review/milestone-03a/"
var game: OpeningAscent

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var boot := preload("res://scenes/main/boot.tscn").instantiate()
	root.add_child(boot)
	await process_frame
	await RenderingServer.frame_post_draw
	_save(root.get_texture().get_image(), "menu_native")
	boot.free()
	game = preload("res://scenes/levels/opening_ascent.tscn").instantiate()
	root.add_child(game)
	game.player.accepts_live_input = false
	var shots := {"exterior": -1, "service_entrance": 8, "plaza": 3, "ventilation": 14,
		"ventilation_route": 18, "transformer": 25, "transformer_route": 31,
		"transition_ventilation": 10, "transition_transformer": 22, "summit": 35}
	root.size = Vector2i(320, 180)
	for title: String in shots:
		var index: int = shots[title]
		var at := OpeningAscent.SPAWN
		if index >= 0:
			var rect: Rect2 = game.route[index].rect
			at = Vector2(rect.get_center().x, rect.position.y)
		game.player.reset_movement(at)
		game.camera.reset_tracking()
		for tick in 12:
			await physics_frame
			game.player.step_movement(1.0 / 60, 0, false, false, false)
		await RenderingServer.frame_post_draw
		var frame := root.get_texture().get_image()
		_save(frame, title + "_native")
		frame.resize(1280, 720, Image.INTERPOLATE_NEAREST)
		_save(frame, title + "_4x")
	print("Opening geometry bodies: ", game.get_node("Geometry").get_child_count())
	print("Opening rendered nodes: ", get_node_count())
	root.size = Vector2i(960, 540)
	var timings: Array[float] = []
	for frame in 180:
		await process_frame
		if frame >= 60:
			timings.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000)
	timings.sort()
	var metrics := {"sample_frames": timings.size(), "process_median_ms": timings[timings.size() / 2],
		"process_p95_ms": timings[int(timings.size() * 0.95)], "resolution": "960x540",
		"geometry_bodies": game.get_node("Geometry").get_child_count(), "nodes": get_node_count()}
	FileAccess.open("res://.godot/opening-performance.json", FileAccess.WRITE).store_string(JSON.stringify(metrics, "\t"))
	print("Opening steady render sample: ", metrics)
	game.free()
	var overview := SubViewport.new()
	overview.size = Vector2i(320, 2056)
	overview.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(overview)
	var whole := preload("res://scenes/levels/opening_ascent.tscn").instantiate()
	overview.add_child(whole)
	whole.player.accepts_live_input = false
	whole.camera.enabled = false
	whole.hud.hide()
	overview.canvas_transform = Transform2D(0, Vector2(0, 1840))
	await process_frame
	await RenderingServer.frame_post_draw
	_save(overview.get_texture().get_image(), "full_layout")
	print("Rendered 03A review captures")
	quit()

func _save(image: Image, title: String) -> void:
	assert(image.save_png(OUT + title + ".png") == OK)
