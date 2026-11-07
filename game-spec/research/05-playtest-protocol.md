# 05: Play-test protocol for MSM2 / MSM3

The goal is to turn "it feels great" into numbers the spec can target. Anyone on the team can run this on their own phone or browser. Studying a game by playing it is allowed. Don't extract game files, and don't reuse their art, audio or tracks. Recordings are for internal reference only.

## Setup

- **Devices:** MSM2 (iOS/Android), MSM3 (iOS/Android), and the MSM2 web version on Poki in a desktop browser. Poki is the easiest to measure.
- **Recording:** use the phone's built-in screen recorder at 60 fps (120 if available), or OBS on desktop.
- **Analysis:** any video tool that steps frame by frame (e.g. Kinovea, which is free, or a video editor). Frames ÷ fps = seconds.
- **Ruler:** use the bike's **wheelbase** as the unit of length ("bike-lengths", BL). A real 450cc MX bike's wheelbase is about 1.48 m, which converts BL to metres if needed.
- **Log for every clip:** game, version, track name, bike, upgrades, device, and fps.

## Measurements

| # | What | How | Record |
|---|---|---|---|
| 1 | **Gravity / air time** | On 3 different jumps, count frames from takeoff to landing and estimate peak height in BL | t (s), h (BL); estimated g = 8h / t² |
| 2 | **Air rotation** | From level flight, hold full lean-back. Count frames for 90°, 180°, 360°. Repeat for lean-forward | deg/s at each mark. Does rotation **speed up** (torque) or start at full speed? |
| 3 | **Rotation after release** | Let go of lean mid-spin | Keeps spinning / slows / stops at once? |
| 4 | **Wheelie / stoppie** | On flat ground, hold the longest wheelie and stoppie you can | Max hold time; how many corrections it needed; does it gain or lose speed? |
| 5 | **Acceleration** | From a standstill on flat ground, full throttle | Time to top speed; top speed in BL/s |
| 6 | **Braking** | Full brake from top speed | Stopping distance in BL; does the bike pitch forward? |
| 7 | **Landing tolerance** | Land the same jump at deliberately varied angles | Crash / survive at each angle. Speed before vs after landing. Is landing on a downslope rewarded? |
| 8 | **Crash rules** | Note what caused each crash | Head contact? Over-rotation? Hard landing? |
| 9 | **Respawn and retry loop** | Time from crash to controlling the bike again, and from the finish to the next race | ms. Does a crash restart the race, respawn you nearby, or add a penalty? |
| 10 | **Boost / rockets** | Fire on flat ground, uphill and in the air | Duration, speed increase, uses per race, usable in air? |
| 11 | **Camera** | Watch zoom at low speed, top speed and big air | Zoom range, how far it looks ahead, smoothing lag |
| 12 | **Track anatomy** | For 5 tracks: total time of a good run, number of jumps, whoops/rhythm sections, start procedure (gate, countdown, holeshot) | Table per track |
| 13 | **Opponents** | AI riders vs ghosts. Can they collide with you? How is the position shown? | Notes |
| 14 | **Controls** | Screenshot the touch layout. Note tilt options and assist settings | Diagram |
| 15 | **Upgrades** | Compare the same track before and after an engine or suspension upgrade | % change in top speed / air time |
| 16 | **Audio feedback** | Engine pitch vs speed, landing sounds, near-crash cues | Notes |
| 17 | **Feel ratings** (1–5) | Weight, responsiveness, forgiveness, sense of speed, "one more try" pull | Score plus one sentence each |
| 18 | **Monetisation touchpoints** | Where ads, IAP prompts, energy or time limits appear | List. This informs our model; we don't copy it |

## MSM3-specific

- **Whips:** what input triggers one, how long it takes to recover before landing, and the crash risk if you land mid-whip.
- **2D vs 3D:** does the 3D camera change how readable jumps are? Compare against MSM2 on the same kind of jump.

## Output

Put one row per measurement in a shared sheet (columns: game, track, measurement, value, unit, clip link, tester). Measurements 1–11 become the **feel targets** section of the spec.
