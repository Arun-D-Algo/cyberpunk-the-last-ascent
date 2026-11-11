# Milestone 02F visual review

- [Before and after at native resolution](before_after_native.png) and [6× nearest](before_after_6x.png) show 02E, 02F facing right, and 02F facing left.
- [Native atlas](atlas_native.png) and [3× dark and light atlas](atlas_readability_3x.png) show neutral, idle, walk, charge, launch, rise, fall, landing, ice slide, forced slide and impact. Atlas rows begin with idle, then walk and charge.
- [Idle](idle_strip_3x.png), [walk](walk_strip_3x.png), [charge](charge_strip_3x.png) and [forced slide](forced_strip_3x.png) strips show the keys at 3×.
- [Tower at 320×180](tower_native.png) and [tower at 960×540](tower_3x.png) are actual Godot captures.
- [Connected chute](ramp_3x.png) and [descent timeline](ramp_timeline.png) show the controller at ticks 12, 34, 56 and 78. The last frame is on the normal runout.

Render with tools/capture_david_02f.gd at 960×540 and fixed FPS 120 using the graphical Godot executable. Judge motion in the lab at the usual window size.
