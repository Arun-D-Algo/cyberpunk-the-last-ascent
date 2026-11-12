extends "res://tests/physics_test.gd"

const FRAMES: SpriteFrames = preload("res://resources/visuals/david_frames_cinematic.tres")
const EXPECTED := {"idle": 4, "walk": 6, "charge": 4, "launch": 3, "rise": 3, "apex": 1,
	"fall_early": 2, "fall": 3, "fall_fast": 3, "land": 4, "slide": 2, "forced": 2, "impact": 2}

func _run() -> void:
	_check_frames()
	await _check_playback()
	await _check_descent()
	world.free()
	world = null
	for path: String in ["res://scenes/levels/tower_ascent.tscn", "res://scenes/levels/physics_lab.tscn"]:
		var scene: Node = load(path).instantiate()
		root.add_child(scene)
		var player: PlayerController = scene.get_node("Player")
		var sprite: AnimatedSprite2D = player.get_node("Visual/David")
		check(sprite.sprite_frames == FRAMES, "Shared David resource in " + path)
		var collider: CollisionShape2D = player.get_node("CollisionShape2D")
		check(collider.shape.size == Vector2(10, 24) and collider.position == Vector2(0, -12),
			"Approved collider preserved")
		if scene is PhysicsLab:
			body = player
			body.accepts_live_input = false
			scene.select_section(18)
			await process_frame
			await _ticks(30)
			check(body.is_on_floor() and sprite.animation == &"slide", "Lab ramp activates slide in live physics")
			scene.select_section(20)
			await process_frame
			await _ticks(12, -1)
			check(body.state == PlayerController.State.FORCED_SLIDING and sprite.animation == &"forced" and not sprite.flip_h,
				"Committed slide has its own pose and downhill facing")
		scene.free()
	print("Animation checks: %d, failures: %d" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)

func _check_frames() -> void:
	for name: String in EXPECTED:
		var count := FRAMES.get_frame_count(name)
		check(count == EXPECTED[name], "Frame count for " + name)
		var pixel_keys: Array[int] = []
		for index in count:
			var texture: AtlasTexture = FRAMES.get_frame_texture(name, index)
			check(texture.region.size == Vector2(40, 40), "Frame size for " + name)
			var pixels := texture.atlas.get_image().get_region(Rect2i(texture.region))
			if name in ["idle", "walk", "charge", "land", "slide", "forced"]:
				var planted := false
				for x in pixels.get_width():
					planted = planted or pixels.get_pixel(x, 37).a > 0.0
				check(planted, "Grounded key uses the planted sole baseline")
			var bounds := pixels.get_used_rect()
			check(bounds.has_area() and bounds.position.x > 0 and bounds.end.x < 40 and bounds.position.y > 0 and bounds.end.y < 40,
				"Visible pixels leave clear frame padding")
			var key := hash(pixels.get_data())
			check(key not in pixel_keys, "Distinct authored frame for " + name)
			pixel_keys.append(key)

