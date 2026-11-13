extends SceneTree
## Generate native and nearest-neighbor review strips from the imported resources.
const REBECCA: SpriteFrames = preload("res://resources/visuals/rebecca_frames.tres")
const DAVID: SpriteFrames = preload("res://resources/visuals/david_frames_cinematic.tres")
const OUT := "res://docs/visual-review/rebecca-prototype/"
const SIZE := Vector2i(40, 40)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var idle: Array[Image] = []
	for index in REBECCA.get_frame_count(&"idle"):
		idle.append(_key(REBECCA, &"idle", index))
	assert(idle.size() == 4 and REBECCA.get_animation_loop(&"idle"))
	for index in idle.size():
		var next := (index + 1) % idle.size()
		assert(idle[index].get_data() != idle[next].get_data())
		for y in range(31, SIZE.y):
			for x in SIZE.x:
				var pixel := idle[index].get_pixel(x, y)
				var neutral := idle[0].get_pixel(x, y)
				assert((pixel.a == 0 and neutral.a == 0) or pixel == neutral)
	var sprite := AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.sprite_frames = REBECCA
	sprite.offset = Vector2(0, -18)
	root.add_child(sprite)
	sprite.play(&"idle")
	await create_timer(0.55).timeout
	assert(sprite.is_playing() and sprite.frame > 0)
	await create_timer(0.4).timeout
	assert(sprite.is_playing() and sprite.frame == 0)
	var original := Image.load_from_file(OUT + "original_neutral.png")
	assert(original.get_size() == SIZE)
	_strip("before_after", [original, idle[0]])
	_save_pair("face_detail", idle[0].get_region(Rect2i(10, 8, 20, 13)))
	_save_pair("hands_detail", idle[0].get_region(Rect2i(8, 21, 25, 11)))
	_strip("standing", [idle[0]])
	_strip("facing", [_key(REBECCA, &"left", 0), idle[0]])
	_strip("idle", idle)
	_strip("confident", [_key(REBECCA, &"confident", 0)])
	_strip("annoyed", [_key(REBECCA, &"annoyed", 0)])
	var david := _key(DAVID, &"idle", 0)
	_strip("david_standing", [david])
	_strip("scale", [david, idle[0]])
	var atlas := (REBECCA.get_frame_texture(&"idle", 0) as AtlasTexture).atlas.get_image()
	assert(atlas.get_size() == Vector2i(160, 80) and not atlas.has_mipmaps())
	_save_pair("sheet", atlas)
	print("Rebecca atlas, frame bounds, and idle playback verified")
	quit()

func _key(frames: SpriteFrames, animation: StringName, index: int) -> Image:
	var frame := frames.get_frame_texture(animation, index) as AtlasTexture
	assert(Vector2i(frame.region.size) == SIZE)
	var key := frame.atlas.get_image().get_region(Rect2i(frame.region))
	assert(key.get_used_rect().end.y == 38)
	return key

func _strip(name: String, keys: Array[Image]) -> void:
	var strip := Image.create_empty(keys.size() * SIZE.x, SIZE.y, false, Image.FORMAT_RGBA8)
	strip.fill(Color("263245"))
	for index in keys.size():
		strip.blend_rect(keys[index], Rect2i(Vector2i.ZERO, SIZE), Vector2i(index * SIZE.x, 0))
	_save_pair(name, strip)

func _save_pair(name: String, image: Image) -> void:
	assert(image.save_png(OUT + name + "_native.png") == OK)
	image.resize(image.get_width() * 4, image.get_height() * 4, Image.INTERPOLATE_NEAREST)
	assert(image.save_png(OUT + name + "_4x.png") == OK)
