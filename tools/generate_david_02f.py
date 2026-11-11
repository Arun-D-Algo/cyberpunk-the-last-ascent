"""Author and export the 02F David sprites on the native pixel grid."""
from pathlib import Path
from generate_david import write_png

ROOT = Path(__file__).resolve().parents[1]
WIDTH, HEIGHT = 32, 40
COLUMNS = 6
PALETTE = {
    "o": "151524", "h": "33232e", "b": "68423d", "s": "9d5d52",
    "t": "ce8665", "f": "f2af83", "l": "ffe1ad", "k": "252435",
    "d": "23384e", "p": "355773", "P": "52829d", "v": "8cabb7",
    "c": "2589a6", "C": "62d5e2", "a": "a16424", "j": "db942d",
    "y": "f4c442", "Y": "ffe76b", "w": "e8e8da", "r": "ed6355",
}
HEAD = [
    "....o..o....", "...oh.oho...", "..ohhohhho..", ".ohhbbhhho..",
    "ohhbbbhhho..", "ohbbhhhhto..", ".osbshttfo..",
    ".otsfokffo..", "..otsffflto.", "...ottftto..", "....ottso...",
    ".....oto....",
]
JACKET = [
    "..oocCoo.oo......", ".ocCCcoooCco.....", "oYyyCCokocYYyoo..",
    "oYyyyjokoyYyyjo..", "oyYyyjokoyyyyjo..", "oyyyyjoloyYyajo..",
    "ojyyyjokoyyyajo..", "ovwwwvokovwwvo...", "ojyyyjokoyyajo...",
    ".ojyyjokoyajo....", "..oajjokoyao.....", "...ooooooo.......",
]
ARMS = {
    "hang": [".oYYo.", "oyYyjo", "oyyyjo", "ojyyjo", "ovwwvo", "ojyyjo", ".otto.", ".otso."],
    "brace": ["..oYYo...", ".oyyYyo..", "ojyyYyjo.", "ovwwvYyjo", ".oajjytoo", "..oottso.", "....ooo.."],
    "reach": ["..oYYoo....", ".oyyYjYoo..", "ojyjyYyyjoo", "ovwwvjjttfo", ".ooaootssoo", "......ooo.."],
    "back": [".oyyo", "ojyjo", "oyyjo", "ovwvo", "ojjoo", ".oto.", ".oso."],
}

# Each key authors the torso offset, independent sleeve placements, and a pair
# of trousers. A leg uses hip, knee and boot X, followed by the sole row.
POSES = {
    "idle": (5, [
        (0, 0, "hang", 7, 19, "back", 22, 18, (14, 13, 12, 37), (19, 20, 21, 37)),
        (0, -1, "hang", 7, 18, "back", 22, 17, (14, 13, 12, 37), (19, 20, 21, 37)),
        (0, -2, "hang", 7, 17, "back", 22, 16, (14, 13, 12, 37), (19, 20, 21, 37)),
        (0, -1, "hang", 7, 18, "back", 22, 18, (14, 13, 12, 37), (19, 20, 21, 37)),
    ]),
    "walk": (10, [
        (0, 0, "brace", 6, 19, "back", 23, 19, (14, 11, 8, 37), (19, 22, 25, 37)),
        (1, -1, "hang", 8, 18, "brace", 20, 19, (15, 12, 11, 35), (20, 22, 23, 37)),
        (0, -1, "hang", 8, 18, "back", 22, 18, (14, 15, 16, 37), (19, 22, 21, 34)),
        (0, 0, "reach", 7, 19, "back", 21, 19, (14, 19, 24, 37), (19, 15, 9, 37)),
        (1, -1, "brace", 9, 19, "back", 22, 18, (15, 20, 21, 37), (20, 16, 13, 35)),
        (0, -1, "brace", 7, 18, "back", 22, 18, (14, 19, 18, 35), (19, 19, 20, 37)),
    ]),
    "charge": (1, [
        (0, 0, "brace", 7, 20, "back", 22, 19, (14, 12, 11, 37), (19, 22, 23, 37)),
        (0, 2, "brace", 7, 22, "brace", 21, 22, (14, 11, 11, 37), (19, 24, 23, 37)),
        (0, 4, "brace", 6, 24, "brace", 21, 24, (14, 9, 11, 37), (19, 25, 23, 37)),
        (1, 6, "brace", 5, 26, "brace", 22, 25, (14, 8, 11, 37), (20, 25, 23, 37)),
    ]),
    "launch": (30, [
        (0, 1, "reach", 8, 17, "back", 22, 15, (14, 12, 11, 37), (19, 21, 23, 36)),
        (1, -3, "reach", 10, 13, "back", 23, 13, (15, 13, 12, 36), (20, 22, 23, 34)),
    ]),
    "rise": (8, [
        (1, -2, "brace", 9, 15, "back", 23, 16, (15, 12, 11, 35), (20, 24, 22, 32)),
        (0, -2, "brace", 8, 16, "back", 22, 17, (14, 11, 10, 34), (19, 23, 21, 31)),
    ]),
    "fall": (8, [
        (0, 0, "reach", 4, 17, "brace", 21, 17, (14, 11, 10, 37), (19, 21, 23, 36)),
        (0, -1, "reach", 3, 16, "brace", 22, 17, (14, 10, 9, 36), (19, 22, 24, 37)),
    ]),
    "land": (30, [
        (1, 5, "brace", 6, 25, "brace", 21, 24, (14, 9, 11, 37), (20, 25, 23, 37)),
        (0, 2, "brace", 7, 22, "back", 22, 20, (14, 11, 11, 37), (19, 23, 23, 37)),
    ]),
    "slide": (7, [
        (0, 2, "reach", 6, 22, "back", 21, 20, (14, 12, 10, 37), (19, 22, 25, 37)),
        (0, 3, "reach", 7, 23, "back", 21, 21, (14, 11, 10, 37), (19, 23, 25, 37)),
    ]),
    "forced": (8, [
        (-2, 5, "reach", 4, 22, "brace", 21, 24, (12, 10, 9, 37), (17, 22, 26, 37)),
        (-2, 4, "reach", 3, 22, "brace", 22, 23, (12, 10, 9, 37), (17, 23, 26, 37)),
    ]),
    "impact": (20, [
        (-2, 1, "reach", 6, 16, "brace", 19, 18, (12, 8, 9, 34), (17, 21, 19, 32)),
        (-1, 1, "brace", 7, 19, "back", 21, 18, (13, 10, 10, 36), (18, 22, 23, 35)),
    ]),
}


