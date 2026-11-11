# Milestone 02E visual review

- [Native atlas](atlas_native.png) contains all 25 keys. From top to bottom the rows are idle, walk, charge, launch, rise, fall, land, slide and impact. The final occupied charge cell is full charge.
- [3× dark and light atlas](atlas_readability_3x.png) compares the exact pixels on navy and light slate.
- [Walking strip](walk_strip_3x.png) and [charge strip](charge_strip_3x.png) show the individual poses at 3× nearest enlargement.
- [Tower native render](tower_native.png) and [tower 3× render](tower_3x.png) show David on the real tower floor.
- [Ramp 3× render](ramp_3x.png) and [ramp timeline](ramp_timeline.png) show Lab P at successive physics ticks. The timeline reads top left, top right, bottom left, bottom right at ticks 15, 39, 63 and 87. Each frame comes from the actual Godot Compatibility renderer after controller-driven motion.

Reproduce with the Godot console executable, the project path and graphical arguments: --resolution 960x540 --fixed-fps 120 --script res://tools/capture_david_review.gd. The engine render ran on Intel Arc. The timeline is sampled evidence. Play the ramp in real time to judge motion feel.
