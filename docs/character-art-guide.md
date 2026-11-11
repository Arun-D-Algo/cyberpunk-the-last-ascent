# David Martinez character art guide

## Milestone 02G airborne refinement

The 02G attachment is a full-body David illustration. I inspected the spiked dark-brown crown, exposed forehead, narrow jaw, asymmetrical jacket opening, blue collar and folds around the loose knees and cuffs. The 02F standing key from the committed atlas is the before comparison. Earlier user attachments and the publisher reference research below provide context. The 02G pixel clusters and motion keys are original artwork.

The current renderer reuses the 02F ground poses. The head keeps its original height and fits a stepped forehead, cheek and chin into a compact right-facing profile. A dark brow and restrained cheek highlights define the face. The head draws over the sleeves where an airborne gesture crosses the jaw. The near lapel covers the lower left side of the shirt and the far edge tapers into shadow. The trousers use six fabric pixels through the thigh and knee with a folded highlight, dark crease, tapered cuff and separate sole. These clusters carry across all frames.

The 40×40 cells provide horizontal room for open arms and rising jacket hems. The 240×520 atlas contains 37 distinct authored keys across 13 animations. The origin is (20, 38). Ground poses plant a sole on row 37 at native pixel density. Jacket tails rise from their seams and grow wider with each fall phase. Offset folds alternate during each phase while the collar and front panels keep their place on the torso.

| Animation | Keys | Timing or selection |
| --- | ---: | --- |
| Idle / walk / charge | 4 / 6 / 4 | Existing planted bob, speed-driven walk and charge fraction |
| Launch / rise / apex | 3 / 3 / 1 | 100 ms visual takeoff, then ascending keys and open apex pose from −40 px/s |
| Early fall / normal / fast | 2 / 3 / 3 | 10 / 12 / 14 fps. Entry thresholds of 75 and 315 px/s downward |
| Land / ordinary slide / forced slide / impact | 2 each | Existing recovery, slide and impact selection |

The two fall thresholds are inspector properties on Player Visual. A 24 px/s hysteresis band keeps each pose stable until descent speed drops below 51 or 291 px/s with the defaults. The wall-impact pose takes visual priority and resumes the current fall band afterward. The wider sleeves and hems may extend outside the 10×24 gameplay collider. At native resolution a few pixels represent each facial feature and fabric fold. The artwork awaits owner review.

Regenerate the active atlas and SpriteFrames with Python 3 and tools/generate_david_02g.py. It reuses the 02F pose data and frame exporter. The 02F exporter still reproduces its existing files byte for byte. See the [02G review package](visual-review/milestone-02g/README.md) for comparison sheets, air poses and Godot captures.

## Milestone 02F prototype

The user's current-sprite screenshot was the primary before reference. The attached front-facing bead artwork informed jacket mass, wide sleeves, dark blue trousers and separated shoes. The attached back-facing pixel artwork informed the shoulder span, collar and balance stance. All three were inspected directly. The 02E publisher guide research below remains reference context. The new pixel clusters were authored for this project and the attachments are outside distributed assets.

The canvas is **32×40** compared with **24×40** in 02E. The **192×400** atlas has **28** original keys. The feet pivot is **(16, 38)** and planted soles occupy row 37. The compact face fits under the hairline, the near and far sleeves have separate outlines, and each trouser leg has a four-pixel fabric span in its wider sections. The yellow jacket retains cool collar and reflective sleeve highlights. The 10×24 collision body sits within the wider silhouette, so the visual sleeves and shoes can overlap nearby scenery.

| Animation | Frames and behavior |
| --- | --- |
| Idle | 4 keys, 2-pixel vertical upper-body bob with both shoes planted |
| Walking | 6 keys with independent leg placement and sleeve swing |
| Charge | 4 keys, planted feet, outward knees and up to 6 pixels of torso compression |
| Launch, rise, fall, land | 2 keys each with separate limbs and crouch extension or recovery |
| Ice or ordinary slide | 2 keys, standing balance |
| Forced slide | 2 keys, low braced stance and extended downhill foot |
| Wall impact | 2 keys, abbreviated raised-arm reaction |

Run tools/generate_david_02f.py with Python 3 to regenerate the new PNG and SpriteFrames. The first render review exposed a detached-looking far sleeve and a flat facial edge. The second pass connected the shoulder and adjusted the brow, cheek and jaw. The [review package](visual-review/milestone-02f/README.md) contains both facings, the old and new sprites, native and enlarged views and all animation keys. Final likeness and motion approval remain with the owner.

Milestone 02E supplies an original animated pixel-art prototype based on the early-series David design. The cues are swept spiked hair with a shaved temple, a warm face, a raised cyan-lined collar, a yellow jacket with a silver sleeve stripe, a black shirt, a small gold pendant, dark cuffed trousers and light-soled sneakers.

