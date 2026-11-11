"""Refine the 02F pose set and export the active David atlas."""
from generate_david_02f import ARMS, HEIGHT, PALETTE, POSES as BASE_POSES, export_frames

WIDTH = 40
HEAD = [
    "...o........", ".oohhoo.....", "..ohbbho....", "ohhbbhhoo...",
    ".ohbbhhhoho.", ".ohhhhhtho..", "..ossttfho..", "..otfokfoo..",
    "..otfffsto..", "...otffto...", "....otso....", ".....to.....",
]
JACKET = [
    "..oocCoo.oo......", ".ocCCcoooCco.....", "oYyyCCokocYYyoo..",
    "oYyyyjodkoyYyjo..", "oyYyyjodkoyyyjo..", "oyyyyjodkoyyajo..",
    "ojyyyjodkoyYajo..", "ovwwwvojkolwv....", "ojyyyjYokoyajo...",
    ".ojyyjYokoyao....", "..oajjYokoyo.....", "...ooooooo.......",
]
AIR_ARMS = {
    "open": [
        "....ooYYoo....", "...oYyyyjoo...", "..oYyyyjvwtoo.",
        ".oyyyajvwwtfo.", ".oajjjooottso.", "..oooo...ooo..",
    ],
    "spread": [
        "..ooYYoo......", "ooYyyyjoooo...", "oYyyyjYjvwtoo.",
        ".oyyajjvwwtffo", "..ooooooottso.", "..........oo..",
    ],
    "raised": [
        "........otfo..", "......oovwto..", "....ooYjvwo...",
        "..ooYyyjjo....", ".oYyyyjao.....", "..oooooo......",
    ],
}
# Two short tails start at the raised edges and tuck under the torso.
FLARE = [
    ("....oo...", "...oYyo..", "..ojyYoo.", ".oajywvoo", ".oajjjyyo", "..oooooo."),
    ("...oo.....", "..oYyo....", ".oYyYoo...", "ojyYywwwoo", "oajyyjjjjo", ".oajjjjoo.", "..ooooo..."),
    (".oo.........", "oYyo........", "oYyYoo......", ".oyYyYoo....", ".ojyywwwwooo",
     "..oajjyyjjjo", "...oajjjjoo.", "....ooooo..."),
]

# Retain ground keys and replace the airborne sequence using the same rig.
POSES = BASE_POSES.copy()
del POSES["fall"]
POSES.update({
    "launch": (30, [
        (0, 2, "brace", 7, 20, "raised", 23, 15, (14, 10, 11, 36), (20, 24, 23, 36)),
        (1, -1, "raised", 11, 11, "back", 23, 15, (15, 12, 11, 36), (21, 22, 24, 37)),
        (1, -3, "raised", 12, 10, "brace", 23, 14, (15, 14, 12, 36), (21, 24, 23, 34)),
    ]),
    "rise": (12, [
        (1, -3, "raised", 12, 11, "back", 23, 15, (15, 12, 11, 36), (21, 24, 23, 33)),
        (1, -2, "brace", 11, 15, "brace", 22, 16, (15, 12, 10, 35), (21, 24, 23, 32)),
        (0, -2, "brace", 9, 15, "back", 23, 16, (14, 11, 10, 34), (20, 24, 22, 32)),
    ]),
    "apex": (12, [
        (0, -2, "open", 10, 14, "open", 2, 14, (14, 11, 10, 34), (20, 24, 22, 33)),
    ]),
    "fall_early": (10, [
        (0, -1, "open", 11, 14, "open", 1, 14, (14, 11, 10, 35), (20, 24, 23, 34)),
        (0, -1, "open", 12, 15, "open", 0, 15, (14, 10, 9, 36), (20, 24, 24, 34)),
    ]),
    "fall": (12, [
        (0, 0, "spread", 13, 14, "spread", -1, 14, (14, 10, 9, 36), (20, 25, 24, 35)),
        (0, 0, "open", 14, 15, "open", -1, 13, (14, 9, 9, 36), (20, 25, 25, 34)),
        (0, 0, "spread", 13, 15, "spread", -2, 14, (14, 10, 8, 35), (20, 24, 25, 35)),
    ]),
    "fall_fast": (14, [
        (0, 0, "spread", 15, 13, "spread", -3, 12, (14, 9, 7, 36), (20, 26, 25, 34)),
        (0, 0, "raised", 15, 11, "spread", -3, 13, (14, 10, 7, 35), (20, 26, 26, 35)),
        (0, 0, "spread", 15, 14, "raised", -3, 11, (14, 9, 8, 36), (20, 26, 26, 34)),
    ]),
})
LOOPS = {"idle", "walk", "fall_early", "fall", "fall_fast", "slide", "forced"}


