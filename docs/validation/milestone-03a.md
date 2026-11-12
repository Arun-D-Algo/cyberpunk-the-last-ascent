# Milestone 03A measured validation

Godot 4.7.2 at fixed 60 Hz. The final main-menu entry and opening route passed 555 checks with zero failures.

## Continuous route

The replay walks between launches and completes all 36 destinations without inter-platform resets. Candidate discovery and neighboring-input trials run separately. The climb spans 1,760 pixels. Timing counts successful adjacent charge ticks out of two. Holds above maximum charge clamp to maximum. Position counts successful ±2-pixel launch trials out of two.

| Destination | Rise px | Center offset px | Launch x | Hold s | Actual landing | Rebounds | Timing | Position |
| --- | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: |
| A1_01 | 16 | 48 | 152 | 0.2167 | (174.8843, 127.9813) | 0 | 2/2 | 2/2 |
| A1_02 | 52 | -88 | 200 | 0.6500 | (128.6486, 75.98132) | 0 | 2/2 | 2/2 |
| A1_03 | 44 | 104 | 112 | 0.6500 | (190.7318, 31.98131) | 0 | 2/2 | 2/2 |
| A1_04 | 52 | -104 | 208 | 0.7000 | (124.6305, -20.01869) | 0 | 2/2 | 2/2 |
| A1_05 | 48 | 88 | 120 | 0.6000 | (182.518, -68.01872) | 0 | 2/2 | 2/2 |
| A1_06 | 44 | -88 | 208 | 0.6000 | (140.8516, -112.0187) | 0 | 2/2 | 2/2 |
| A1_07 | 52 | 80 | 120 | 0.6167 | (179.0953, -164.0187) | 0 | 1/2 | 2/2 |
| A1_08 | 48 | -88 | 200 | 0.6167 | (133.8141, -212.0187) | 0 | 2/2 | 2/2 |
| A1_09 | 52 | 104 | 112 | 0.6833 | (191.2669, -264.0187) | 0 | 2/2 | 2/2 |
| A1_10 | 48 | -104 | 208 | 0.6833 | (123.6196, -312.0187) | 0 | 2/2 | 2/2 |
| A2_01 | 44 | 96 | 104 | 0.7500 | (208.5073, -356.0187) | 0 | 2/2 | 2/2 |
| A2_02 | 48 | -88 | 200 | 0.7500 | (98.24274, -404.0187) | 0 | 2/2 | 2/2 |
| A2_03 | 44 | 104 | 112 | 0.7500 | (216.5073, -448.0187) | 0 | 2/2 | 2/2 |
| A2_04 | 48 | -104 | 208 | 0.7000 | (119.4203, -496.0187) | 0 | 2/2 | 2/2 |
| A2_05 | 48 | 52 | 104 | 0.7500 | (154.8311, -544.0187) | 1 | 2/2 | 2/2 |
| A2_06 | 44 | -64 | 156 | 0.6333 | (81.22595, -588.0187) | 0 | 2/2 | 2/2 |
| A2_07 | 52 | 96 | 92 | 0.7500 | (169.0073, -640.0187) | 0 | 2/2 | 2/2 |
| A2_08 | 48 | -76 | 188 | 0.7167 | (95.1244, -688.0187) | 0 | 2/2 | 2/2 |
| A2_09 | 44 | 96 | 120 | 0.6667 | (202.7862, -732.0187) | 0 | 2/2 | 2/2 |
| A2_10 | 48 | -52 | 216 | 0.7500 | (165.1689, -780.0187) | 1 | 2/2 | 2/2 |
| A2_11 | 48 | 64 | 164 | 0.6833 | (248.3804, -828.0187) | 0 | 2/2 | 1/2 |
| A2_12 | 52 | -80 | 212 | 0.6333 | (146.8733, -880.0187) | 0 | 1/2 | 1/2 |
| A3_01 | 48 | 68 | 132 | 0.6667 | (212.2777, -928.0187) | 0 | 2/2 | 2/2 |
| A3_02 | 52 | -88 | 200 | 0.7333 | (105.4336, -980.0187) | 0 | 2/2 | 2/2 |
| A3_03 | 48 | 104 | 112 | 0.7500 | (213.7573, -1028.019) | 0 | 2/2 | 2/2 |
| A3_04 | 56 | -104 | 208 | 0.7500 | (114.4927, -1084.019) | 0 | 2/2 | 2/2 |
| A3_05 | 48 | 52 | 104 | 0.7500 | (154.8311, -1132.019) | 1 | 2/2 | 2/2 |
| A3_06 | 52 | -64 | 156 | 0.6500 | (84.64864, -1184.019) | 0 | 2/2 | 2/2 |
| A3_07 | 56 | 96 | 92 | 0.7500 | (185.5073, -1240.019) | 0 | 2/2 | 2/2 |
| A3_08 | 52 | -76 | 188 | 0.7000 | (104.6305, -1292.019) | 0 | 2/2 | 2/2 |
| A3_09 | 48 | 104 | 112 | 0.7500 | (205.5073, -1340.019) | 0 | 2/2 | 2/2 |
| A3_10 | 52 | -60 | 224 | 0.7500 | (160.2188, -1392.019) | 1 | 2/2 | 2/2 |
| A3_11 | 56 | 72 | 156 | 0.7333 | (245.1631, -1448.019) | 0 | 2/2 | 2/2 |
| A3_12 | 52 | -96 | 228 | 0.7500 | (128.9927, -1500.019) | 0 | 2/2 | 2/2 |
| A3_13 | 56 | 68 | 132 | 0.7000 | (212.7645, -1556.019) | 0 | 2/2 | 2/2 |
| A3_14 | 60 | -88 | 200 | 0.7500 | (109.2427, -1616.019) | 0 | 2/2 | 2/2 |

