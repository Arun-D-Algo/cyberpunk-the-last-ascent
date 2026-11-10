extends SceneTree
## Original pixel artwork. Integer coordinates, fixed palette, no downloaded inputs.
## Rebuild: godot --headless --path . --script res://tools/generate_art.gd

const NAVY: Color = Color("080d18")
const DARK: Color = Color("101a29")
const STEEL: Color = Color("172638")
const SLATE: Color = Color("34475a")
const EDGE: Color = Color("536779")
const CYAN: Color = Color("00d9e8")
const YELLOW: Color = Color("f5d547")
const MAGENTA: Color = Color("f04775")
const LIGHT: Color = Color("a9c4cc")
var art: Image


func _initialize() -> void:
	_atlas()
	_backgrounds()
	_player()
	_effects()
	_font()
	print("PASS: original pixel assets rebuilt")
	quit()


func rect(x: int, y: int, w: int, h: int, color: Color) -> void:
	art.fill_rect(Rect2i(x, y, w, h), color)


func line(x: int, y: int, dx: int, dy: int, color: Color) -> void:
	var count: int = maxi(absi(dx), absi(dy))
	for n: int in range(count + 1):
		var t: float = float(n) / maxf(count, 1)
		var point: Vector2i = Vector2i(x + roundi(dx * t), y + roundi(dy * t))
		# Background braces intentionally cross the canvas; clip their raster footprint.
		if Rect2i(Vector2i.ZERO, art.get_size()).has_point(point):
			art.set_pixelv(point, color)


func panel(x: int, y: int, w: int, h: int) -> void:
	rect(x, y, w, h, NAVY)
	rect(x + 1, y + 1, w - 2, h - 2, SLATE)
	rect(x + 2, y + 3, w - 4, h - 4, STEEL)
	for px: int in [x + 3, x + w - 4]:
		for py: int in [y + 3, y + h - 4]:
			rect(px, py, 1, 1, EDGE)


func stripes(x: int, y: int, w: int, h: int) -> void:
	rect(x, y, w, h, YELLOW)
	for py: int in h:
		for px: int in w:
			if (px + py) % 8 < 4:
				rect(x + px, y + py, 1, 1, STEEL)


