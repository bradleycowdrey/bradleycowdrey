# 06: Findings and spec inputs

This pulls together documents 01–05: what we learned, which decisions the spec has to make, and a recommendation for each. Decisions marked **(you)** are business or product calls for the team, not technical ones.

## Five things the research made clear

1. **The genre "feel" rests on a shared skeleton:**
   - a bike frame plus two wheels on spring-damper suspension;
   - only the wheels and the head touch the ground;
   - head contact = crash;
   - a fixed-rate physics clock.

   X-Moto and Elma both use it. MSM almost certainly does too, since its physics is a custom 2D C++ engine ([01](01-version-survey.md)).
2. **Both genre ancestors run in slow motion:** X-Moto at 0.6× and Elma at 0.44× real time.
   - That makes gravity feel low compared with the bike, which buys air time for controlling rotation.
   - **"Time scale" and "gravity" are the two most important feel settings,** and the spec has to set them on purpose from measurements ([05](05-playtest-protocol.md), test 1).
3. **Neither ancestor has real weight shift.** In both, the rider is a cosmetic puppet, and leaning just twists the frame.
   - MSM riding *looks* like the rider moves their weight around.
   - **This is the main open physics question.** Our spec has to decide it, and a prototype has to confirm it.
4. **Neither ancestor can verify a time.**
   - Both replay systems store recorded positions, not inputs. Elma isn't even deterministic, and its fan successor had to retrofit determinism, imperfectly.
   - **Box2D v3 offers cross-platform determinism.** That makes "store inputs, re-simulate on the server" possible: tiny ghost files and leaderboards that can be checked ([04](04-box2d-notes.md)).
5. **What keeps players coming back is retry speed and comparison, not content volume.**
   - Instant one-key restart, intro skipped.
   - Always-on ghosts (your best plus the best you're chasing), split times, and medals relative to a target time.
   - Every reference does these things.

## Decisions for the spec

| # | Decision | What the references do | Recommendation |
|---|---|---|---|
| D1 | **Core structure** | MSM: linear left-to-right racing on short tracks. X-Moto/Elma: exploration puzzles with collectibles | **Linear racing**, tracks of 20–60 s. Collectibles at most as an optional side goal |
| D2 | **Physics engine** | MSM: custom C++. X-Moto: ODE + Chipmunk. Elma: custom | **Box2D v3** (MIT), for its wheel joint, continuous collision and cross-platform determinism. Our own "arcade layer" sits on top |
| D3 | **Physics rate** | X-Moto 100 Hz fixed. Elma tied to frame rate. EOL2 500 Hz | **Fixed 120 Hz or 240 Hz**, integer-tick timing, and smoothing (interpolation) between physics steps when rendering |
| D4 | **Time scale and gravity** | Both run in slow motion with low felt gravity | Expose both as top-level settings. Set the targets from MSM2 measurements |
| D5 | **Rider weight** | Cosmetic in both | **Prototype two options:** (a) lean = torque on the frame (classic); (b) lean shifts the centre of mass on the ground, plus torque in the air. Pick whichever matches MSM's feel |
| D6 | **Rotation control** | X-Moto: torque bursts every 0.6 s. Elma: rotation bursts with a cooldown | **Continuous torque** with a cap on rotation speed, tuned separately for ground and air. Specify exactly what simultaneous inputs do |
| D7 | **Grip** | Effectively infinite in both | High but **finite friction**, with surface materials (dirt, mud, sand, wood, metal) as data. Specify the maximum climbable slope |
| D8 | **Collision and crash rules** | Wheels + head only; head = crash; the frame passes through ground | Wheels + head + **a frame shape** (it collides but doesn't kill). Head = crash. Over-rotated landings crash through the head rule naturally. Continuous collision on everything that moves fast |
| D9 | **Same-step events** | Both: death beats finishing | Adopt **"death beats finish"**. Ties broken by tick count, then by submission order |
| D10 | **Replays and ghosts** | Recorded positions, can't be verified | **Input log per tick plus a state checksum every N ticks.** Physics version and level hash stamped on every run. Ghosts rendered with cubic interpolation. The server re-simulates leaderboard runs |
| D11 | **Retry loop** | Instant restart with one key, intro skipped | **Hard target: under 100 ms from pressing restart to controlling the bike.** Short crash ragdoll that never blocks a restart |
| D12 | **Scoring** | X-Moto: medals relative to the world record. Elma: hundredths, truncated | Fixed **gold/silver/bronze target times per track**, plus global and friends leaderboards. Show hundredths, store ticks |
| D13 | **Camera** | Locked to the bike with smoothed look-ahead. X-Moto adds speed-based zoom with two thresholds. Elma has no vertical smoothing | Look-ahead in the direction of travel, speed-based zoom with two thresholds, gentle vertical smoothing, all scaled by frame time |
| D14 | **Level format** | Polygons with per-edge materials, decoration layers, a validator, a hash as the ID | The same concepts in our own (e.g. JSON) format. Convex pieces precomputed. The level hash binds records to the level |
| D15 | **Track editor** | MSM1 had a desktop editor reviewers praised. X-Moto needs an Inkscape plugin, a known barrier | **Built-in editor** (or a browser one), planned in from v1 even if it ships later |
| D16 | **Audio** | Elma drives sound from the physics | Engine pitch from wheel spin, landing thump from impact speed, suspension sound from spring work |
| D17 | **Boost / rockets** | MSM1 power-ups. MSM2 rockets, earned or bought | **(you)** Include a boost or not. If it's monetised, keep it out of ranked leaderboards to avoid pay-to-win |
| D18 | **Visual style** | MSM1/2: 2D cartoon. MSM3: 3D. X-Moto/Elma: 2D | **(you)** The physics stays 2D either way. Suggest 2D first, for readability and cost |
| D19 | **Platforms and game engine** | MSM2: mobile in Unity, web rebuilt in Defold with the C++ physics kept as a native extension | **(you)** Keep the physics core engine-independent (Box2D in C) so the same simulation runs on mobile, web, desktop and the server |
| D20 | **Business model and live content** | MSM2: free with light purchases and weekly JAM tracks. MSM3: heavier monetisation | **(you)** Premium vs free-to-play. Weekly tracks need a steady content pipeline, which depends on D15 |

## Feel targets: what to fill in from the play-tests

These become the spec's "feel" section, using test numbers from [05](05-playtest-protocol.md):

- **Air time and felt gravity** on a standard jump (tests 1)
- **Air rotation:** seconds per 360°, whether it speeds up, whether it keeps spinning after release (2–3)
- **Wheelie and stoppie** hold window (4)
- **Speed:** time from standstill to top speed, top speed in bike-lengths/s, stopping distance (5–6)
- **Landing:** which angles you survive, and the speed kept on a good landing (7)
- **Retry loop** latency (9) and **camera** zoom range (11)

## Suggested next steps (still no code)

1. **Team:** run the play-test protocol on MSM2 (Poki or phone) and MSM3, and fill in the sheet.
2. **You:** decide D17–D20.
3. **Then:** write **Spec v0.1**:
   - game design: pillars, controls, rules, modes, progression, track design guide;
   - technical design: physics model, determinism, replay format, level format, editor;
   - feel targets.
4. **After the spec is approved:** a plan for a small physics prototype to settle D5 and D6. That's the first point where code would be written.
