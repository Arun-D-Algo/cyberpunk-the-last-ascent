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
    "..ooo.oooooo...oo.", ".oMmoomMMMMMoooMmo", ".omooMMMMMMMMoommo",
    ".omohMMMMMpphommo", ".omhMMMppppPphmmo.",
    ".omhMMpopoepPommo.", ".omhMsppeppPPommo.",
    ".omohspPpspPPommo.", ".ohmoopPpoppohmho.",
    ".ohmooosppoo.omho.", "..oo...oRro..ooo..",
]
COAT = [
    "...ooJo....oJoo...", "..oJkooRRrooJJo..",
    ".oJkJJoRRpoJJJJo.", "oJkJJJoPpoJJJJJJo",
    "oJJJJJjoojJJJkJJo", "oJkJJjoJJjoJJkJJo",
    "oJkJJjoJJJojJJJjo", "oJJJjoJJJJoJJJJjo",
    "ojJJjoJJkJojJJjjo", ".oggooJkJJjoggoo.",
    ".oBRbojjJJooRrro.", ".obBbooggggoRrro.",
    "..ooo.ooooo.ooo..",
]
LEGS = [
    ".opppo..opspo.", ".oppPo..oppPo.", ".opRPo..oppPo.",
    ".opspo..opsPo.", ".oppo....oppo.", ".oppo....oppo.",
    ".opso....opso.", ".oggo....oggo.", ".oJjoo...oJjoo",
    "oJJjko..oJJjko", "ogkkgo..ogkkgo", ".oooo....oooo.",
]

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
    draw(cell, 13, 26, LEGS)
    coat = COAT.copy()
    if name == "confident":
        for row in range(6, len(coat)):
            coat[row] = coat[row][:12]
    if name == "annoyed":
        coat[10:] = ["....ojjjJJoo.....", "....ooggggo......", ".....ooooo......."]
    draw(cell, 11, 17 - lift, coat)
    head = HEAD.copy()
    if name == "confident":
        head[8] = ".ohmoopPpoPpohmho."
        draw(cell, 22, 15, [".....oooo", "....oRRro", "...oRrRro", "...oRrroo", "...oorro.", "..oggoo..", ".oJJJo...", "oJkJJo...", "oJJjoo..."])
    if name == "annoyed":
        head[5] = ".omhMopopeoPPommo."
        head[8] = ".ohmoopPooppohmho."
        draw(cell, 12, 22, ["..ooooooo.....", ".oJkJJJJJoooo.", "oJJJJBBooRRro.", "ojJJJbboRRrroo", ".ooooooJjoooo.", "......oooo...."])
        draw(cell, 16, 25, ["oBbo", "obBo", ".oo."])
    if frame == 2 and name == "idle":
        head[9] = ".ohmooosppoo.ohho."
    draw(cell, 11 + int(name == "confident"), 9 - lift, head)
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