## Reference manifest

| Reference | Reviewed material | Takeaway | User supplied |
| --- | --- | --- | --- |
| [CD PROJEKT RED David cosplay guide](https://cdn-s-cyberpunk.cdprojektred.com/cosplay-guides/DAVID_MARTINEZ_COSPLAY_GUIDE_EN.pdf) | Published front, three-quarter, head and costume image descriptions. Full PDF raster fetch exceeded the browser tool size limit. | Hair shape and undercut, face, early-series black shirt, layered yellow jacket, silver accents and cool collar | No |
| [CD PROJEKT RED Edgerunners update](https://blog.playstation.com/?p=369114) | Developer's account of the jacket and its significance | Yellow jacket as primary recognition cue | No |
| [David turnaround reproduced by Cultura Geek](https://culturageek.com.ar/la-nueva-actualizacion-del-cyberpunk-2077-une-el-juego-con-su-anime-edgerunners/) | Image search description of front, back and side turnaround. Direct image fetch supplied no readable visual output. | Side silhouette, rolled trousers, footwear and reflective stripes | No |
| [Katana ZERO](https://store.steampowered.com/app/460950/Katana_ZERO/) | Publisher listing and indexed gameplay still descriptions | Compact limbs and strong silhouette against neon | No |
| [SANABI](https://store.steampowered.com/app/1562700/SANABI/) | Publisher listing and indexed industrial traversal still descriptions | Distinguish airborne poses through limbs and leading direction | No |
| [The Last Night](https://oddtales.net/thelastnight/) | Studio production page and trailer scene index | Separate a small character from layered backgrounds with local contrast | No |

Reference review used the accessible publisher pages and image descriptions. No user reference art was attached. The pose clusters are original pixel placements. Reference artwork is outside the source asset set.

## Scale and palette

Each cell is **24×40** at one source pixel per logical gameplay pixel. Idle art occupies about 31 pixels vertically, close to the old visual's 32-pixel cell height. Transparent space accommodates the reaching arm, spread feet and crouch. The foot pivot is **(12, 38)**, with ground-contact soles on row 37. The 10×24 collider represents the gameplay body, so hair, arms and jacket extend visually beyond it. The atlas is **144×360**.

| Role | Hex values |
| --- | --- |
| Outline and hair | #131321, #302030, #57343B, #915C49 |
| Skin and pendant highlights | #A36052, #CF8966, #F2B287, #FFE1AD |
| Shirt, trousers and soles | #222438, #414C66, #687791, #9DAFB8 |
| Collar | #288EAE, #63D9E2 |
| Jacket and sleeve | #9A591E, #D88C26, #F4C442, #FFE46C, #E1E9E6, #F66A55 |

## Animation keys and timing

| Atlas row / pose | Frames | Selection |
| --- | ---: | --- |
| 1 Idle | 3 | 3 fps loop. Breathing and blink with planted soles |
| 2 Walk | 6 | 10 fps at configured ground speed. Time advances in proportion to tangent speed |
| 3 Charge | 4 | Indexed by actual charge fraction, from preparation to full compression |
| 4 Launch | 2 | 30 fps extension, triggered by the jump signal for about 67 ms |
| 5 Rising | 2 | 8 fps tucked rising loop |
| 6 Falling | 2 | 8 fps open stance loop |
| 7 Landing | 2 | Selected by the existing landing recovery progress |
| 8 Sliding | 2 | 7 fps braced balance loop, facing travel |
| 9 Wall impact | 2 | 20 fps for about 100 ms after a rebound, facing the struck wall |

Visual receives fixed-tick and event updates from the shared player. Charging and landing have priority over airborne reactions. Reset clears animation time, facing and one-shot timers. The player scene creates the same AnimatedSprite2D and SpriteFrames in the main game, chamber and lab.

## Production and review

Run Python 3 on tools/generate_david.py from the project. The standard-library generator writes the lossless RGBA atlas and the matching SpriteFrames definition. Edit the palette-indexed clusters and pose keys, regenerate both, then import through Godot. Preserve the source pixel grid and feet pivot. Run tests/run_validation.ps1 with the Godot console executable to check distinct frames, actual input-driven pose transitions, shared scene integration and collider invariants.

The [review package](visual-review/milestone-02e/README.md) includes the native atlas, dark and light nearest-enlarged comparisons, charge and walk strips, and actual Godot tower and ramp captures. The first review led to a stronger undercut silhouette, brighter cuffs and sneaker soles and an extended reach arm. At native scale check the jacket first, then hair silhouette, shoe contact, crouch compression and airborne pose readability. The early-series likeness, clothing motion and proportions remain prototype art for owner review.
