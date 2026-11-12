# Cinematic David sprite review

The 02G keys are on the top row. The cinematic keys are on the bottom row.

| Comparison | Native | 4× nearest |
| --- | --- | --- |
| Neutral standing | [1×](standing_native.png) | [4×](standing_4x.png) |
| Hair, brow and jaw | [1×](head_native.png) | [4×](head_4x.png) |
| Four charge, three launch, three rise and one apex key | [1×](takeoff_native.png) | [4×](takeoff_4x.png) |
| Eight descent keys in ascending speed order | [1×](descent_native.png) | [4×](descent_4x.png) |
| Impact through recovery | [1×](landing_native.png) | [4×](landing_4x.png) |

| Godot capture | Native | 4× nearest |
| --- | --- | --- |
| Idle in the tower | [1×](tower_native.png) | [4×](tower_4x.png) |
| Full charge in Lab A | [1×](charge_lab_native.png) | [4×](charge_lab_4x.png) |
| Launch extension in Lab A | [1×](launch_lab_native.png) | [4×](launch_lab_4x.png) |
| Fast fall in Lab A | [1×](fall_fast_lab_native.png) | [4×](fall_fast_lab_4x.png) |
| Three-point landing in Lab A | [1×](land_lab_native.png) | [4×](land_lab_4x.png) |
| Recovery in Lab A | [1×](recovery_lab_native.png) | [4×](recovery_lab_4x.png) |

The [animated lab jump](lab_jump.apng) plays a real charge, jump, hard landing and recovery sampled at 30 fps. Open it in a browser that supports animated PNGs. The [full native atlas](atlas_native.png) includes all 39 keys.

To reproduce the stills and 60 Hz source sequence, run graphical Godot with `--resolution 1280x720 --fixed-fps 120 --script res://tools/capture_david_cinematic.gd`. The raw playback frames go to the ignored `.godot/cinematic-sequence` directory.

For manual review, enter **Physics Lab 2.0 → A Jumps** and tap the charge input, then hold it to full charge and release for a vertical jump. Walk or start charging as soon as control returns after a hard landing. Repeat facing left and right. Open **Start Tower Ascent** to judge the standing silhouette against the live environment.
