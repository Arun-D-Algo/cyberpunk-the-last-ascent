"""Author cinematic David keys on the established 40-pixel grid."""
from generate_david_02f import ARMS, HEIGHT, POSES as BASE_POSES, export_frames
from generate_david_02g import WIDTH, draw_pixels, draw_trousers

HEAD = [
    "......o.....", "...o.oh.o...", "..ohoohhoo..", "..ohbhbhoo..",
    ".ohbbhbhooo.", ".ohbhhhhhoo.", ".ohhssffto..", "..oshtkfo...",
    "..ostffto...", "...otftso...", "....otto....", ".....to.....",
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
    "plant": [
        "..oYYoo...", ".oyyyjoo..", ".oyyyajo..", "..oyyyjo..",
        "...ovwvo..", "...ojyjo..", "....otto..", "....ostt..", "....osflo.",
        ".....oooo.",
    ],
    "trail": [
        ".....ooYYo", "...ooyyyjo", "..oyyyyjo.", ".ovwwyjo..",
        "ottoo.....", "osfo......", ".oo.......",
    ],
}
# Retain ground keys and replace the airborne sequence using the same rig.
POSES = BASE_POSES.copy()
del POSES["fall"]
POSES.update({
    "charge": (1, [
        (0, 0, "hang", 7, 19, "back", 22, 18, (14, 13, 12, 37), (19, 20, 21, 37)),
        (1, 2, "brace", 8, 21, "trail", 4, 20, (15, 11, 12, 37), (20, 22, 21, 37)),
        (2, 5, "brace", 9, 24, "trail", 5, 22, (15, 10, 12, 37), (20, 23, 21, 37)),
        (3, 7, "brace", 11, 26, "trail", 5, 25, (15, 9, 12, 37), (21, 24, 21, 37)),
    ]),
    "land": (20, [
        (3, 8, "plant", 20, 28, "trail", 5, 25, (14, 9, 8, 37), (21, 22, 21, 37)),
        (2, 6, "plant", 19, 25, "trail", 5, 23, (15, 10, 8, 37), (20, 23, 21, 37)),
        (1, 3, "hang", 12, 22, "back", 23, 21, (15, 11, 10, 37), (20, 22, 21, 37)),
        (0, 1, "hang", 8, 20, "back", 22, 19, (14, 12, 11, 37), (19, 21, 21, 37)),
    ]),
    "launch": (30, [
        (2, 1, "brace", 12, 19, "trail", 6, 18, (15, 12, 11, 37), (21, 23, 22, 36)),
        (2, -2, "brace", 13, 15, "trail", 7, 17, (15, 13, 11, 37), (21, 24, 23, 35)),
        (1, -3, "brace", 12, 14, "trail", 7, 16, (15, 13, 11, 36), (21, 25, 23, 33)),
    ]),
    "rise": (12, [
        (1, -3, "brace", 11, 14, "trail", 6, 16, (15, 12, 11, 36), (21, 24, 23, 33)),
        (1, -2, "brace", 10, 15, "trail", 6, 17, (15, 12, 10, 35), (21, 24, 23, 32)),
        (0, -2, "brace", 9, 15, "trail", 5, 17, (14, 11, 10, 34), (20, 24, 22, 32)),
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
        (0, 0, "spread", 15, 14, "spread", -3, 14, (14, 9, 7, 36), (20, 26, 25, 34)),
        (0, 0, "open", 15, 15, "spread", -3, 14, (14, 10, 7, 35), (20, 26, 26, 35)),
        (0, 0, "spread", 15, 14, "open", -2, 13, (14, 9, 8, 36), (20, 26, 26, 34)),
    ]),
})
LOOPS = {"idle", "walk", "fall_early", "fall", "fall_fast", "slide", "forced"}


def draw_key(canvas, stride, x, y, pose, name, _frame):
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

    jacket = JACKET
    if name in {"charge", "land"} and dy >= 5:
        # A folded hem exposes the thigh and leaves the support arm legible.
        jacket = JACKET[:8] + [".ojyyjYokoyao....", "..oooooooooo...."]
    draw_pixels(cell, 12 + dx, 16 + dy, jacket)
    draw_pixels(cell, nx + 4, ny, arms[near])
    draw_pixels(cell, 16 + dx, 6 + dy, HEAD)
    draw_pixels(cell, 20 + dx, 21 + dy, ["l", "y"])
    for row in range(HEIGHT):
        offset = ((y + row) * stride + x) * 4
        canvas[offset:offset + WIDTH * 4] = cell[row * WIDTH * 4:(row + 1) * WIDTH * 4]


if __name__ == "__main__":
    export_frames("cinematic", WIDTH, POSES, draw_key, LOOPS)
