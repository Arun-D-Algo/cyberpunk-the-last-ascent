# Milestone 03B visual review

The comparison pairs use the saved 03A engine overview and the live 03B scene. Most gameplay views stage David on supported surfaces. The fall and recovery frames show a controller-driven summit walk-off. The validation report covers continuous controller-driven play.

| Area | Before | After |
| --- | --- | --- |
| Corporate Service | [03A](before_section_1.png) | [03B](section_1.png) |
| Ventilation Galleries | [03A](before_section_2.png) | [03B](section_2.png) |
| Transformer Hall | [03A](before_section_3.png) | [03B](section_3.png) |

[Full-height overview](full_layout.png) · [Annotated route and recovery paths](../../validation/milestone-03b.md)

| Gameplay view | Native | 4× nearest |
| --- | --- | --- |
| Exterior and security roof | [1×](exterior_native.png) | [4×](exterior_4x.png) |
| Corporate overhang and inspection landing | [1×](plaza_overhang_native.png) | [4×](plaza_overhang_4x.png) |
| Service gate | [1×](service_gate_native.png) | [4×](service_gate_4x.png) |
| Fan rebound pocket | [1×](fan_rebound_native.png) | [4×](fan_rebound_4x.png) |
| Angled duct shoulder | [1×](slope_native.png) | [4×](slope_4x.png) |
| Pressure bypass and transfer bridge | [1×](ventilation_fork_native.png) | [4×](ventilation_fork_4x.png) |
| Exhaust chute and lower catch | [1×](exhaust_native.png) | [4×](exhaust_4x.png) |
| Slick condensate tray | [1×](slick_native.png) | [4×](slick_4x.png) |
| Opposing transformer piers | [1×](transformer_shaft_native.png) | [4×](transformer_shaft_4x.png) |
| Elevator header and direct summit option | [1×](header_native.png) | [4×](header_4x.png) |
| Summit | [1×](summit_native.png) | [4×](summit_4x.png) |
| Mid-fall through the transformer shaft | [1×](fall_lane_native.png) | [4×](fall_lane_4x.png) |
| Lower recovery on Tower Fin | [1×](fall_recovery_native.png) | [4×](fall_recovery_4x.png) |

## Playtest checklist

1. Start Tower Ascent. Climb the right-side security structures. Try a full-charge bank off the right wall from Badge Reader to Gate Canopy, then compare the two approaches from Sign Beam to Loading Gantry.
2. From Glass Lintel, compare a medium charge into Inspection Pocket with a full charge under the beam. Read the overhead clearance before leaving the pocket.
3. Walk the Pipe Saddle shoulder, then bank off the central fan column. Compare the pressure bypass and the bridge/valve route.
4. Deliberately walk off the right edge of Transfer Bridge. Try holding right and Space during the leftward chute descent. Climb from the catch to Fan Column and rejoin at Pillar Sill.
5. Release movement on the blue Condensation Tray, brake, and start a fresh charge. Try the two opposing banks in Transformer Hall.
6. Compare the header route and the direct summit jump. Walk off the left summit edge and climb back from the transformer fins. Check camera look, Esc pause and F6 reset.
7. Review readability, charge tolerance, route choice, scenery and the cost of mistakes before approving further regions.

Capture command uses graphical Godot 4.7.2 with --resolution 320x180 --fixed-fps 60 --script res://tools/capture_opening_review.gd.
