extends SceneTree
## Compare authored keys and capture a real charge, jump and landing in Godot.

const REVIEW := "res://docs/visual-review/cinematic/"
const BEFORE: SpriteFrames = preload("res://resources/visuals/david_frames_02g.tres")
const AFTER: SpriteFrames = preload("res://resources/visuals/david_frames_cinematic.tres")
const CELL := Vector2i(40, 40)
const DT := 1.0 / 60.0

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(REVIEW)
	DirAccess.make_dir_recursive_absolute("res://.godot/cinematic-sequence")
	var atlas: AtlasTexture = AFTER.get_frame_texture(&"idle", 0)
	_save(atlas.atlas.get_image(), "atlas_native")
	_compare([&"idle"], "standing", Rect2i(0, 0, 40, 40), true)
	_compare([&"idle"], "head", Rect2i(13, 4, 18, 15), true)
	_compare([&"charge", &"launch", &"rise", &"apex"], "takeoff")
	_compare([&"fall_early", &"fall", &"fall_fast"], "descent")
	_compare([&"land"], "landing")
	await _capture_game()
	quit()


func _compare(animations: Array[StringName], name: String,
		crop := Rect2i(Vector2i.ZERO, CELL), first_only := false) -> void:
	var count := 0
	for animation in animations:
		count += maxi(BEFORE.get_frame_count(animation), AFTER.get_frame_count(animation))
	if first_only:
		count = 1
	var result := Image.create_empty(count * crop.size.x, 2 * crop.size.y, false, Image.FORMAT_RGBA8)
	result.fill(Color("223045"))
	for row in 2:
		var frames := BEFORE if row == 0 else AFTER
		var column := 0
		for animation in animations:
			var length := 1 if first_only else frames.get_frame_count(animation)
			for frame in length:
				var texture: AtlasTexture = frames.get_frame_texture(animation, frame)
				var key := texture.atlas.get_image().get_region(Rect2i(texture.region))
				result.blend_rect(key, crop, Vector2i((column + frame) * crop.size.x, row * crop.size.y))
			column += maxi(BEFORE.get_frame_count(animation), AFTER.get_frame_count(animation))
	_save(result, name + "_native")
	result.resize(result.get_width() * 4, result.get_height() * 4, Image.INTERPOLATE_NEAREST)
	_save(result, name + "_4x")


func _capture_game() -> void:
	var tower: TowerAscent = preload("res://scenes/levels/tower_ascent.tscn").instantiate()
	root.add_child(tower)
	tower.player.accepts_live_input = false
	tower.player.reset_movement(Vector2(145, 144))
	for tick in 14:
		await _step(tower.player)
	await _screen("tower_4x")
	root.size = Vector2i(320, 180)
	for frame in 5:
		await process_frame
	await _screen("tower_native")
	tower.free()

	var lab: PhysicsLab = preload("res://scenes/levels/physics_lab.tscn").instantiate()
	root.add_child(lab)
	lab.player.accepts_live_input = false
	lab.select_section(1)
	await process_frame
	lab.player.reset_movement(Vector2(145, 144))
	for tick in 14:
		await _step(lab.player)
	var sprite: AnimatedSprite2D = lab.player.get_node("Visual/David")
	var stills := {&"charge": 3, &"launch": 1, &"fall_fast": 0, &"land": 0, &"recovery": 2}
	for tick in 126:
		await _step(lab.player, tick == 4, tick >= 4 and tick < 54, tick == 54)
		await RenderingServer.frame_post_draw
		var view := root.get_texture().get_image()
		if view.save_png("res://.godot/cinematic-sequence/%03d.png" % tick) != OK:
			push_error("Could not save jump preview frame")
		var pose := sprite.animation
		if pose == &"land" and sprite.frame == 2:
			pose = &"recovery"
		if stills.get(pose, -1) == sprite.frame:
			_save(view, str(pose) + "_lab_native")
			view.resize(view.get_width() * 4, view.get_height() * 4, Image.INTERPOLATE_NEAREST)
			_save(view, str(pose) + "_lab_4x")
			stills.erase(pose)
	if not stills.is_empty():
		push_error("Missing captured poses: " + str(stills))


func _step(player: PlayerController, press := false, held := false, release := false) -> void:
	await physics_frame
	player.step_movement(DT, 0, press, held, release)


func _screen(name: String) -> void:
	await RenderingServer.frame_post_draw
	_save(root.get_texture().get_image(), name)


func _save(image: Image, name: String) -> void:
	if image.save_png(REVIEW + name + ".png") != OK:
		push_error("Could not save " + name)
