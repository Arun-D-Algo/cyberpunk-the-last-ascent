# Development session summary - 11 November 2026

## Outcome and owner approval

Cyberpunk: The Last Ascent now has a playable continuous four-floor tower prototype, a shared precision-platforming controller, original industrial visuals and a real-body validation suite. After testing the final physics, the project owner explicitly approved it:

> "Okay, the physics is working perfectly fine now. I'm genuinely happy with whatever we came up with today."

This records physics/game-feel approval. It does not imply approval of the future eight-region campaign, final artwork, release builds or untested platforms. Session work spans 10-11 November 2026 in Asia/Calcutta; this summary records the accepted state on 11 November.

## Work delivered

| Milestone | Completed work |
| --- | --- |
| 00 | Existing Godot project foundation, InputMap, project conventions, core design documentation and smoke/static validation |
| 01 | Shared charge-and-release controller, grounded/charging/rising/falling/landing states, original jump equations, camera/recorder/HUD and Classic lab route |
| 02A | Original pixel-art sprites/atlases/font, industrial platforms/fixtures/backgrounds and Emergency Power Chamber visual slice |
| 02B | Resource-driven surface/contact rules, ice, real polygon slopes, gravity ramps, moving-platform fixtures and selectable Physics Lab 2.0 sections |
| 02D | Controllable ice, fractional/interpolated presentation, universal wall/platform-side rebounds, deliberate ricochet scenarios and the connected main ascent |

No separate 02C implementation is inferred. Detailed historical decisions and measurements are retained in [development-log.md](development-log.md).

## Final mechanics

Hold Space to charge, choose A/D or Left/Right, then release. Air steering remains disabled by default; no double jumping or automatic charge buffering was introduced. The normal jump envelope remains 69.015px maximum rise and 132.007px same-height range.

Moderate ice uses 405px/s2 acceleration, 810px/s2 reverse braking, 144px/s2 released drag, .68 landing retention and a 12px/s charge eligibility threshold. Accepted charging is stationary; tiny residual motion snaps to rest. Mild and optional extreme profiles remain separately configurable.

| Measured from 65px/s | Before / preserved extreme | Moderate default |
| --- | ---: | ---: |
| Released stopping distance | 69.875px | 14.127px |
| Released stopping time | 2.167s | .450s |
| Opposite-input reversal distance | 10.117px | 2.042px |
| First negative velocity | .333s | .083s |

Ordinary airborne side impacts use .6 restitution above 30px/s horizontal relative velocity. Vertical momentum is preserved; moving-side response uses collider-relative velocity once. Persistent contact tracking suppresses repeat impulses, ceilings take priority at corners, and supported walking corners remain stable. Optional diagonal redirects are energy-bounded and rising-only, once per jump. Ordinary top surfaces land normally; special top restitution is opt-in.

The sprite and camera no longer round their transforms. Nearest-filtered `canvas_items` rendering and Godot 2D interpolation allow finer displayed movement at the physical window resolution while simulation stays at 60Hz. A physical 320x180 window remains limited to its physical pixels. Existing asset PNGs were preserved.

## Main playable route

| Floor | Vertical length | Landing destinations |
| --- | ---: | ---: |
| Public Access | 720px | 15 |
| Commercial Atrium | 736px | 15 |
| Restricted Infrastructure | 732px | 15 |
| Maintenance Ascent | 820px | 15 |
| Total | 3,008px | 60 |

The reference route exercises eight ricochets, six moderate-ice landings and two controlled ramp/runout landings. The tower, laboratory and chamber instantiate the same player scene/controller/physics Resources. Floors share continuous world coordinates, with reusable theme Resources and temporary tints/signage. There are no transition teleports, automatic checkpoints or loading screens.

## Validation evidence

Godot version: `4.7.2.stable.official.ed1daf0bf` on Windows. Latest implementation validation passed:

| Check | Result |
| --- | --- |
| Static source contracts | 226 checks |
| Movement/physics integration | 177 checks |
| Visual assets and keyboard input | 168 checks |
| Surface mechanics | 633 checks |
| Refinement/rebound behavior | 115 checks |
| Tower reachability/integration | 393 checks |
| Import, boot/chamber/tower startup and smoke | Passed |
| 30/60/120 render-cadence probes | Passed |
| Actual Compatibility-renderer captures | Captured and visually reviewed |

A separate continuous solver replay reaches all 60 destinations and verifies the expected collision sequences without inter-platform resets. Ideal simulation time is 115.467 seconds; that is not a human completion-time claim. The summit fall test drops 1,263.750px at up to 600px/s into floor 3, lands, recovers, charges, pauses and explicitly resets successfully. All measured recipes are in [the validation report](validation/milestone-02d.md).

Reproduce validation from the checkout with PowerShell:

```powershell
.\tests\validate_static.ps1
.\tests\run_validation.ps1 -GodotExe 'C:\path\to\godot_console.exe'
```

The runner isolates writable AppData/cache/log paths beneath ignored `.godot`. Game source, design documentation, original source assets, import/UID sidecars and reviewed screenshots belong in Git; generated caches, logs, exports and credentials do not.

## Remaining scope

Physics is accepted by the owner. Full-route pacing/variety, final floor art, prolonged hardware performance, exported builds and Linux behavior remain separate work. The final eight-region campaign, story scenes, combat, cyberware, hazards, saves and release packaging are future scope. Some return banks permit alternative routes/charges. Human approval does not replace regression testing when physics or geometry changes.

The project remains an unofficial fan work. The existing rights/provenance notes in README and the asset manifest apply; publishing source does not create a third-party IP license.

## Repository handoff

The owner authorized creating a **public** GitHub repository named `cyberpunk-the-last-ascent` and pushing the full development history, documentation and assets. Publication verification is performed against the remote main branch after pushing. No generated engine cache or credentials are included.
