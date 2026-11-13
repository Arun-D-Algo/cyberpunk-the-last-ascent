"""Draw Rebecca's original 40-pixel pose keys and write the Godot atlas."""
from generate_david import write_png
from generate_david_02f import ROOT

CELL = 40
PALETTE = {
    "o": "141723", "h": "408478", "m": "80bea2", "M": "b6e2bd",
    "s": "a1bfbb", "p": "dbe8d7", "P": "f0f3df", "e": "ee815d",
    "r": "b94664", "R": "e46880", "b": "395c8e", "B": "6fa9c9",
    "j": "22263e", "J": "383e5b", "k": "4d566e", "g": "9aa361",
}
HEAD = [
    "..ooo.oooooo...oo.",
    ".oMmoomMMMMMo.oMmo",
    ".omooMMMMMMMMoommo",
    ".omohMMMpppMhommho",
    ".omhMMpsppPshommho",
    ".omhMpojspojpommho",
    ".omhMpsesppesommho",
    ".omohsppppspoommho",
    ".ohmoosppspooohmho",
    ".ohmo.oospo...omho",
    "..oo...oRro....ooo",
]
COAT = [
    "..ooo....ooo..",
    ".oJkoRrooJko.",
    "oJkJospokJJJo",
    "oJkJjojoJJJJo",
    "ojJJJkoJkJJjo",
    ".oJJJkoJJJjo.",
    ".ojJJjoJJjo..",
    "..oJJkoJJjo..",
    "..ojJJojjjo..",
    ".ogggjjjggo..",
    "..oooooooo...",
]
SLEEVE = [
    "..oo..", ".okJo.", "okJJJo", "oJJJjo", ".oJJjo",
    ".ojjo.", "..ogo.", "..ojo.",
]
FIST = [
    "..ooo..", ".okBkoo", "oBBkBbo", "oBbBbbo", "obobobo", ".obboo.", "..ooo..",
]
LEGS = [
    ".osppo.ospso.", ".ospPo.osppo.", ".osRPo.osppo.",
    ".osppo.osppo.", "..ospo.ospso.", "..ospo.ospso.",
    "..ospo.osppo.", "..oggo.oggo.", ".oJjko.oJjko.",
    "oJJjko.oJJjko", "ogkkgo.ogkkgo", ".oooo...oooo.",
]

def mirrored(rows):
    width = max(map(len, rows))
    return [row.ljust(width, ".")[::-1] for row in rows]

def fist(cell, x, y, warm=False):
    rows = [row.translate(str.maketrans("Bb", "Rr")) for row in FIST] if warm else FIST
    draw(cell, x, y, rows)


def draw(cell, x, y, rows):
    for dy, row in enumerate(rows):
        for dx, pixel in enumerate(row):
            if pixel == ".":
                continue
            assert 0 <= x + dx < CELL and 0 <= y + dy < CELL
            i = ((y + dy) * CELL + x + dx) * 4
            cell[i:i+4] = bytes.fromhex(PALETTE[pixel] + "ff")

def pose(name, frame):
    cell = bytearray(CELL * CELL * 4)
    lift = int(name == "idle" and frame in (1, 2))
    draw(cell, 14, 26, LEGS)
    draw(cell, 14, 18 - lift, COAT)
    draw(cell, 10, 18 - lift, SLEEVE)
    head = HEAD.copy()
    if name == "confident":
        head[8] = ".ohmoosppkpoo" + head[8][13:]
        draw(cell, 25, 20, ["..ogo.", ".oJko.", ".oJJJo", "oJkJjo", "ojJJoo", ".ooo.."])
        fist(cell, 9, 24)
    elif name == "annoyed":
        head[5] = ".omhMpsjopojp" + head[5][13:]
        head[8] = ".ohmoospkppoo" + head[8][13:]
        draw(cell, 24, 18, mirrored(SLEEVE[:6]))
        draw(cell, 13, 23, ["ooooooo...", "ojJJJkJoo.", "oJJkkJJJJo", ".oooooooo."])
        draw(cell, 19, 24, ["..oooooooo", ".oJJJkJJjo", "oJJJJJJJjo", ".oooooooo."])
        fist(cell, 12, 24, warm=True)
        fist(cell, 23, 22)
    else:
        draw(cell, 25, 18 - lift, mirrored(SLEEVE))
        fist(cell, 9, 24 - lift)
        fist(cell, 25, 24 - lift, warm=True)
    if frame == 2 and name == "idle":
        head[9] = head[9][:13] + ".ohho"
    draw(cell, 11, 9 - lift, head)
    if name == "confident":
        fist(cell, 26, 14, warm=True)
    if name == "left":
        for y in range(CELL):
            start = y * CELL * 4
            row = cell[start:start + CELL * 4]
            cell[start:start + CELL * 4] = b"".join(row[x:x+4] for x in range(len(row)-4, -1, -4))
    return cell

def main():
    keys = {"idle": (0, 3), "left": (3, 1), "confident": (4, 1), "annoyed": (5, 1)}
    width = CELL * 3
    sheet = bytearray(width * CELL * 2 * 4)
    resource = ['[gd_resource type="SpriteFrames" load_steps=8 format=3]',
                '[ext_resource type="Texture2D" path="res://assets/player/rebecca.png" id="atlas"]']
    animations = []
    for name, (first, count) in keys.items():
        frames = []
        for frame in range(count):
            index = first + frame
            x, y = index % 3 * CELL, index // 3 * CELL
            cell = pose(name, frame)
            for row in range(CELL):
                start = ((y + row) * width + x) * 4
                sheet[start:start+CELL*4] = cell[row*CELL*4:(row+1)*CELL*4]
            key = f"{name}_{frame}"
            resource.append(f'[sub_resource type="AtlasTexture" id="{key}"]\natlas = ExtResource("atlas")\nregion = Rect2({x}, {y}, 40, 40)')
            duration = [2, 1, 1][frame] if name == "idle" else 1
            frames.append(f'{{"duration": {duration}.0, "texture": SubResource("{key}")}}')
        animations.append('{"frames": [' + ", ".join(frames) +
                          f'], "loop": {str(name == "idle").lower()}, "name": &"{name}", "speed": 5.0}}')
    write_png(ROOT / "assets/player/rebecca.png", width, CELL * 2, sheet)
    resource.append("[resource]\nanimations = [" + ",\n".join(animations) + "]")
    (ROOT / "resources/visuals/rebecca_frames.tres").write_text("\n\n".join(resource) + "\n", encoding="utf-8")

if __name__ == "__main__":
    main()
