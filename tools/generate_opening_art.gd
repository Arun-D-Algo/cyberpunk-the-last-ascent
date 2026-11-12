extends "res://tools/generate_art.gd"
## Original 03A raster source. Every output pixel is authored at world density.
const PINK := Color("f02d87")
const OUT := "res://assets/environment/opening/"
const TYPES := ["booth", "cargo", "canopy", "beam", "cabinet", "duct", "fan", "transformer", "lift"]

func _initialize() -> void:
	_machines()
	_wall()
	_city()
	for zone in 3:
		_infrastructure(zone)
	print("Opening environment art generated")
	quit()

func _machines() -> void:
	art = Image.create_empty(64, 32 * TYPES.size(), false, Image.FORMAT_RGBA8)
	for index in TYPES.size():
		var y := index * 32
		panel(0, y, 64, 16)
		rect(0, y, 64, 1, LIGHT)
		rect(1, y + 1, 62, 1, EDGE)
		match TYPES[index]:
			"booth":
				rect(4, y + 4, 56, 8, Color("133c50"))
				for x in range(4, 60, 12):
					rect(x, y + 4, 1, 8, EDGE)
					line(x + 2, y + 5, 6, 0, Color("2b6170"))
				rect(26, y + 13, 12, 1, PINK)
			"cargo":
				for x in range(5, 60, 6):
					rect(x, y + 4, 2, 8, EDGE)
				stripes(2, y + 3, 4, 10)
				stripes(58, y + 3, 4, 10)
			"canopy", "beam":
				rect(2, y + 3, 60, 7, DARK)
				for x in range(4, 60, 12):
					line(x, y + 9, 7, -6, EDGE)
				rect(2, y + 10, 60, 1, SLATE)
			"cabinet":
				for x in range(4, 60, 16):
					rect(x, y + 4, 12, 8, DARK)
					rect(x + 2, y + 6, 5, 1, CYAN)
					rect(x + 9, y + 9, 1, 2, LIGHT)
			"duct":
				for x in range(4, 62, 8):
					rect(x, y + 3, 2, 10, SLATE)
					rect(x, y + 4, 1, 8, EDGE)
				line(4, y + 14, 56, 0, EDGE)
			"fan":
				for x in range(4, 60, 12):
					for n in range(2, 10, 2):
						rect(x, y + n + 2, 8, 1, EDGE)
				rect(2, y + 12, 60, 1, SLATE)
			"transformer":
				for x in range(3, 60, 5):
					rect(x, y + 4, 2, 8, EDGE)
					rect(x + 2, y + 4, 1, 8, DARK)
				stripes(4, y + 13, 12, 2)
			"lift":
				rect(5, y + 4, 54, 7, DARK)
				for x in range(7, 58, 8):
					line(x, y + 10, 4, -6, SLATE)
				rect(22, y + 5, 20, 1, PINK)
		panel(0, y + 16, 64, 16)
		for x in range(4, 60, 5):
			rect(x, y + 17, 2, 12, EDGE)
			rect(x + 2, y + 17, 1, 12, DARK)
		rect(4, y + 30, 56, 1, SLATE)
		for x in [2, 61]:
			rect(x, y + 2, 1, 1, LIGHT)
	_save(OUT + "machinery.png")

func _city() -> void:
	art = Image.create_empty(320, 2304, false, Image.FORMAT_RGBA8)
	art.fill(NAVY)
	for y in range(0, 2304, 192):
		for column in 8:
			var x := column * 43 - 10
			var height := 80 + (column * 37 + y) % 100
			rect(maxi(0, x), y + 192 - height, mini(32, 320 - maxi(0, x)), height, Color("101526"))
			for wy in range(y + 200 - height, y + 188, 9):
				for wx in range(maxi(0, x + 4), mini(320, x + 30), 7):
					if (wx + wy) % 5 != 0:
						rect(wx, wy, 2, 1, Color("273047"))
			if column % 3 == 0:
				rect(maxi(0, x + 3), y + 196 - height, 1, height - 8, Color("56263f"))
	_save(OUT + "city_depth.png")

func _infrastructure(zone: int) -> void:
	art = Image.create_empty(320, 1024, false, Image.FORMAT_RGBA8)
	for y in range(0, 1024, 128):
		if zone == 0:
			# Recessed facade bays leave an exterior city vista through the middle.
			for x in [18, 238]:
				rect(x, y, 64, 128, Color("101725"))
				rect(x + 3, y, 2, 128, Color("293345"))
				rect(x + 7, y + 8, 49, 105, Color("182232"))
				for slot in range(3):
					rect(x + 11, y + 16 + slot * 28, 40, 18, Color("0b1725"))
					line(x + 11, y + 16 + slot * 28, 39, 0, Color("283c50"))
				rect(x + 59, y, 1, 112, Color("74304e"))
			for x in [87, 228]:
				rect(x, y, 4, 128, Color("152131"))
				rect(x, y + 12, 1, 80, Color("803353"))
		elif zone == 1:
			rect(22, y, 276, 128, Color("101b29"))
			for x in [24, 264]:
				rect(x, y, 26, 128, Color("253345"))
				for seam in range(0, 128, 24):
					rect(x, y + seam, 26, 3, Color("344458"))
			rect(56, y + 10, 200, 4, Color("293747"))
			rect(56, y + 14, 200, 12, Color("162636"))
			for x in [92, 208]:
				_fan_housing(Vector2i(x, y + 76), 35)
			for x in range(62, 258, 16):
				rect(x, y + 116, 8, 2, Color("263a4c"))
		else:
			rect(18, y, 284, 128, Color("0e1827"))
			for x in [32, 188]:
				rect(x, y + 22, 100, 100, Color("1b2a3a"))
				rect(x + 4, y + 26, 92, 2, Color("3a4b5b"))
				for fin in range(8, 94, 7):
					rect(x + fin, y + 36, 3, 72, Color("2d4153"))
					rect(x + fin + 3, y + 36, 2, 72, Color("101c2a"))
				rect(x + 32, y + 52, 36, 29, Color("152131"))
				for cable in range(3):
					rect(x + 16 + cable * 32, y, 6, 22, Color("293d4b"))
					for ring in range(4, 20, 4):
						rect(x + 13 + cable * 32, y + ring, 12, 2, Color("3b4b57"))
			rect(148, y, 16, 128, Color("25303e"))
			for cable in range(4):
				rect(150 + cable * 3, y, 1, 128, Color("493144"))
		# Architectural sill and recessed corporate uplight.
		rect(18, y + 124, 284, 4, Color("213044"))
		rect(24, y + 122, 32, 1, Color("702842"))
		rect(264, y + 122, 24, 1, Color("702842"))
	_save(OUT + ["facade", "ventilation", "transformers"][zone] + ".png")

func _fan_housing(center: Vector2i, radius: int) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var d := x * x + y * y
			if d <= radius * radius:
				var color := Color("0a1421")
				if d > (radius - 3) * (radius - 3):
					color = Color("304252")
				elif d > (radius - 6) * (radius - 6):
					color = Color("182b3c")
				art.set_pixelv(center + Vector2i(x, y), color)
	for offset in range(-24, 25, 6):
		line(center.x - 24, center.y + offset, 48, 0, Color("1b2a38"))


func _wall() -> void:
	art = Image.create_empty(8, 64, false, Image.FORMAT_RGBA8)
	panel(0, 0, 8, 64)
	rect(0, 0, 1, 64, EDGE)
	for y in range(4, 60, 16):
		rect(2, y, 4, 2, SLATE)
		rect(3, y, 1, 1, LIGHT)
	_save(OUT + "wall.png")
