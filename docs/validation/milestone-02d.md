# Milestone 02D measured validation

Godot 4.7.2.stable.official.ed1daf0bf, Windows, fixed 60Hz simulation. Final acceptance results are also summarized in development-log.md.

| Floor | Height range above base | Length | Landings | Main focus |
|---|---:|---:|---:|---|
| Public Access | 0-720 px | 720 px | 15 | Wide pads, varied rises, introductory return banks |
| Commercial Atrium | 720-1456 px | 736 px | 15 | Narrower pads, long transfers, raised side/underside clearance |
| Restricted Infrastructure | 1456-2188 px | 732 px | 15 | Moderate ice, controlled ramp/runout, rebound combinations |
| Maintenance Ascent | 2188-3008 px | 820 px | 15 | 24-40px ledges, 52-60px rises, ice/ramp/bank combinations |

Continuous reference replay: 115.467s simulation time. No resets/teleports between the 60 landings. Discovery resets are a separate search pass. Eight return banks are verified against actual collision impulses.

Long fall: {'drop': 1263.75012207031, 'landing_y': -1600.01867675781, 'peak_speed': 600.0, 'seconds': 2.41666666666667, 'start_y': -2863.76879882813, 'zone_after': 3}

## Ice measurements

Times in seconds, distances in pixels. Landing coast starts after the same recovery interval. Extreme is the 02B comparison profile.

```json
{
  "ice": {
    "landing_release": {
      "distance_after_recovery": 35.7000122070313,
      "seconds_after_recovery": 0.716666666666667
    },
    "release": {
      "distance": 14.1266622543335,
      "seconds": 0.45
    },
    "reverse": {
      "distance": 2.04166674613953,
      "seconds": 0.0833333333333333
    }
  },
  "ice_extreme": {
    "landing_release": {
      "distance_after_recovery": 372.748336791992,
      "seconds_after_recovery": 4.98333333333333
    },
    "release": {
      "distance": 69.8750228881836,
      "seconds": 2.16666666666667
    },
    "reverse": {
      "distance": 10.1166715621948,
      "seconds": 0.333333333333333
    }
  },
  "ice_mild": {
    "landing_release": {
      "distance_after_recovery": 4.45835876464844,
      "seconds_after_recovery": 0.183333333333333
    },
    "release": {
      "distance": 6.50000095367432,
      "seconds": 0.216666666666667
    },
    "reverse": {
      "distance": 1.08333361148834,
      "seconds": 0.0666666666666667
    }
  }
}
```

## Ricochet scenarios

```json
{
  "I WALL": {
    "air": 0.616666666666667,
    "charge": 0.75,
    "landing": "(176.8311, 95.98129)",
    "rebounds": 1,
    "rise": 69.0152130126953
  },
  "J PAD SIDE": {
    "air": 0.616666666666667,
    "charge": 0.75,
    "landing": "(176.8311, 95.98129)",
    "rebounds": 1,
    "rise": 69.0152130126953
  },
  "K SHAFT": {
    "air": 0.5,
    "charge": 0.75,
    "landing": "(174.9989, 79.98131)",
    "rebounds": 2,
    "rise": 69.0153045654297
  },
  "L RISING": {
    "air": 0.566666666666667,
    "charge": 0.700000000000001,
    "landing": "(164.2244, 95.9813)",
    "rebounds": 1,
    "rise": 63.1855545043945
  },
  "M ICE BANK": {
    "air": 0.616666666666667,
    "charge": 0.75,
    "landing": "(176.8311, 95.98129)",
    "rebounds": 1,
    "rise": 69.0154571533203
  },
  "N DIAGONAL": {
    "air": 0.633333333333334,
    "charge": 0.700000000000001,
    "landing": "(165.2972, 95.98129)",
    "rebounds": 1,
    "rise": 65.2150802612305
  }
}
```

## All mandatory landing recipes

World Y decreases upward. Hold timings are quantized to 60Hz; launch x is a reference position reached on foot. Landing coordinates are measured from the discovery simulation; the separate continuous replay asserts the same landing bodies and collision counts.

