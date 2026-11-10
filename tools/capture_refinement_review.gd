extends SceneTree
## Staged actual Compatibility renders. These are visual QA, not human traversal.
const REVIEW: String = "res://docs/visual-review/milestone-02d/"

func _initialize() -> void:
	call_deferred("_run")

func _settle() -> void:
	paused = false
	for frame: int in 8:
		await process_frame
		paused = false
	await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(REVIEW + name + ".png")
	if error != OK:
		push_error("Capture failed: " + error_string(error))

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(REVIEW)
	var boot: Node = preload("res://scenes/main/boot.tscn").instantiate()
	root.add_child(boot)
	await _settle()
	_save("boot")
	boot.free()
	var tower: TowerAscent = preload("res://scenes/levels/tower_ascent.tscn").instantiate()
	root.add_child(tower)
	tower.player.accepts_live_input = false
	for zone: int in 4:
		var row: Dictionary = tower.route[zone * 15 + 6]
		tower.player.reset_movement(Vector2(row.rect.get_center().x, row.rect.position.y))
		for tick: int in 10:
			await physics_frame
			tower.player.step_movement(1.0 / 60.0, 0, false, false, false)
		tower.camera.reset_tracking()
		tower._update_zone(0)
		await _settle()
		_save("floor_%d" % (zone + 1))
	tower.hud.toggle_debug()
	await _settle()
	_save("debug")
	tower.free()
	var lab: PhysicsLab = preload("res://scenes/levels/physics_lab.tscn").instantiate()
	root.add_child(lab)
	lab.player.accepts_live_input = false
	for section: int in [7, 13, 16]:
		lab.select_section(section)
		await _settle()
		for tick: int in 10:
			await physics_frame
			lab.player.step_movement(1.0 / 60.0, 0, false, false, false)
		await _settle()
		_save("lab_%d" % section)
	print("PASS: staged 960x540 refinement views captured")
	quit()
