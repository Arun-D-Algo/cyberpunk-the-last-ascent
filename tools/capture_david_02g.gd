extends SceneTree
## Capture editable atlas keys and real engine views for art review.

const REVIEW := "res://docs/visual-review/milestone-02g/"
const FRAMES: SpriteFrames = preload("res://resources/visuals/david_frames_02g.tres")
const BEFORE: Texture2D = preload("res://assets/player/david_martinez_02f.png")
const CELL := Vector2i(40, 40)
const DT := 1.0 / 60.0

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(REVIEW)
	var atlas: AtlasTexture = FRAMES.get_frame_texture(&"idle", 0)
	_save(atlas.atlas.get_image(), "atlas_native")
	var standing := _strip(2)
	standing.blend_rect(BEFORE.get_image().get_region(Rect2i(0, 0, 32, 40)), Rect2i(0, 0, 32, 40), Vector2i(4, 0))
	standing.blend_rect(_key(&"idle", 0), Rect2i(Vector2i.ZERO, CELL), Vector2i(40, 0))
	_save_pair(standing, "standing", 6)
	var anatomy := _strip(2)
	for index in 2:
		var standing_key := standing.get_region(Rect2i(index * 40, 0, 40, 40))
		anatomy.blit_rect(standing_key, Rect2i(8, 3, 24, 15), Vector2i(index * 40 + 8, 0))
		anatomy.blit_rect(standing_key, Rect2i(8, 18, 26, 22), Vector2i(index * 40 + 8, 16))
	_save_pair(anatomy, "anatomy", 6)
	_save_keys([&"launch", &"rise", &"apex"], "takeoff")
	_save_keys([&"fall_early", &"fall", &"fall_fast"], "descent")
	await _capture_game()
	quit()


func _key(animation: StringName, index: int) -> Image:
	var texture: AtlasTexture = FRAMES.get_frame_texture(animation, index)
	return texture.atlas.get_image().get_region(Rect2i(texture.region))


func _strip(count: int) -> Image:
	var result := Image.create_empty(count * CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
	result.fill(Color("223045"))
	return result


func _save_keys(animations: Array[StringName], name: String) -> void:
	var count := 0
	for animation in animations:
		count += FRAMES.get_frame_count(animation)
	var result := _strip(count)
	var index := 0
	for animation in animations:
		for frame in FRAMES.get_frame_count(animation):
			result.blend_rect(_key(animation, frame), Rect2i(Vector2i.ZERO, CELL), Vector2i(index * CELL.x, 0))
			index += 1
	_save_pair(result, name, 3)


func _capture_game() -> void:
	var tower: TowerAscent = preload("res://scenes/levels/tower_ascent.tscn").instantiate()
	root.add_child(tower)
	tower.player.accepts_live_input = false
	tower.player.reset_movement(Vector2(145, 144))
	for tick in 14:
		await _step(tower.player)
	await RenderingServer.frame_post_draw
	_save(root.get_texture().get_image(), "tower_3x")
	root.size = Vector2i(320, 180)
	for frame in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	_save(root.get_texture().get_image(), "tower_native")
	root.size = Vector2i(960, 540)
	tower.free()

	var lab: PhysicsLab = preload("res://scenes/levels/physics_lab.tscn").instantiate()
	root.add_child(lab)
	lab.player.accepts_live_input = false
	lab.select_section(1)
	await process_frame
	lab.player.reset_movement(Vector2(145, -160))
	lab.camera.reset_tracking()
	var captured: Array[StringName] = []
	var sprite: AnimatedSprite2D = lab.player.get_node("Visual/David")
	for tick in 60:
		await _step(lab.player)
		var pose := sprite.animation
		if pose in [&"fall_early", &"fall", &"fall_fast"] and pose not in captured:
			# Show visible downward motion before sampling the early pose.
			if lab.player.velocity.y < 45.0:
				continue
			captured.append(pose)
			await RenderingServer.frame_post_draw
			_save(root.get_texture().get_image(), str(pose) + "_lab_3x")
			print("Captured %s at %.1f px/s" % [pose, lab.player.velocity.y])


func _step(player: PlayerController) -> void:
	await physics_frame
	paused = false
	player.step_movement(DT, 0, false, false, false)


func _save_pair(image: Image, name: String, scale: int) -> void:
	_save(image, name + "_native")
	var enlarged := image.duplicate() as Image
	enlarged.resize(image.get_width() * scale, image.get_height() * scale, Image.INTERPOLATE_NEAREST)
	_save(enlarged, name + "_enlarged")


func _save(image: Image, name: String) -> void:
	if image.save_png(REVIEW + name + ".png") != OK:
		push_error("Could not save " + name)