func _save(path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	assert(art.save_png(path) == OK, "Could not save " + path)


func _atlas() -> void:
	art = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	# A 16px structural vocabulary; topmost pixel is always the true contact line.
	for tile: int in 4:
		var x: int = tile * 16
		panel(x, 0, 16, 16)
		rect(x, 0, 16, 1, LIGHT)
		rect(x + 1, 2, 14, 2, SLATE)
		for px: int in range(2, 15, 3):
			rect(x + px, 6, 1, 1, EDGE)
			line(x + px, 9, 0, 3, NAVY)
		if tile == 1 or tile == 3:
			stripes(x + 1, 3, 14, 3)
		if tile == 2:
			line(x + 2, 5, 11, 8, EDGE)
	# Reinforced wall, support girder, pipe and actuator.
	panel(0, 32, 32, 64)
	for y: int in range(40, 90, 12):
		rect(5, y, 22, 1, DARK)
		line(5, y + 2, 6, 5, SLATE)
	panel(32, 32, 16, 64)
	for y: int in range(36, 94, 14):
		line(35, y, 9, 10, EDGE)
		line(44, y, -9, 10, DARK)
	rect(49, 32, 13, 64, NAVY)
	rect(51, 32, 9, 64, SLATE)
	rect(52, 32, 2, 64, EDGE)
	rect(58, 32, 2, 64, STEEL)
	for y: int in [37, 64, 88]:
		rect(48, y, 16, 5, DARK)
		rect(49, y, 14, 1, EDGE)
	panel(48, 96, 16, 64)
	rect(54, 100, 4, 44, LIGHT)
	rect(54, 100, 1, 44, Color("e0d9b5"))
	for y: int in [99, 142, 149]:
		rect(50, y, 12, 4, SLATE)
	# Railing: dark and segmented, unlike a solid ledge.
	for x: int in [1, 15, 29]:
		rect(x, 113, 2, 15, SLATE)
	rect(0, 113, 32, 2, EDGE)
	rect(0, 121, 32, 1, SLATE)
	# Generator: original 96x160 ribbed alternator with off-center core.
	panel(68, 3, 88, 153)
	for y: int in range(12, 150, 16):
		rect(64, y, 96, 9, DARK)
		rect(67, y, 90, 2, SLATE)
		rect(71, y + 2, 82, 1, EDGE)
		rect(66, y + 8, 92, 1, NAVY)
	rect(80, 4, 64, 145, NAVY)
	rect(83, 8, 58, 138, STEEL)
	for x: int in range(88, 140, 8):
		rect(x, 10, 3, 132, SLATE)
		rect(x + 1, 10, 1, 132, EDGE)
	for y: int in [22, 62, 114]:
		rect(77, y, 70, 12, DARK)
		rect(78, y, 68, 2, SLATE)
		rect(90, y + 5, 42, 2, Color("167283"))
		rect(96, y + 5, 28, 1, CYAN)
	panel(93, 78, 38, 26)
	rect(99, 83, 26, 13, Color("073a4b"))
	for x: int in range(101, 124, 3):
		rect(x, 85, 1, 8, CYAN if x % 2 else Color("26828d"))
	stripes(80, 146, 64, 6)
	rect(73, 153, 80, 5, NAVY)
	# Access door, service sign, monitor, cables and fixtures.
	panel(160, 0, 48, 64)
	panel(165, 5, 38, 54)
	rect(183, 7, 2, 49, NAVY)
	for y: int in range(12, 52, 8):
		line(168, y, 12, 5, SLATE)
		line(199, y, -12, 5, SLATE)
	rect(188, 29, 3, 8, YELLOW)
	stripes(164, 58, 40, 4)
	panel(160, 64, 48, 24)
	stripes(162, 66, 44, 4)
	rect(164, 74, 20, 2, YELLOW)
	rect(164, 79, 34, 1, EDGE)
	panel(160, 96, 32, 24)
	rect(164, 99, 24, 14, Color("074451"))
	for y: int in range(101, 112, 3):
		rect(166, y, 12 + y % 5, 1, CYAN)
	rect(171, 120 - 3, 10, 3, SLATE)
	for c: int in range(4):
		var x: int = 210 + c * 7
		line(x, 0, 0, 21 + c * 5, NAVY)
		line(x + 1, 0, 0, 21 + c * 5, SLATE)
		line(x + 1, 21 + c * 5, -5, 16, SLATE)
		line(x - 4, 37 + c * 5, 3, 11, SLATE)
	panel(208, 80, 32, 32)
	line(212, 84, 8, 9, NAVY)
	line(220, 93, -3, 10, NAVY)
	line(219, 92, 9, 5, EDGE)
	panel(208, 112, 32, 32)
	for x: int in [213, 221, 229]:
		rect(x, 115, 3, 26, EDGE)
		rect(x + 2, 115, 1, 26, DARK)
	rect(160, 128, 32, 8, DARK)
	rect(162, 130, 28, 3, Color("167283"))
	rect(164, 130, 24, 1, Color("b5f6e6"))
	for x: int in [192, 208]:
		panel(x, 128, 16, 16)
		rect(x + 4, 132, 8, 6, YELLOW if x == 192 else MAGENTA)
	panel(160, 144, 32, 16)
	for y: int in range(148, 157, 3):
		rect(164, y, 24, 1, NAVY)
	# Fan housing, electrical switchboard, sloped control desk.
	_fan(0, 144, 0)
	panel(0, 176, 32, 32)
	for y: int in [182, 190, 198]:
		rect(5, y, 13, 3, DARK)
		rect(23, y, 3, 2, CYAN if y != 190 else MAGENTA)
	panel(0, 208, 48, 32)
	rect(4, 212, 40, 14, DARK)
	rect(7, 214, 21, 9, Color("084653"))
	for y: int in [216, 219, 222]:
		rect(9, y, 12 + y % 5, 1, CYAN)
	for x: int in range(32, 42, 4):
		rect(x, 216, 2, 2, YELLOW)
	stripes(5, 230, 38, 4)
	_save("res://assets/environment/industrial/industrial_atlas.png")


func _fan(x: int, y: int, frame: int) -> void:
	panel(x, y, 32, 32)
	for py: int in range(3, 29):
		for px: int in range(3, 29):
			var distance: float = Vector2(px - 16, py - 16).length()
			if distance < 12:
				rect(x + px, y + py, 1, 1, DARK)
			if distance >= 10 and distance < 11:
				rect(x + px, y + py, 1, 1, EDGE)
	for blade: int in 4:
		var angle: float = float(blade) * PI / 2.0 + frame * PI / 8.0
		for radius: int in range(3, 10):
			var point: Vector2 = Vector2.from_angle(angle + radius * 0.05) * radius
			rect(x + 15 + roundi(point.x), y + 15 + roundi(point.y), 2, 2, SLATE)
	rect(x + 14, y + 14, 4, 4, EDGE)


func _backgrounds() -> void:
	art = Image.create(320, 512, false, Image.FORMAT_RGBA8)
	art.fill(NAVY)
	for x: int in [12, 104, 208, 296]:
		rect(x, 0, 10, 512, Color("0e1826"))
		for y: int in range(0, 512, 48):
			line(x, y, 80, 40, Color("111e2b"))
	for y: int in range(0, 512, 64):
		rect(24, y, 272, 2, Color("13202e"))
		for x: int in range(30, 290, 48):
			rect(x, y + 8, 36, 46, Color("0b1320"))
			for slit: int in range(4):
				rect(x + 4, y + 16 + slit * 6, 28, 2, Color("101e2b"))
	_save("res://assets/environment/backgrounds/shaft_far.png")
	art = Image.create(320, 512, false, Image.FORMAT_RGBA8)
	for x: int in [28, 278]:
		rect(x, 0, 8, 512, Color("1b3040"))
		rect(x + 1, 0, 1, 512, Color("294353"))
		for y: int in range(8, 512, 32):
			rect(x - 2, y, 12, 4, Color("253c4b"))
	for y: int in [70, 230, 390]:
		rect(36, y, 240, 14, Color("122332"))
		rect(36, y + 1, 240, 1, Color("294050"))
		for x: int in range(40, 270, 16):
			line(x, y + 4, 8, 7, Color("203644"))
	_save("res://assets/environment/backgrounds/shaft_mid.png")


func _player() -> void:
	art = Image.create(96, 32, false, Image.FORMAT_RGBA8)
	for frame: int in 6:
		var x: int = frame * 16
		# Feet remain at row31. Original maintenance-runner placeholder, not final character art.
		rect(x + 5, 6, 7, 6, NAVY)
		rect(x + 6, 7, 5, 4, Color("ca9875"))
		rect(x + 5, 5, 7, 3, Color("242838"))
		rect(x + 10, 8, 3, 2, CYAN)
		rect(x + 4, 12, 9, 10, Color("ad872f"))
		rect(x + 5, 12, 7, 2, YELLOW)
		rect(x + 3, 13, 3, 8, Color("c4a144"))
		rect(x + 4, 14, 1, 6, LIGHT)
		rect(x + 12, 14, 2, 7, STEEL)
		rect(x + 11, 19, 3, 2, Color("ca9875"))
		rect(x + 5, 22, 3, 8, STEEL)
		rect(x + 9, 22, 3, 8, DARK)
		rect(x + 4, 29, 4, 3, EDGE)
		rect(x + 9, 29, 4, 3, EDGE)
		rect(x + 4, 31, 4, 1, CYAN)
		if frame == 1:
			rect(x + 9, 27, 4, 5, Color(0, 0, 0, 0))
			rect(x + 11, 25, 3, 4, STEEL)
		if frame == 2:
			rect(x + 1, 15, 2, 8, CYAN)
			rect(x + 2, 23, 12, 1, YELLOW)
		if frame == 3:
			rect(x + 12, 12, 2, 6, LIGHT)
		if frame == 4:
			rect(x + 1, 13, 2, 5, LIGHT)
		if frame == 5:
			rect(x + 3, 31, 12, 1, LIGHT)
	_save("res://assets/player/maintenance_runner.png")


func _effects() -> void:
	art = Image.create(128, 64, false, Image.FORMAT_RGBA8)
	for frame: int in 4:
		_fan(frame * 32, 0, frame)
		var x: int = frame * 16
		if frame < 3:
			line(x + 7, 39, 3 + frame, -3, YELLOW)
			line(x + 7, 39, -2, 4 + frame, CYAN)
			rect(x + 6, 38, 2, 2, LIGHT)
		for n: int in 3:
			rect(x + 4 + (n + frame) % 4, 61 - n * 3 - frame, 4 + n, 1, Color("516776", 0.28))
	_save("res://assets/environment/effects/effects_atlas.png")


func _font() -> void:
	# Hand-authored 3x5 diagnostic alphabet. No external font dependency.
	var glyphs: Dictionary = {
		"A":"010101111101101", "B":"110101110101110", "C":"011100100100011", "D":"110101101101110",
		"E":"111100110100111", "F":"111100110100100", "G":"011100101101011", "H":"101101111101101",
		"I":"111010010010111", "J":"001001001101010", "K":"101101110101101", "L":"100100100100111",
		"M":"101111111101101", "N":"101111111111101", "O":"010101101101010", "P":"110101110100100",
		"Q":"010101101111011", "R":"110101110101101", "S":"011100010001110", "T":"111010010010010",
		"U":"101101101101111", "V":"101101101101010", "W":"101101111111101", "X":"101101010101101",
		"Y":"101101010010010", "Z":"111001010100111", "0":"111101101101111", "1":"010110010010111",
		"2":"110001010100111", "3":"110001010001110", "4":"101101111001001", "5":"111100110001110",
		"6":"011100111101111", "7":"111001010010010", "8":"111101111101111", "9":"111101111001110",
		"-":"000000111000000", ".":"000000000000010", ":":"000010000010000", "/":"001001010100100",
		"%":"101001010100101", "+":"000010111010000", "|":"010010010010010", "_":"000000000000111",
		"<":"001010100010001", ">":"100010001010100", "?":"110001010000010", "=":"000111000111000"
	}
	art = Image.create(128, 64, false, Image.FORMAT_RGBA8)
	var font: String = "info face=\"Industrial Micro\" size=7\ncommon lineHeight=8 base=6 scaleW=128 scaleH=64 pages=1 packed=0\npage id=0 file=\"industrial_micro.png\"\nchars count=95\n"
	for code: int in range(32, 127):
		var index: int = code - 32
		var x: int = (index % 24) * 5
		var y: int = (index / 24) * 8
		var glyph: String = glyphs.get(String.chr(code).to_upper(), "000000000000000")
		for py: int in 5:
			for px: int in 3:
				if glyph[py * 3 + px] == "1":
					rect(x + px, y + py, 1, 1, Color.WHITE)
		font += "char id=%d x=%d y=%d width=3 height=5 xoffset=0 yoffset=1 xadvance=4 page=0 chnl=15\n" % [code, x, y]
	_save("res://assets/ui/industrial_micro.png")
	var file: FileAccess = FileAccess.open("res://assets/ui/industrial_micro.fnt", FileAccess.WRITE)
	file.store_string(font)
