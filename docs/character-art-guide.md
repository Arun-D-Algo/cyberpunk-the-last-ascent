# David Martinez character art guide

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