Every destination has at least one successful adjacent charge trial and offset trial. One-sided windows deserve attention during human playtesting. The actual landing coordinate records solver behavior. These local samples do not establish every possible approach.

## Falls and recovery

| Departure | Catch | Drop px |
| --- | --- | ---: |
| A1_03 | Base | 111.75 |
| A2_07 | A2_04 | 143.73 |
| A3_09 | A3_07 | 99.75 |

The summit fall dropped 1303.75 pixels in 2.483 simulation seconds, reaching 600 px/s and returning to section 1. The camera retained player visibility. After contact, the test walked to a launch position and reached the next ascent destination. Pause and explicit reset also passed.

## Commands and regression outcomes

```powershell
& powershell -NoProfile -ExecutionPolicy Bypass -File tests/run_validation.ps1 -GodotExe 'C:\Users\Arunangshu Dasgupta\Tools\Godot\godot_console.exe'
& powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate_static.ps1
```

Static validation passed 281 source checks. The runner passed import, boot, smoke, chamber, lab and historical tower startup, 177 physics checks, 168 visual/input checks, 665 surface checks, 115 refinement checks, 55 slope checks, 191 character animation checks, and 393 historical tower checks covering all 60 original landings. Forced slides passed 53 checks at each of 30, 60 and 120 render FPS, together with the cadence probes.

The opening suite uses the menu's normal ascent entry and validates casing dimensions, collision layers, resources, route tolerances, transitions, falls and recovery. Compared with 8146509, player scripts, sprite assets, animation resources, collision scene, camera source, physics resources, surface profiles and project configuration have no diff.

## Rendering and performance

Godot Compatibility rendered the review using Intel Arc graphics. Repeating wall sprites reduced the captured scene from 536 to 296 nodes. It has 43 static bodies. A short 960×540 run sampled Godot's process monitor for 120 frames after warmup and reported approximately 17.5 ms. The monitor updates coarsely, so repeated values do not establish a per-frame latency distribution or guarantee 60 FPS. Capture/readback and PNG-save time is excluded from the steady sample. Longer interactive performance testing remains part of owner review.

## Acceptance limits

Human difficulty and artistic approval remain pending. The compact route repeats architectural modules. Rear-plane braces, background machines and signage are decorative. Bright landing roofs, casings, boundary columns and return faces are solid. Existing Assisted/Classic resources have no selectable tower checkpoint policy, so separate mode behavior is not claimed.