def draw_pixels(canvas, width, x, y, rows):
    for row_index, row in enumerate(rows):
        for column, pixel in enumerate(row):
            if pixel == ".":
                continue
            offset = ((y + row_index) * width + x + column) * 4
            canvas[offset:offset + 4] = bytes.fromhex(PALETTE[pixel] + "ff")


def draw_pose(canvas, width, x, y, pose):
    dx, dy, near_arm, nx, ny, far_arm, fx, fy, near_leg, far_leg = pose
    cell = bytearray(WIDTH * HEIGHT * 4)
    draw_pixels(cell, WIDTH, fx - 2, fy, ARMS[far_arm])
    for index, (hip, knee, boot, sole) in enumerate((far_leg, near_leg)):
        top = 25 + dy
        middle = (top + sole - 2) // 2
        cloth = "d" if index == 0 else "p"
        highlight = "p" if index == 0 else "P"
        for row in range(top, sole - 1):
            if row <= middle:
                center = round(hip + (knee - hip) * (row - top) / max(middle - top, 1))
            else:
                center = round(knee + (boot - knee) * (row - middle) / max(sole - 2 - middle, 1))
            span = "o" + cloth + highlight + cloth * 2 + "o"
            if row == sole - 2:
                span = "ov" + cloth * 2 + "o"
            draw_pixels(cell, WIDTH, center - 2, row, [span])
        draw_pixels(cell, WIDTH, boot - 2, sole - 1, ["okvkkko", "oPvwwvo"])
    draw_pixels(cell, WIDTH, 8 + dx, 16 + dy, JACKET)
    draw_pixels(cell, WIDTH, 12 + dx, 6 + dy, HEAD)
    draw_pixels(cell, WIDTH, nx, ny, ARMS[near_arm])
    draw_pixels(cell, WIDTH, 16 + dx, 21 + dy, ["l", "y"])
    for row in range(HEIGHT):
        offset = ((y + row) * width + x) * 4
        canvas[offset:offset + WIDTH * 4] = cell[row * WIDTH * 4:(row + 1) * WIDTH * 4]


def main():
    width = COLUMNS * WIDTH
    height = len(POSES) * HEIGHT
    canvas = bytearray(width * height * 4)
    frame_count = sum(len(poses) for _, poses in POSES.values())
    resource = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        '[ext_resource type="Texture2D" path="res://assets/player/david_martinez_02f.png" id="atlas"]',
    ]
    animations = []
    for row, (name, (fps, poses)) in enumerate(POSES.items()):
        frames = []
        for column, pose in enumerate(poses):
            x, y = column * WIDTH, row * HEIGHT
            draw_pose(canvas, width, x, y, pose)
            frame_id = f"{name}_{column}"
            resource += [f'[sub_resource type="AtlasTexture" id="{frame_id}"]',
                         'atlas = ExtResource("atlas")', f'region = Rect2({x}, {y}, {WIDTH}, {HEIGHT})']
            frames.append(f'{{"duration": 1.0, "texture": SubResource("{frame_id}")}}')
        loop = "true" if name in {"idle", "walk", "rise", "fall", "slide", "forced"} else "false"
        animations.append('{"frames": [' + ", ".join(frames) +
                          f'], "loop": {loop}, "name": &"{name}", "speed": {fps}.0}}')
    write_png(ROOT / "assets/player/david_martinez_02f.png", width, height, canvas)
    resource += ["[resource]", "animations = [" + ",\n".join(animations) + "]"]
    (ROOT / "resources/visuals").mkdir(exist_ok=True)
    (ROOT / "resources/visuals/david_frames_02f.tres").write_text("\n\n".join(resource) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
