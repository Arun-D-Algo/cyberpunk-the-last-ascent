"""Rasterize editable palette-indexed David poses. Python 3, standard library only."""
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
WIDTH, HEIGHT = 24, 40
COLUMNS = 6

PALETTE = {
    "o": "131321", "h": "302030", "b": "57343b", "B": "915c49",
    "s": "a36052", "t": "cf8966", "f": "f2b287", "l": "ffe1ad",
    "d": "222438", "p": "414c66", "P": "687791", "v": "9dafb8",
    "c": "288eae", "C": "63d9e2", "a": "9a591e", "j": "d88c26",
    "y": "f4c442", "Y": "ffe46c", "w": "e1e9e6", "r": "f66a55",
}

# Pixel clusters are aligned to layer origins, with an invariant foot pivot (12, 38).
HEAD = [
    "....o..o....", "...oh.oh....", "..ohhohho...", ".ohhBbhhho..",
    "ohhBbBhhho..", "ohbbhhhho...", "ohsbshtto...", ".osbsfffoo..",
    ".otssfoflo..", "..otstfffto.", "...ottfftoo.", "....otttoo..",
    ".....oto....",
]
TORSO = [
    "...ocCo..o....", "..oCYCo.soo...", ".oYyyjCovjo...",
    "oYyyjjwodYo...", "oYyYyjooYyo...", "oyyyYyoYyjo...",
    "ojyYyyoYajo...", "ovwwwvoYajo...", ".ojyyjodjo....",
    ".oayjjodoo....", "..ojjopoo.....", "...ooooo......",
]
SLEEVE = ["oYYo", "oyyo", "ojyo", "ovwo", "ojyo", ".oto", ".oso"]
BENT_ARM = [".oYo...", "oyyyo..", "ojjyYo.", ".ovwYo.", "..ootso", "....oo."]
REACH_ARM = ["..oYYo.", ".oYyyyo", "oyjvwoo", ".ooyjto", "...ooo."]
BACK_ARM = ["oYo", "oyo", "ojo", "ovo", "oto", ".o."]
LEGS = {
    "rest": ["..odpdo...", "..odpdo...", "..odpdo...", "..odPdo...", "..odPdo...", "..odpdo...", "..odpdo...", "..odpdo...", "..oPvPo...", "..odPdoo..", "..ovwvoo.."],
    "wide": ["...opdo....", "..opppdo...", "..opoddo...", ".opoodpdo..", ".opo..opdo.", "opo...opdo.", "opo....odo.", "odo....odo.", "oPo....oPo.", "odPoo..odPo", "ovwvo..ovwo"],
    "forward": ["...opdo....", "..opppdo...", "..opodpo...", "..opo.opo..", "..odo..opo.", "..opo...odo", ".opo....odo", ".odo....ovo", ".ovo....ooo", ".oddoo.....", ".ovvvo....."],
    "back": ["...opdo....", "..opppdo...", ".opoodpo...", "opo..opdo..", "odo...opdo.", "ovo....odo.", "ooo....odo.", ".......odo.", ".......ovo.", ".......oddo", ".......ovvo"],
    "tuck": ["...opdo....", "..opppdo...", ".opoodppo..", "opo..odpPo.", "odo...odppo", "ovo...oovoo", "ooo.....oo."],
    "drop": ["..opddo....", "..opddo....", "..opddo....", ".opodpo....", ".opo.opo...", ".odo.odo...", ".odo.odo...", ".ovo.ovo...", ".odoo.odo..", ".ovvo.ovvo."],
    "crouch": ["..opppdo...", ".oppoopdo..", "opo...opdo.", "odo....odo.", "oPo....oPo.", "odPoo..odPo", "ovwvo..ovwo"],
    "slide": ["...opdo.....", "..opppdo....", ".opoodpdo...", "opo...opdo..", "odo....opdo.", "ovo.....odo.", "oddoo...ovoo", "ovvvo...ovvo"],
}

