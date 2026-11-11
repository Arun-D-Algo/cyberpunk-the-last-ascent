# Original asset manifest — M02A

All listed art was authored for this project by the versioned tools/generate_art.gd script. No downloaded source images, fonts, sprites, game screenshots, audio or extracted proprietary files were used. The project owner retains the decision about a future public asset/software license; this manifest does not grant rights to the third-party fan setting. High-level references are documented in visual-style-guide.md.

| Source/output | Contents and purpose |
| --- | --- |
| tools/generate_art.gd | Editable integer-pixel source, fixed palette, raster glyph patterns, deterministic PNG/FNT generation |
| assets/environment/industrial/industrial_atlas.png | 256×256 RGBA atlas: floor/platform/walkway/edge, reinforced wall, beam, pipe, actuator, railing, generator, fan, panel, console, access door, sign, monitor, cables, damaged panel, conduit, fluorescent/warning/emergency lamps, vent |
| assets/environment/industrial/palette.gpl | Editable six-role palette plus support shades; hand-maintained alongside source constants |
| assets/environment/backgrounds/shaft_far.png | 320×512 original recessed bays and distant industrial braces |
| assets/environment/backgrounds/shaft_mid.png | 320×512 transparent pipe/support depth layer |
| assets/environment/effects/effects_atlas.png | 128×64: four fan frames, four spark cells, four steam cells |
| assets/player/maintenance_runner.png | 96×32: six original 16×32 maintenance-runner pose cells, replaceable placeholder |
| assets/ui/industrial_micro.png and .fnt | Original hand-authored 3×5 diagnostic glyphs and BMFont metrics; ASCII coverage, no external font dependency |
| resources/ui/industrial_theme.tres | Native Godot colors, sharp StyleBoxes, font/charge/button styling |

Atlas region coordinates and naming are centralized in scripts/environment/industrial_art.gd. Preserve integer bounds and avoid rescaling pixel textures. Source PNGs and import metadata belong in Git; .godot imported textures do not. The generation script intentionally clips long background braces at canvas edges. An initial unbounded raster call was corrected before clean regeneration; no generator errors remain.

Review imagery is actual Godot Compatibility output under docs/visual-review/milestone-02a. Atlas overview is labeled as an asset preview. No reference-game screenshot is packaged in the project. Public redistribution/character replacement/IP review remains a separate future decision.

## Milestone 02E character prototype

The David Martinez fan-art prototype uses original palette-indexed pixel clusters and pose keys authored in tools/generate_david.py. It emits assets/player/david_martinez.png and resources/visuals/david_frames.tres. The former maintenance runner remains a historical source asset. Reference and frame details are in [Character art guide](character-art-guide.md).
