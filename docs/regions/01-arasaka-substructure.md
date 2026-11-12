# Arasaka Substructure — opening ascent

## Delivered scope

Milestone 03A implements one continuous opening through Corporate Plaza and Service Entrance, Ventilation Galleries, and Transformer Hall. Start Tower Ascent enters scenes/levels/opening_ascent.tscn. The original four-floor prototype remains available at scenes/levels/tower_ascent.tscn for regression testing.

The route has 36 intentional destinations over 1,760 vertical pixels, from feet y144 to y−1616. Camera bounds span 2,080 pixels including look clearance. The authored scene occupies continuous coordinates and classifies sections by altitude. Ordinary falls can cross both boundaries.

| Section | Destinations | Feet coordinates | Rise |
| --- | ---: | --- | ---: |
| Corporate Plaza and Service Entrance | 10 | y144 to y−312 | 456 px |
| Ventilation Galleries | 12 | y−312 to y−880 | 568 px |
| Transformer Hall | 14 | y−880 to y−1616 | 736 px |

## References and art decisions

The user explicitly authorized existing project art, the written brief, the Neon Industrial Decay palette and the corporate service / neon power / substructure hybrid as primary references. No external reference images were used or claimed as inspected. Existing industrial atlas artwork and prior rendered tower views were inspected directly.

Original assets use dark navy #080D18, steel #172638, slate #34475A, magenta #F04775, pink #F02D87, cyan #00D9E8 and warning yellow #F5D547. Dark architectural masses dominate. Pink identifies corporate signage and wall attachments. Cyan identifies powered equipment. Bright pale roof edges identify collision surfaces.

The plaza uses tall recessed facade bays, city windows, two service gates, a corporate emblem, ARASAKA wordmark and SECURITY IS PROGRESS display. The ventilation section uses paired intake housings, broad ducts, animated fans and steam. The transformer section uses radiator fins, insulators, cable trunks, monitors and intermittent electrical accents. Section signage identifies facilities and transitions.

Each casing has an architectural wall attachment drawn on a recessed plane. The shaded support braces, background fans, transformer masses and doors belong to that rear plane. Foreground machine roofs and full casing rectangles are solid. The four return faces are visible structural members with solid tops, sides and undersides. No invisible physics bodies are attached to ambient effects.

The first render exposed an incorrect layer order that hid support braces and covered branding. The refinement moved the recessed layers behind the attachments, relocated the sign to clear gameplay geometry and added restrained local magenta spill. Transformer casings gained deeper radiator bodies and were revalidated with their final collisions.

## Reusable assets and components

| Source | Responsibility |
| --- | --- |
| scripts/core/opening_route.gd | 36 editable destinations, section rises, widths, casing types and return-bank placement |
| scripts/core/opening_ascent.gd | Scene composition and section classification, with inherited pause/reset/input behavior |
| scripts/environment/opening_machine.gd | Solid casing with matching collision and cropped native-pixel artwork |
| scripts/environment/opening_backdrop.gd | Finite architecture, 6% distant parallax, supports, corporate signs and ambient fixtures |
| tools/generate_opening_art.gd | Original raster source using the existing integer-art helpers |
| assets/environment/opening/machinery.png | Nine casing materials, including glass booth, cargo ribs, canopy truss, cabinet, duct, fan grille, radiator and lift |
| assets/environment/opening/city_depth.png | Distant city windows and tower silhouettes |
| assets/environment/opening/facade.png | Corporate facade bays |
| assets/environment/opening/ventilation.png | Ducts and intake housings |
| assets/environment/opening/wall.png | Repeating solid boundary-column texture |
| assets/environment/opening/transformers.png | Insulators, radiator banks and cable trunks |

Shared Player, David atlas and animation resources, JumpPhysics, surface profiles and LabCamera are reused directly. IndustrialArt supplies the original bitmap lettering and door assets. IndustrialFixture supplies the existing fan, monitor, lamp, spark and steam animations. Scenery uses pausable processing.

Regenerate the artwork with Godot headless and tools/generate_opening_art.gd, then import. Assets use lossless compression, nearest filtering and no mipmaps. The internal resolution, Compatibility renderer and 60 Hz simulation retain their baseline configuration.

## Route and collision rules

Every machine uses its complete rectangular casing for collision, with layer 1 and mask 2. Casing depths range from 8 pixels for return ledges through 12–16 pixel housings to 24 pixel transformer radiators. Roof widths range from 32 to 64 pixels. The player's 10×24 collider and movement configuration match the approved revision.

Deep early blockout housings obstructed nearby trajectories. Their clearances were corrected in route data. The opening roof was lowered to a 16-pixel rise and uses a short charge. Later rises reach 60 pixels against the measured 69.015-pixel maximum. The minimum-to-maximum same-height range remains 15.006–132.007 pixels.

The intended route exercises four deliberate side rebounds. Alternative paths and lower catches are possible because the geometry stays continuous. The test verifies the intended sequence, including walking between launches, with no reset between its 36 landings. Each destination also receives adjacent 60 Hz charge-tick and ±2-pixel launch-position probes. These local probes establish repeatability near the recorded recipe, rather than a complete enumeration of every possible approach.

See the [reachability report](../validation/milestone-03a.md) for actual launch recipes, measured rises, neighboring input outcomes and fall measurements.

## Camera, recovery and difficulty

The scene configures the existing camera's world bounds. Camera tracking, dead zone, look distance, player visibility clamp and reset behavior use the existing implementation. Wide base geometry catches falls at the bottom. There are no automatic section teleports.

Fall tests walk off real destinations, retain the controller's airborne momentum, wait for supported contact and check fresh charge recovery. The summit fall returns through earlier sections. The recovery replay walks to a launch position and rejoins the next route destination.

Assisted and Classic are existing design/resource concepts. The current tower runtime has no selectable checkpoint or difficulty policy. This milestone retains that runtime behavior. The lab's CLASSIC selector denotes its original fixture.

## Review and limitations

The [visual-review package](../visual-review/milestone-03a/README.md) contains staged actual Godot captures at native size and 4×, both transitions, the summit, environmental examples and a full vertical overview. These captures establish rendering and composition. The continuous solver replay establishes reachability. Human route difficulty, pacing and artistic approval remain pending.

The route has a deliberately compact 320-pixel horizontal footprint. Some architectural modules repeat, and supports are depicted on a recessed decorative plane. Large background fan and transformer assemblies are decorative. Landing cues use brighter solid roof edges. Review this distinction in play.

No human playtime estimate or broad hardware performance claim is made. The scene uses finite textures and a bounded number of ambient fixtures without particle systems, scene streaming or per-frame tree searches.

## Next review and future sections

Review the exterior, service access, ventilation, transformer machinery, route length, input tolerances and setbacks before expanding production. The Powerworks, Coolant Distribution, Freight Elevator Shaft, Security Transfer and Atrium Threshold are recorded future sections. Their implementation requires the user's next approval.
