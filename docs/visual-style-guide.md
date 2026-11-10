# Neon Industrial Decay — Milestone 02A

Status: implemented visual direction for user review, **not artistic approval**. The user approved M01 movement in the M02A brief. Physics is locked for this milestone. This guide supersedes the provisional scale/palette suggestions in art-direction.md; use the latter for broader campaign principles.

## Identity and reference interpretation

An abandoned emergency power chamber under an oppressive corporate tower: costly infrastructure is still running, but its maintenance systems have been isolated and allowed to decay. The protagonist is a small warm silhouette framed by cold machinery. A massive ribbed alternator occupies the right lower room; a darker second housing stretches upward on the left, suggesting further infrastructure beyond the view. The route is a sequence of service ledges, not floating abstract blocks.

The user's references inform different choices: Edgerunners supplies the yellow/cyan/magenta hierarchy and harsh infrastructure; Katana ZERO informs readable silhouettes and constrained local contrast; SANABI informs oversized mechanical masses and vertical composition; The Last Night informs layered atmospheric depth. These are interpretations of the requested high-level influences, not copies of frames, sprites, typography or rendering pipelines. The in-game signs use original maintenance codes and angular diagnostic forms rather than third-party logos or invented Japanese text.

Reference links for future art review: [Cyberpunk: Edgerunners](https://www.cyberpunk.net/en/edgerunners), [Katana ZERO](https://store.steampowered.com/app/460950/Katana_ZERO/), [SANABI](https://store.steampowered.com/app/1562700/SANABI/), [Odd Tales](https://oddtales.net/). Reference imagery is never imported as a texture.

## Palette and hierarchy

| Role | Hex | Application |
| --- | --- | --- |
| Deep background navy | #080D18 | Void, deep architectural shadows |
| Dark industrial steel | #172638 | Metal bodies, housings, dark clothing |
| Midtone slate | #34475A | Supports, ribs and structural secondary planes |
| Electric cyan | #00D9E8 | Powered monitors, fluorescent tubes, player implant/charge |
| Warning yellow | #F5D547 | Route end caps, maintenance signs, warm player jacket |
| Emergency magenta | #F04775 | Sparse fault indicators, never broad ambient fill |
| Recess shadow | #101A29 | Panel cavities and seams |
| Steel edge | #536779 | Bolts, bevels, exposed metal edges |
| Surface highlight | #A9C4CC | Actual platform top line and key silhouettes |

The editable GIMP palette is assets/environment/industrial/palette.gpl. Source colors are centralized in tools/generate_art.gd. Supporting skin/jacket shades are for the original placeholder only. Alpha overlays and tint modulation produce rendered intermediate colors; the screenshot need not contain only source swatches.

Navy/steel dominate. Cyan marks a few working systems. Yellow identifies warnings and the route without turning every object into a light. Magenta is a local failure accent. Do not give all three neon colors equal screen area. Value, contour and top-edge treatment must convey walkability even without hue discrimination.

## Pixel production contract

- Keep the 320×180 viewport, integer scaling and GL Compatibility renderer. Artwork uses one source pixel per world pixel, with no fractional sprite scaling. 3× review previews use nearest-neighbor replication.
- Structural vocabulary uses 16px modules. Wall panels are 32×64; generator 96×160; access door 48×64; console 48×32; fan/panels 32×32. Platforms can have arbitrary integer widths by cropping the final atlas tile instead of stretching it. Gap geometry remains dictated by approved physics.
- Player atlas is six 16×32 cells. Feet remain at row 31, body origin at the bottom-center. The existing 10×24 collider remains unchanged; appearance cannot define contact. The visible humanoid is an original maintenance-runner placeholder, not final David artwork.
- Use one-pixel contour seams and bevels, with selective highlights on upward/left-facing metal. Avoid uniform bright outlines around every machine. Keep background contours darker than foreground platform tops.
- Shade in two or three deliberate planes. Ribbing, recessed vents, bolts, panel seams, fractured panels and cable silhouettes convey material. Do not scatter random per-pixel noise. Sparse diagonal/brushed patterns are acceptable; dense dithering behind player feet is not.
- No antialiasing in asset generation. Lossless texture import, no mipmaps and nearest canvas filtering. Transparent PNG borders are intentional. Atlas regions have integer bounds; validate them after edits.
- Visual-only player snapping rounds the child Visual to world pixels. The body retains its precise floating-point physics coordinates. Camera smoothing/rounding remains the approved M01 implementation; never snap the body or adjust collisions for art.

## Scene hierarchy and composition

Background: 320×512 oversized shaft textures, deep recessed bays, distant braces. Their large continuous fields cover every view; they do not tile within the chamber. Midground: generators, trunks, pipe clamps and cables, tinted lower in contrast. Foreground: bright one-pixel ledge tops, selective warning end caps, load-bearing brackets, enclosing walls and the player. Decorative railing is deliberately dark and broken by posts; it is not another solid platform.

Read the room from warm lower-left start to cyan generator core, then alternating ledges to the yellow upper-relay marker. Preserve gaps of quieter negative space around the small landing surface. Avoid placing a detailed console or bright monitor directly on a critical landing silhouette. Props are composed from reusable sprites, not a screen-sized hardcoded drawing. Static collisions are built independently by IndustrialPlatform and the chamber boundary bodies.

Parallax uses a finite, oversized far image and a midground assembly. Position shifts by 12% and 4.5% of vertical camera displacement respectively, rounded to whole pixels. Foreground geometry never shifts. W/S and arrow look are tested at lower/middle/upper stops for complete image coverage. These finite layers are appropriate for one room, not a ready-made streaming solution for the whole tower.

## Lighting and animation

Use pixel bands of low-alpha local glow around fixtures, two very faint polygonal bounce-light shafts, emissive painted pixels and a segmented lit power trunk. No bloom, full-screen shader, CanvasModulate or renderer switch. This intentionally gives a small flat-pixel lighting vocabulary rather than physically accurate shadow casting. World highlights are baked/painted; prop glow remains local. Renderer compatibility is verified by actual OpenGL screenshots.

Fan cycles four frames at 6 fps. Spark flashes briefly once per six-second cycle, steam uses four sparse frames at 4 fps, and lamps use occasional subdued state changes at a half-second cadence. These are decorative: no damage, collision, time-scale or jump effects. Pause also pauses decorative clocks. Exported animation_enabled allows disabling fixture motion for review or future accessibility wiring. There is no global accessibility settings UI in 02A.

Avoid wide bright flashes, continuously flickering panels, excessive particles and camera shake. A future reduced-effects setting should disable fixture animation and light-shaft visibility without changing geometry or player mechanics.

## Player and diagnostic UI

The maintenance runner has a head/hair silhouette, cyan visor/implant, yellow work jacket, separated legs, boots and an asymmetric arm/visor facing cue. Six pose cells represent idle, walk, charging, rising, falling and landing, read from controller state. It is deliberately replaceable; these are not final character animations. Charge also has a small body-local bar and direction marker.

An original 3×5 bitmap alphabet with a four-pixel advance sits in a seven-pixel native font cell. HUD uses size 7; doubled headings use 14. Do not choose arbitrary font sizes that fractionally scale the raster glyphs. This diagnostic face is compact and intentionally coarse; localization and larger accessibility type are future work. It has ASCII glyph coverage, with uppercase/lowercase sharing forms, not full Unicode/Japanese coverage.

HUD occupies the existing top 25px: state/direction/percentage, thin cyan charge fill and compact debug/reset/pause hints. A dark backing separates it from architecture. Debug details stay optional and update at 10 Hz only while visible. The chamber title appears for 2.2 seconds then fades over 0.8 seconds without blocking input. Essential feedback never depends solely on the title or color. Boot retains Physics Lab access and adds a Power Chamber button; both use the same UI Theme.

## Editable workflow and provenance

1. Edit integer shapes, palette constants, glyph patterns and source placements in tools/generate_art.gd. This script is the editable art source, not an opaque generated binary.
2. Run Godot headless with --script res://tools/generate_art.gd. Review output/logs; exit 0 alone is not enough if errors were printed.
3. Run --headless --editor --path . --import. Commit original PNG/FNT/palette and source .import sidecars; ignore .godot cache. Verify lossless/no-mipmap settings with visual_prototype_test.gd.
4. Reuse IndustrialArt atlas regions through Sprite2D/AtlasTexture; reuse industrial_platform.tscn and industrial_fixture.tscn. Decorative sprites must not acquire invisible collisions.
5. Run full tests. The visual suite protects the exact approved controller, launch calculator, physics Resource, collider scene and camera source, plus the real chamber route.
6. Capture actual scene views with tools/capture_visual_review.gd, inspect native/3× images, document a visible refinement and compare. Review screenshots are excluded from Godot import with .gdignore, but are tracked in Git.

No copyrighted asset was downloaded or extracted, and no paid API or external art tool is required. See asset-manifest.md for provenance. Export presets are still future work; exclude tools/tests/docs from shipping exports when those presets are added.

## Visual quality gate and future rooms

Review at native size and 3×: (1) consistent density/contours; (2) recognizable machinery and structural logic; (3) restrained accent hierarchy and abandoned infrastructure; (4) bright player/ledge contours against subdued decoration; (5) meaningful masses/negative space and upward landmarks; (6) crisp imports, stable animations and renderer compatibility. Automated tests cannot approve mood or taste.

The initial chamber review showed flat contrast between machinery and landings. Refinement adds warning-marked platform ends, subdued midground highlights, faint warm/cool spill, a lit vertical power trunk, framing railing/cables and clearer maintenance hints. Before/after and upper/middle images are in visual-review/milestone-02a. Review captures use actual Godot rendering with staged player positions; they are not claims of manual playthrough.

Stop after 02A delivery for the user's visual approval. Do not build the remaining Sublevel Zero sections, region transitions/checkpoints, hazards, cyberware, combat, narrative or 02B content until separately authorized.
