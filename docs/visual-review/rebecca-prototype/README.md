# Rebecca character prototype

Original indexed pixel clusters based on the three supplied images. The anime close-up shows the pale face, warm eyes and pink neck marking. The Kotobukiya illustration and character model sheet show the mint twin tails with dark ties, oversized navy jacket, blue and pink cyberhands, thigh stripe and olive-trimmed boots.

Rebecca uses a 120×80 RGBA atlas with six 40×40 cells. Neutral stands 29 pixels tall beside David's 33-pixel neutral key. Both use one source pixel per logical pixel and feet on row 37, with an anchor at (20, 38). The left key mirrors the neutral right key, so the glove colors and thigh stripe swap on screen. Facial details are compressed to a few clusters at native scale.

The top row is the right-facing idle. It holds the neutral key for 400 ms, then plays two one-pixel upper-body and hair shifts for 200 ms each. The soles stay planted. The bottom row is neutral left, confident with a raised hand, and annoyed with folded arms.

| Preview | Native | 4× nearest |
| --- | --- | --- |
| Neutral | [1×](standing_native.png) | [4×](standing_4x.png) |
| Left and right | [1×](facing_native.png) | [4×](facing_4x.png) |
| Idle keys | [1×](idle_native.png) | [4×](idle_4x.png) |
| Confident | [1×](confident_native.png) | [4×](confident_4x.png) |
| Annoyed | [1×](annoyed_native.png) | [4×](annoyed_4x.png) |
| Atlas | [1×](sheet_native.png) | [4×](sheet_4x.png) |
| David and Rebecca | [1×](scale_native.png) | [4×](scale_4x.png) |

Run Python 3 on tools/generate_rebecca.py from the project root. Import in Godot 4.7.2 and run Godot headlessly with --fixed-fps 60 --script res://tools/capture_rebecca_review.gd. The review script verifies imported frame size, foot alignment, distinct idle keys and playback using nearest filtering on an isolated AnimatedSprite2D.
