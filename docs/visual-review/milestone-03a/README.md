# Milestone 03A visual review

These are actual Godot Compatibility captures with the shared player staged on supported destinations. Enlargements use nearest-neighbor 4× scaling. The real-controller replay separately verifies traversal.

| View | Native | 4× |
| --- | --- | --- |
| Exterior, emblem and corporate sign | [320×180](exterior_native.png) | [1280×720](exterior_4x.png) |
| Service entrance | [320×180](service_entrance_native.png) | [1280×720](service_entrance_4x.png) |
| Corporate platforming | [320×180](plaza_native.png) | [1280×720](plaza_4x.png) |
| Fan housings and return face | [320×180](ventilation_native.png) | [1280×720](ventilation_4x.png) |
| Ventilation route | [320×180](ventilation_route_native.png) | [1280×720](ventilation_route_4x.png) |
| Radiators and inspection ledges | [320×180](transformer_native.png) | [1280×720](transformer_4x.png) |
| Upper transformer route | [320×180](transformer_route_native.png) | [1280×720](transformer_route_4x.png) |
| Service to ventilation | [320×180](transition_ventilation_native.png) | [1280×720](transition_ventilation_4x.png) |
| Ventilation to transformer | [320×180](transition_transformer_native.png) | [1280×720](transition_transformer_4x.png) |
| Final landing | [320×180](summit_native.png) | [1280×720](summit_4x.png) |

The [full overview](full_layout.png) shows all 36 destinations through a full-height viewport. The [main menu](menu_native.png) identifies the new entry. Compare the [historical tower](../milestone-02d/floor_3.png) for the preceding platform treatment. That historical image contains the earlier character art.

## Refinement

The first render exposed hidden support connections and occluded branding. Reordering layers and relocating the sign restored them. The follow-up added local magenta spill, deeper transformer casings and repeating wall sprites with fewer nodes. Native and enlarged captures were reinspected after these changes.

## Playtest

1. Open project.godot in Godot 4.7.2, run and choose Start Tower Ascent.
2. Inspect the exterior and sign. Walk toward the first casing, hold Space briefly and release. A/D or arrows choose launch direction.
3. Climb the corporate route and check roof highlights against darker architecture.
4. Cross Ventilation Galleries, use the visible return faces and deliberately miss transfers to inspect catches.
5. Climb Transformer Hall and test a long fall from the upper route. Recover and resume climbing.
6. Use W/S or Up/Down to look. Test Esc pause, F3 diagnostics, F6 reset, and the lab and chamber entries.
7. Review repeated modules, art density, character contrast, difficulty and fall penalties before approving expansion.

## Reproduction

Run tools/generate_opening_art.gd headlessly and import when changing the artwork. Run graphical Godot with --resolution 320x180 --fixed-fps 60 --script res://tools/capture_opening_review.gd for captures. The script also samples a short 960×540 render period and exports a full-height overview.

The [region document](../../regions/01-arasaka-substructure.md) records decisions and limitations. The [validation report](../../validation/milestone-03a.md) records measurements. Artistic and manual gameplay approval remain with the owner.