func _check_playback() -> void:
	await _new_fixture()
	var sprite: AnimatedSprite2D = body.get_node("Visual/David")
	check(sprite.animation == &"idle", "Grounded at rest is idle")
	var idle_frame := sprite.frame
	var feet := body.position
	var low: AtlasTexture = FRAMES.get_frame_texture(&"idle", 0)
	var high: AtlasTexture = FRAMES.get_frame_texture(&"idle", 2)
	var low_bounds := low.atlas.get_image().get_region(Rect2i(low.region)).get_used_rect()
	var high_bounds := high.atlas.get_image().get_region(Rect2i(high.region)).get_used_rect()
	check(low_bounds.position.y - high_bounds.position.y == 2 and low_bounds.end.y == high_bounds.end.y,
		"Idle raises the silhouette by two pixels with planted soles")
	await _ticks(22)
	check(sprite.animation == &"idle" and sprite.frame != idle_frame, "Idle advances")
	check(feet.distance_to(body.position) < 0.01, "Idle bob leaves the physics body planted")
	await _ticks(10, -1)
	check(sprite.animation == &"walk" and sprite.flip_h, "Walking follows left facing")
	var walk_frame := sprite.frame
	await _ticks(8, -1)
	check(sprite.frame != walk_frame, "Walk advances with ground travel")
	await _tick(1, true, true)
	check(sprite.animation == &"charge" and sprite.frame == 0 and not sprite.flip_h,
		"Fresh charge starts at first pose and faces right")
	for tick in 14:
		await _tick(1, false, true)
	check(sprite.animation == &"charge" and sprite.frame == 1, "Early compression follows charge progress")
	for tick in 13:
		await _tick(1, false, true)
	check(sprite.animation == &"charge" and sprite.frame == 2, "Deep compression follows charge progress")
	await _charge(0.8, 1)
	check(sprite.animation == &"charge" and sprite.frame == 3, "Full charge holds the final pose")
	await _tick(1, false, false, true)
	check(sprite.animation == &"launch" and body.velocity.y < 0.0, "Launch pose observes immediate impulse")
	var poses: Array[StringName] = []
	for tick in 70:
		await _tick()
		if sprite.animation not in poses:
			poses.append(sprite.animation)
	check(&"rise" in poses and &"apex" in poses and &"fall_early" in poses and &"fall" in poses and &"land" in poses and &"idle" in poses,
		"Rise, fall, land and idle follow a real jump")

	await _new_fixture()
	sprite = body.get_node("Visual/David")
	_solid(Rect2(38, -160, 8, 200))
	await _charge(0.75, 1)
	await _tick(1, false, false, true)
	var impacted := false
	for tick in 30:
		await _tick()
		if body.rebound_count > 0:
			impacted = true
			check(sprite.animation == &"impact" and not sprite.flip_h and body.velocity.x < 0,
				"Impact faces the wall and leaves rebound velocity intact")
			break
	check(impacted, "Observed actual rebound")
	body.reset_movement(Vector2.ZERO)
	check(sprite.animation == &"idle" and sprite.frame == 0 and not sprite.flip_h,
		"Reset clears one-shot pose and facing")
	await _ticks(8)
	world.get_child(0).set_meta("surface_physics", preload("res://resources/surfaces/ice.tres"))
	await _ticks(2)
	body.velocity.x = 65.0
	await _tick()
	check(sprite.animation == &"slide", "Ice coasting activates slide")
	await _ticks(45)
	check(sprite.animation == &"idle", "Slide returns to idle on rest")

func _check_descent() -> void:
	await _new_fixture()
	body.reset_movement(Vector2(0, -480))
	var sprite: AnimatedSprite2D = body.get_node("Visual/David")
	var ordered: Array[StringName] = []
	for tick in 120:
		await _tick()
		var animation := sprite.animation
		if animation not in ordered:
			ordered.append(animation)
		if body.is_on_floor():
			break
	check(ordered == [&"fall_early", &"fall", &"fall_fast", &"land"], "Real long fall plays every phase in order")
	check(sprite.frame == 0, "Hard landing starts at the three-point impact")
	await _ticks(4)
	check(sprite.animation == &"land" and sprite.frame == 1 and body.state == PlayerController.State.GROUNDED,
		"Visual recovery continues after gameplay recovery")
	await _tick(-1, true, true)
	check(sprite.animation == &"charge" and sprite.flip_h, "New charge interrupts visual recovery")
	await _tick(-1, false, false, true)
	check(sprite.animation == &"launch" and body.velocity.y < 0.0, "Short left release launches immediately")
	for tick in 70:
		await _tick()
		if body.state == PlayerController.State.LANDING:
			break
	check(sprite.animation == &"land" and sprite.frame == 2, "Soft landing starts in standing compression")

	body.reset_movement(Vector2(0, -480))
	await _tick()
	# Each solver step adds 15 px/s of gravity, so these samples bracket the bands.
	body.velocity.y = 300.0
	await _tick()
	check(sprite.animation == &"fall_fast", "Fast band enters at 315 px/s")
	body.velocity.y = 285.0
	await _tick()
	check(sprite.animation == &"fall_fast", "Fast band holds across small velocity changes")
	body.velocity.y = 270.0
	await _tick()
	check(sprite.animation == &"fall", "Fast band releases below 291 px/s")
	body.velocity.y = 50.0
	await _tick()
	check(sprite.animation == &"fall", "Normal band holds below its entry threshold")
	body.velocity.y = 25.0
	await _tick()
	check(sprite.animation == &"fall_early", "Normal band releases below 51 px/s")

	_solid(Rect2(38, -550, 8, 500))
	body.reset_movement(Vector2(0, -450))
	body.velocity = Vector2(165, 315)
	var hit := false
	for tick in 25:
		await _tick()
		if sprite.animation == &"impact":
			hit = true
			break
	check(hit and body.state == PlayerController.State.FALLING, "Falling side impact takes visual priority")
	await _ticks(8)
	check(sprite.animation == &"fall_fast", "After impact the sprite resumes the current speed band")