| Pad | Launch X | Hold s | Direction | Measured landing (x,y) | Rebounds |
|---|---:|---:|---|---|---:|
| Z1_01 | 110.0 | 0.750 | right | (222.7573, 111.9813) | 0 |
| Z1_02 | 200.0 | 0.750 | left | (100.9927, 59.98129) | 0 |
| Z1_03 | 112.0 | 0.750 | right | (216.5073, 15.9813) | 0 |
| Z1_04 | 216.0 | 0.750 | left | (127.9927, -36.0187) | 0 |
| Z1_05 | 104.0 | 0.750 | right | (154.8311, -84.01871) | 1 |
| Z1_06 | 156.0 | 0.667 | left | (73.21384, -128.0187) | 0 |
| Z1_07 | 92.0 | 0.750 | right | (191.0073, -180.0187) | 0 |
| Z1_08 | 188.0 | 0.733 | left | (90.73187, -228.0187) | 0 |
| Z1_09 | 112.0 | 0.750 | right | (200.0073, -280.0187) | 0 |
| Z1_10 | 216.0 | 0.750 | left | (165.1689, -328.0187) | 1 |
| Z1_11 | 164.0 | 0.700 | right | (255.1848, -372.0187) | 0 |
| Z1_12 | 228.0 | 0.750 | left | (139.9927, -424.0187) | 0 |
| Z1_13 | 132.0 | 0.717 | right | (224.8756, -472.0187) | 0 |
| Z1_14 | 200.0 | 0.750 | left | (100.9927, -524.0187) | 0 |
| Z1_15 | 112.0 | 0.750 | right | (211.0073, -576.0187) | 0 |
| Z2_01 | 216.0 | 0.750 | left | (114.2427, -624.0187) | 0 |
| Z2_02 | 104.0 | 0.733 | right | (201.2681, -672.0187) | 0 |
| Z2_03 | 208.0 | 0.750 | left | (106.2427, -720.0187) | 0 |
| Z2_04 | 120.0 | 0.750 | right | (219.0073, -772.0187) | 0 |
| Z2_05 | 200.0 | 0.750 | left | (149.1689, -820.0187) | 1 |
| Z2_06 | 148.0 | 0.667 | right | (228.2777, -868.0187) | 0 |
| Z2_07 | 212.0 | 0.750 | left | (112.9927, -920.0187) | 0 |
| Z2_08 | 116.0 | 0.750 | right | (217.7573, -968.0187) | 0 |
| Z2_09 | 208.0 | 0.750 | left | (128.2427, -1016.019) | 0 |
| Z2_10 | 120.0 | 0.750 | right | (170.8311, -1064.019) | 1 |
| Z2_11 | 172.0 | 0.700 | left | (83.42032, -1112.019) | 0 |
| Z2_12 | 108.0 | 0.750 | right | (207.0073, -1164.019) | 0 |
| Z2_13 | 204.0 | 0.750 | left | (102.2427, -1212.019) | 0 |
| Z2_14 | 104.0 | 0.750 | right | (205.7573, -1260.019) | 0 |
| Z2_15 | 208.0 | 0.750 | left | (108.9927, -1312.019) | 0 |
| Z3_01 | 120.0 | 0.750 | right | (221.7573, -1360.019) | 0 |
| Z3_02 | 200.0 | 0.750 | left | (98.24274, -1408.019) | 0 |
| Z3_03 | 112.0 | 0.750 | right | (226.6573, -1456.019) | 0 |
| Z3_04 | 216.0 | 0.700 | left | (127.4203, -1504.019) | 0 |
| Z3_05 | 104.0 | 0.750 | right | (154.8311, -1552.019) | 1 |
| Z3_06 | 156.0 | 0.700 | left | (67.42032, -1600.019) | 0 |
| Z3_07 | 92.0 | 0.750 | right | (198.0255, -1652.0) | 0 |
| Z3_08 | 188.0 | 0.683 | left | (89.79936, -1700.019) | 0 |
| Z3_09 | 112.0 | 0.750 | right | (191.7573, -1748.019) | 0 |
| Z3_10 | 216.0 | 0.750 | left | (165.1689, -1796.019) | 1 |
| Z3_11 | 164.0 | 0.683 | right | (248.3804, -1844.019) | 0 |
| Z3_12 | 228.0 | 0.750 | left | (139.9927, -1896.019) | 0 |
| Z3_13 | 132.0 | 0.683 | right | (228.2244, -1944.019) | 0 |
| Z3_14 | 200.0 | 0.750 | left | (98.24274, -1992.019) | 0 |
| Z3_15 | 112.0 | 0.750 | right | (211.0073, -2044.019) | 0 |
| Z4_01 | 216.0 | 0.750 | left | (116.9927, -2096.019) | 0 |
| Z4_02 | 112.0 | 0.750 | right | (205.5072, -2152.019) | 0 |
| Z4_03 | 208.0 | 0.717 | left | (105.7212, -2204.019) | 0 |
| Z4_04 | 120.0 | 0.750 | right | (210.7572, -2264.019) | 0 |
| Z4_05 | 200.0 | 0.750 | left | (149.1689, -2312.019) | 1 |
| Z4_06 | 148.0 | 0.667 | right | (218.2439, -2368.019) | 0 |
| Z4_07 | 212.0 | 0.750 | left | (113.3195, -2423.911) | 0 |
| Z4_08 | 116.0 | 0.733 | right | (215.9094, -2480.019) | 0 |
| Z4_09 | 208.0 | 0.750 | left | (114.4928, -2536.019) | 0 |
| Z4_10 | 120.0 | 0.750 | right | (170.8311, -2584.019) | 1 |
| Z4_11 | 172.0 | 0.683 | left | (92.73318, -2636.019) | 0 |
| Z4_12 | 108.0 | 0.750 | right | (198.7572, -2696.019) | 0 |
| Z4_13 | 204.0 | 0.750 | left | (97.59275, -2752.019) | 0 |
| Z4_14 | 104.0 | 0.750 | right | (203.0072, -2804.019) | 0 |
| Z4_15 | 208.0 | 0.750 | left | (117.2428, -2864.019) | 0 |

## Scope and limitations

Real-body solver tests establish reachability, friction, collision response and recovery. They do not establish subjective enjoyment, several-minute human completion times, long-session performance, Linux/export compatibility or human physical-key timing. The tower uses finite loaded geometry; alternative routes/charges may bypass some banks. No automatic checkpoint or campaign difficulty mode was added.
