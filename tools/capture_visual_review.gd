extends SceneTree
## Actual Compatibility-rendered views, with staged player positions for composition review.
## No simulated screenshot artwork. All resizing uses nearest-neighbor integer scales.

const REVIEW: String = "res://docs/visual-review/milestone-02a/"
const CHAMBER: PackedScene = preload("res://scenes/regions/sublevel_zero/emergency_power_chamber.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(REVIEW)
	var chamber: EmergencyPowerChamber = CHAMBER.instantiate() as EmergencyPowerChamber
	root.add_child(chamber)
	current_scene = chamber
	chamber.player.accepts_live_input = false
	# Stable art review clocks and no focus-dependent pause while rendering offline.
	chamber.set_process_unhandled_input(false)
	await process_frame
	for fixture: IndustrialFixture in chamber.fixtures:
		fixture.animation_enabled = false
	chamber.get_node("Titles").hide()
	await _settle_player(chamber)
	var initial: bool = OS.get_cmdline_user_args().has("--initial-art")
	await _settle_render()
	var image: Image = root.get_texture().get_image()
	if initial:
		_save(image, "before_start")
		print("PASS: initial actual-scene view captured")
		quit()
		return
	_save(image, "starting_area")
	var hud: Image = image.get_region(Rect2i(0, 0, 320, 25))
	hud.resize(960, 75, Image.INTERPOLATE_NEAREST)
	hud.save_png(REVIEW + "hud_closeup.png")
	for view: Array in [["mid_climb", Vector2(186, -40)], ["upper_room", Vector2(210, -144)]]:
		chamber.player.reset_movement(view[1])
		chamber.camera.reset_tracking()
		await _settle_player(chamber)
		await _settle_render()
		_save(root.get_texture().get_image(), view[0])
	# A second actual scene rendered at native pixel density with a wider vertical lens.
	var overview: SubViewport = SubViewport.new()
	overview.size = Vector2i(320, 420)
	overview.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	overview.transparent_bg = false
	overview.world_2d = World2D.new()
	root.add_child(overview)
	var room: EmergencyPowerChamber = CHAMBER.instantiate() as EmergencyPowerChamber
	overview.add_child(room)
	room.player.accepts_live_input = false
	room.camera.enabled = false
	room.hud.hide()
	room.get_node("Titles").hide()
	overview.canvas_transform = Transform2D(0.0, Vector2(0, 240))
	await _settle_render()
	_save(overview.get_texture().get_image(), "full_room")
	var before: Image = Image.load_from_file(REVIEW + "before_start.png")
	var after: Image = Image.load_from_file(REVIEW + "starting_area.png")
	if before != null:
		var comparison: Image = Image.create(640, 180, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(before, Rect2i(0, 0, 320, 180), Vector2i.ZERO)
		comparison.blit_rect(after, Rect2i(0, 0, 320, 180), Vector2i(320, 0))
		comparison.resize(1280, 360, Image.INTERPOLATE_NEAREST)
		comparison.save_png(REVIEW + "before_after_2x.png")
	var atlas: Image = IndustrialArt.ATLAS.get_image()
	atlas.resize(768, 768, Image.INTERPOLATE_NEAREST)
	atlas.save_png(REVIEW + "atlas_3x.png")
	print("PASS: actual-scene visual review package captured")
	quit()


func _settle_player(chamber: EmergencyPowerChamber) -> void:
	paused = false
	for tick: int in 8:
		await physics_frame
		chamber.player.step_movement(1.0 / 60.0, 0, false, false, false)


func _settle_render() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw


func _save(pixels: Image, name: String) -> void:
	assert(pixels.save_png(REVIEW + name + ".png") == OK)
	var preview: Image = pixels.duplicate()
	preview.resize(pixels.get_width() * 3, pixels.get_height() * 3, Image.INTERPOLATE_NEAREST)
	assert(preview.save_png(REVIEW + name + "_3x.png") == OK)
