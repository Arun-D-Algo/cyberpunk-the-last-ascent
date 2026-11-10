# Art direction

## Resolution and scales

Approved starting viewport is 320×180, subject to playtesting. Display at integer multiples with nearest texture filtering, kept aspect and letterboxing where needed. Detailed pixel art must remain readable at native resolution, not merely in zoomed concept art. Current native-font boot UI is temporary and is not the production pixel-font decision.

Proposed reference player canvas is 16×32 pixels, with feet at a consistent origin; validate silhouette and collider readability in M01 before adopting it. A 16-pixel authoring grid is a proposal for tiles, not a restriction on collision placement or platform heights. Record final sprite scale alongside collision dimensions once chosen. Export artwork at native size, without baked scaling or blurry resampling.

## Silhouette and palette

The player must be recognizable against all region palettes with clear feet, head clearance and facing. NPCs need distinct posture and accessory silhouettes without depending on tiny facial detail. Threats, usable platforms and decorative structures need separate shape language. Never copy or trace copyrighted production sprites; placeholder character identities can be expressed as simple original shapes.

Use restrained dark blue/charcoal background values, strong mid-value traversal surfaces, and limited cyan, magenta or warm yellow focal accents. Give regions distinct accent families while retaining shared interaction colors. Hazard meaning must use shape/motion/icons as well as hue. Check value contrast and color-vision simulations during production.

## Neon and effects

Neon lighting should guide attention to routes, interactions and threats. Prefer authored highlights and small localized effects before expensive full-screen processing. Avoid lighting that washes out ledge edges, hides collider boundaries, or creates misleading landable surfaces. Flashes, shake and glitch effects require reduced-motion/flash settings and must not convey indispensable information alone. No shaders or lighting effects are needed for M00.

## Animation and backgrounds

Planned player animation states: idle, ground movement, charge buildup/hold, jump launch, ascent, apex, descent, landing, knockback and interaction. Cyberware/late-game variants are added only when mechanics exist. Keep feet origin stable; animation frames never control body velocity. Read physics state as presentation input, and separate optional anticipation from actual release timing.

Use layered parallax backgrounds with low contrast near platform silhouettes, restrained scroll ratios, and region transitions aligned to world progression. Background layers are visual only and contain no gameplay collision. Validate parallax at fast fall speeds and across loading seams; offer reduced motion when needed.

## UI and audio production

UI should favor compact panels, high-contrast type, clear charge/energy indicators and restrained neon outlines. At 320×180, measure text fit and localization expansion before selecting fonts and panel sizes. Show key prompts from current bindings when remapping exists, rather than embedding letter art. Label temporary indicators honestly.

Original sound cues should reinforce charge, launch, landing and hazards; pair essential cues visually. Compose or license music explicitly. Do not extract anime/game audio or reproduce recognizable soundtrack recordings. Region ambience and music transitions should not mask timing cues. Audio assets are absent in M00.

## Asset workflow and placeholders

Use lower_snake_case names with a category/state suffix, for example player_idle.png, foundry_far.png or vent_warning.wav. Store source sprites in assets/sprites, animation sources in assets/animations, backgrounds/tilesets in their respective folders, and audio by music/SFX/ambience category. Store character display names in content data, not code/file dependencies. Scene and resource names should describe roles when possible.

For every imported production asset record creator, source, license/permission, modifications and intended use in an asset manifest added when the first asset arrives. Retain editable originals in a documented source workflow; commit Godot .import metadata but not generated .godot cache. Review attribution and redistribution rights before export.

Placeholders must be original geometric/native visuals or clearly licensed work, labeled as temporary in their manifest. M00 uses only native controls/default font and solid colors. Do not generate large placeholder libraries. Future workflow: approve scale/palette sheet, create one representative sprite/tile, import with nearest filtering, review at native size in engine, validate collision readability, then expand the set. Asset replacement must not change collision reach inadvertently.
