# Milestone 02A visual review

These gameplay views come from the actual emergency_power_chamber.tscn rendered by Godot 4.7.2's Compatibility/OpenGL renderer at 320×180. Player positions are staged on real platforms for composition review, not captured from a claimed human playthrough. The overview renders the same composed scene into a native-density 320×420 SubViewport with HUD hidden. All 3× previews use nearest-neighbor integer replication. No in-game reference images or fabricated screenshots are included.

- [Full room, 3×](full_room_3x.png) — native-density wider vertical lens, not the gameplay camera zoom.
- [Starting area, 3×](starting_area_3x.png) — player, lower machinery, floor and route entrance.
- [Mid-climb, 3×](mid_climb_3x.png) — narrow target and two depth-separated machinery masses.
- [Upper room, 3×](upper_room_3x.png) — exit placeholder/relay door, railing and warning lamp.
- [HUD close-up](hud_closeup.png) — crop of actual top 25px, enlarged 3×.
- [Atlas, 3×](atlas_3x.png) — original source atlas preview, not a gameplay screenshot.
- [Before/after, 2×](before_after_2x.png) — initial scene left, refined scene right.

Native images are full_room.png, starting_area.png, mid_climb.png, upper_room.png and before_start.png. The initial art variant removes warning end caps, added atmosphere, secondary framing and route hints. Inspection found insufficient separation between landing geometry and machinery. Refinement adds these cues and subdues midground highlights; upper and middle stops were also inspected. Cyan marks powered systems, yellow marks service/route emphasis, magenta remains sparse.

Reproduce after import:

```powershell
& $GodotExe --path . --script res://tools/capture_visual_review.gd -- --initial-art
& $GodotExe --path . --script res://tools/capture_visual_review.gd
```

Use the same process-local writable AppData/log isolation as tests/run_validation.ps1 in a restricted agent session. This is a development capture script and is not a runtime export dependency. The original first observation was captured before refinement; the retained --initial-art variant makes the comparison reproducible using the same pose and camera.

Artistic approval remains the user's decision. Please review contrast/readability at native scale, machinery scale, accent hierarchy, player silhouette, text size, and whether the atmosphere matches the intended direction before authorizing 02B.
