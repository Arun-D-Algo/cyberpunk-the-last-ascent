extends "res://tests/physics_test.gd"

const FRAMES: SpriteFrames = preload("res://resources/visuals/david_frames.tres")
const EXPECTED := {"idle": 3, "walk": 6, "charge": 4, "launch": 2, "rise": 2,
	"fall": 2, "land": 2, "slide": 2, "impact": 2}

func _run() -> void:
	_check_frames()
	await _check_playback()
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
			check(texture.region.size == Vector2(24, 40), "Frame size for " + name)
			var pixels := texture.atlas.get_image().get_region(Rect2i(texture.region))
			if name in ["idle", "walk", "charge", "land", "slide"]:
				var planted := false
				for x in pixels.get_width():
					planted = planted or pixels.get_pixel(x, 37).a > 0.0
				check(planted, "Grounded key uses the planted sole baseline")
			var key := hash(pixels.get_data())
			check(key not in pixel_keys, "Distinct authored frame for " + name)
			pixel_keys.append(key)

func _check_playback() -> void:
	await _new_fixture()
	var sprite: AnimatedSprite2D = body.get_node("Visual/David")
	check(sprite.animation == &"idle", "Grounded at rest is idle")
	var idle_frame := sprite.frame
	await _ticks(22)
	check(sprite.animation == &"idle" and sprite.frame != idle_frame, "Idle advances")
	await _ticks(10, -1)
	check(sprite.animation == &"walk" and sprite.flip_h, "Walking follows left facing")
	var walk_frame := sprite.frame
	await _ticks(8, -1)
	check(sprite.frame != walk_frame, "Walk advances with ground travel")
	await _tick(1, true, true)
	check(sprite.animation == &"charge" and sprite.frame == 0 and not sprite.flip_h,
		"Fresh charge starts at first pose and faces right")
	await _charge(0.8, 1)
	check(sprite.animation == &"charge" and sprite.frame == 3, "Full charge holds the final pose")
	await _tick(1, false, false, true)
	check(sprite.animation == &"launch" and body.velocity.y < 0.0, "Launch pose observes immediate impulse")
	var poses: Array[StringName] = []
	for tick in 70:
		await _tick()
		if sprite.animation not in poses:
			poses.append(sprite.animation)
	check(&"rise" in poses and &"fall" in poses and &"land" in poses and &"idle" in poses,
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