def draw_pixels(cell, x, y, rows):
    for row, line in enumerate(rows):
        for column, pixel in enumerate(line):
            if pixel != ".":
                px, py = x + column, y + row
                if not (1 <= px < WIDTH - 1 and 1 <= py < HEIGHT - 1):
                    raise ValueError(f"Pixel outside frame padding at {(px, py)}")
                offset = (py * WIDTH + px) * 4
                cell[offset:offset + 4] = bytes.fromhex(PALETTE[pixel] + "ff")


def draw_trousers(cell, leg, top, far):
    hip, knee, boot, sole = leg
    middle = (top + sole - 2) // 2
    dark, mid, light = ("d", "p", "P") if far else ("p", "P", "v")
    for row in range(top, sole - 1):
        if row <= middle:
            center = round(hip + (knee - hip) * (row - top) / max(middle - top, 1))
        else:
            center = round(knee + (boot - knee) * (row - middle) / max(sole - 2 - middle, 1))
        span = "o" + dark + mid * 4 + dark + "o"
        if row == middle:
            span = "o" + dark + mid + light + mid * 2 + dark + "o"
        elif row == middle + 1 and row < sole - 2:
            span = "o" + dark * 2 + mid * 2 + dark * 2 + "o"
        if row == sole - 2:
            span = "ov" + dark * 3 + "o"
        draw_pixels(cell, center + (1 if len(span) < 8 else 0), row, [span])
    draw_pixels(cell, boot + 2, sole - 1, ["okvkkko", "oPvwwvo"])


def draw_key(canvas, stride, x, y, pose, name, frame):
    dx, dy, near, nx, ny, far, fx, fy, near_leg, far_leg = pose
    cell = bytearray(WIDTH * HEIGHT * 4)
    spreading = name in {"apex", "fall_early", "fall", "fall_fast"}
    arms = ARMS | AIR_ARMS
    far_rows = arms[far]
    if spreading:
        far_rows = tuple(row[::-1] for row in far_rows)
    draw_pixels(cell, fx + (4 if spreading else 2), fy, far_rows)
    if spreading:
        # Inner sleeve fold joins the extended far arm to the shoulder.
        draw_pixels(cell, 9 + dx, 15 + dy, ["..oyo.", ".oyyyo", "ojyyjo", ".ovwvo", "..ojoo"])
    for is_far, leg in ((True, far_leg), (False, near_leg)):
        draw_trousers(cell, leg, 25 + dy, is_far)

    if name in {"launch", "rise", "apex", "fall_early", "fall", "fall_fast"}:
        strength = {"fall": 1, "fall_fast": 2}.get(name, 0)
        tail = FLARE[strength]
        lift = 1 if frame % 2 else 0
        draw_pixels(cell, 12 + dx - 3 * strength, 23 + dy - 2 * strength - lift, tail)
        draw_pixels(cell, 20 + dx + strength, 23 + dy - strength + lift,
                    tuple(row[::-1] for row in tail))
    draw_pixels(cell, 12 + dx, 16 + dy, JACKET)
    draw_pixels(cell, nx + 4, ny, arms[near])
    draw_pixels(cell, 16 + dx, 6 + dy, HEAD)
    draw_pixels(cell, 20 + dx, 21 + dy, ["l", "y"])
    for row in range(HEIGHT):
        offset = ((y + row) * stride + x) * 4
        canvas[offset:offset + WIDTH * 4] = cell[row * WIDTH * 4:(row + 1) * WIDTH * 4]


if __name__ == "__main__":
    export_frames("02g", WIDTH, POSES, draw_key, LOOPS)