# Upper body origin, arm cluster/offset, legs cluster/origin, and optional blink.
# Every key is intentionally posed. Timing lives in the generated SpriteFrames.
POSES = {
    "idle": (3, [(0, 0, "hang", 0, 0, "rest", 8, 27),
                 (0, -1, "hang", 0, -1, "rest", 8, 27),
                 (0, 0, "hang", 0, 0, "rest", 8, 27, True)]),
    "walk": (10, [(0, 0, "bend", -1, 0, "wide", 7, 27),
                  (1, -1, "bend", 0, -1, "forward", 7, 27),
                  (0, -1, "hang", 0, -1, "rest", 8, 27),
                  (0, 0, "hang", -2, 0, "wide", 8, 27),
                  (1, -1, "hang", -2, -1, "back", 7, 27),
                  (1, -1, "bend", -2, 1, "rest", 9, 27)]),
    "charge": (1, [(1, 1, "bend", 0, 1, "wide", 7, 27),
                   (1, 2, "bend", 1, 2, "slide", 7, 30),
                   (2, 3, "bend", 1, 3, "crouch", 7, 31),
                   (2, 4, "bend", 2, 3, "crouch", 6, 31)]),
    "launch": (30, [(2, -1, "reach", 2, -1, "forward", 6, 27),
                   (2, -3, "reach", 3, -2, "drop", 7, 24)]),
    "rise": (8, [(1, -2, "bend", 2, -2, "tuck", 7, 25),
                 (2, -2, "reach", 2, -2, "tuck", 7, 26)]),
    "fall": (8, [(-1, -1, "reach", 3, -3, "drop", 8, 27),
                 (-1, 0, "reach", 3, -4, "wide", 7, 27)]),
    "land": (30, [(1, 4, "bend", 1, 4, "crouch", 7, 31),
                  (1, 2, "hang", 1, 2, "slide", 7, 30)]),
    "slide": (7, [(-1, 2, "reach", 4, 3, "slide", 7, 30),
                  (-1, 3, "reach", 3, 4, "slide", 7, 30)]),
    "impact": (20, [(-2, 0, "reach", 2, -3, "tuck", 6, 27),
                    (-1, 1, "bend", 0, 2, "drop", 7, 26)]),
}


def draw_pixels(canvas, width, x, y, rows):
    for row_index, row in enumerate(rows):
        for column, pixel in enumerate(row):
            if pixel == ".":
                continue
            offset = ((y + row_index) * width + x + column) * 4
            canvas[offset:offset + 4] = bytes.fromhex(PALETTE[pixel] + "ff")


def draw_pose(canvas, width, x, y, pose):
    dx, dy, arm, ax, ay, legs, lx, ly, *blink = pose
    draw_pixels(canvas, width, x + 5 + dx, y + 20 + dy, BACK_ARM)
    draw_pixels(canvas, width, x + lx, y + ly, LEGS[legs])
    draw_pixels(canvas, width, x + 6 + dx, y + 17 + dy, TORSO)
    head = HEAD.copy()
    if blink:
        head[8] = ".otssfflfo.."
    draw_pixels(canvas, width, x + 7 + dx, y + 7 + dy, head)
    arms = {"hang": SLEEVE, "bend": BENT_ARM, "reach": REACH_ARM}
    arm_origin = 8 if arm == "reach" else 6
    draw_pixels(canvas, width, x + arm_origin + ax, y + 20 + ay, arms[arm])
    draw_pixels(canvas, width, x + 14 + dx, y + 22 + dy, ["l", "y"])
    draw_pixels(canvas, width, x + 9 + dx, y + 24 + dy, ["r"])


def write_png(path, width, height, data):
    def chunk(kind, payload):
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", zlib.crc32(kind + payload))

    rows = b"".join(b"\0" + data[i:i + width * 4] for i in range(0, len(data), width * 4))
    path.write_bytes(b"\x89PNG\r\n\x1a\n" +
                     chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)) +
                     chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b""))


def main():
    width = COLUMNS * WIDTH
    height = len(POSES) * HEIGHT
    canvas = bytearray(width * height * 4)
    frame_count = sum(len(poses) for _, poses in POSES.values())
    resource = [
        f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
        '[ext_resource type="Texture2D" path="res://assets/player/david_martinez.png" id="atlas"]',
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
        loop = "true" if name in {"idle", "walk", "rise", "fall", "slide"} else "false"
        animations.append('{"frames": [' + ", ".join(frames) +
                          f'], "loop": {loop}, "name": &"{name}", "speed": {fps}.0}}')
    write_png(ROOT / "assets/player/david_martinez.png", width, height, canvas)
    resource += ["[resource]", "animations = [" + ",\n".join(animations) + "]"]
    (ROOT / "resources/visuals").mkdir(exist_ok=True)
    (ROOT / "resources/visuals/david_frames.tres").write_text("\n\n".join(resource) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
