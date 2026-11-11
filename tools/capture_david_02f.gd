extends SceneTree
## Actual Compatibility renders plus native and enlarged sprite sheets.

const REVIEW := "res://docs/visual-review/milestone-02f/"
const ATLAS: Texture2D = preload("res://assets/player/david_martinez_02f.png")
const DT := 1.0 / 60.0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(REVIEW)
	var atlas := ATLAS.get_image()
	_save(atlas, "atlas_native")
	_save_strip(atlas, "idle_strip_3x", 0, 4)
	_save_strip(atlas, "forced_strip_3x", 8, 2)
	var before := preload("res://assets/player/david_martinez.png").get_image().get_region(Rect2i(0, 0, 24, 40))
	var after := atlas.get_region(Rect2i(0, 0, 32, 40))
	var comparison := Image.create_empty(96, 40, false, Image.FORMAT_RGBA8)
	comparison.fill(Color("223045"))
	comparison.blend_rect(before, Rect2i(Vector2i.ZERO, before.get_size()), Vector2i(4, 0))
	comparison.blend_rect(after, Rect2i(Vector2i.ZERO, after.get_size()), Vector2i(32, 0))
	after.flip_x()
	comparison.blend_rect(after, Rect2i(Vector2i.ZERO, after.get_size()), Vector2i(64, 0))
	_save(comparison, "before_after_native")
	comparison.resize(576, 240, Image.INTERPOLATE_NEAREST)
	_save(comparison, "before_after_6x")
	_save_strip(atlas, "walk_strip_3x", 1, 6)
	_save_strip(atlas, "charge_strip_3x", 2, 4)
	var sheet := Image.create_empty(atlas.get_width() * 2, atlas.get_height(), false, Image.FORMAT_RGBA8)
	sheet.fill(Color("121c2c"))
	sheet.fill_rect(Rect2i(atlas.get_width(), 0, atlas.get_width(), atlas.get_height()), Color("adb6c6"))
	for column in 2:
		sheet.blend_rect(atlas, Rect2i(Vector2i.ZERO, atlas.get_size()), Vector2i(column * atlas.get_width(), 0))
	sheet.resize(sheet.get_width() * 3, sheet.get_height() * 3, Image.INTERPOLATE_NEAREST)
	_save(sheet, "atlas_readability_3x")

	var tower: TowerAscent = preload("res://scenes/levels/tower_ascent.tscn").instantiate()
	root.add_child(tower)
	tower.player.accepts_live_input = false
	tower.player.reset_movement(Vector2(145, 144))
	for tick in 14:
		await _step(tower.player)
	await RenderingServer.frame_post_draw
	var game := root.get_texture().get_image()
	_save(game, "tower_3x")
	root.size = Vector2i(320, 180)
	await _draw_size()
	_save(root.get_texture().get_image(), "tower_native")
	root.size = Vector2i(960, 540)
	await _draw_size()
	tower.free()

	var lab: PhysicsLab = preload("res://scenes/levels/physics_lab.tscn").instantiate()
	root.add_child(lab)
	lab.player.accepts_live_input = false
	lab.select_section(23)
	await process_frame
	var timeline := Image.create_empty(960, 540, false, Image.FORMAT_RGBA8)
	for index in 4:
		for tick in (12 if index == 0 else 22):
			await _step(lab.player)
		await RenderingServer.frame_post_draw
		var shot := root.get_texture().get_image()
		if index == 2:
			_save(shot, "ramp_3x")
		shot.resize(480, 270, Image.INTERPOLATE_NEAREST)
		timeline.blit_rect(shot, Rect2i(0, 0, 480, 270), Vector2i((index % 2) * 480, (index / 2) * 270))
		print("RAMP CAPTURE tick=%d x=%.3f y=%.3f speed=%.3f" % [12 + index * 22, lab.player.position.x, lab.player.position.y, lab.player.tangent_speed()])
	_save(timeline, "ramp_timeline")
	quit()

func _save_strip(atlas: Image, name: String, row: int, count: int) -> void:
	var strip := atlas.get_region(Rect2i(0, row * 40, count * 32, 40))
	strip.resize(strip.get_width() * 3, strip.get_height() * 3, Image.INTERPOLATE_NEAREST)
	_save(strip, name)

func _draw_size() -> void:
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw

func _step(player: PlayerController) -> void:
	await physics_frame
	paused = false
	player.step_movement(DT, 0, false, false, false)

func _save(image: Image, name: String) -> void:
	var error := image.save_png(REVIEW + name + ".png")
	if error != OK:
		push_error("Could not save " + name)
