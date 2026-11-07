# 02: X-Moto study (play + source)

X-Moto is an open-source 2D motocross physics game. The licence is GPL-2.0+, so we describe its mechanisms in prose and copy no code. Sources:

- **Played:** v0.6.2 from Ubuntu 24.04, run in a virtual 1280×720 display with scripted keyboard input. Three recorded runs on the levels "Basics" (`tut1`), "Jumping" (`tut2`) and "Free Fall" (`_iL22_`).
- **Read:** the source at `github.com/xmoto/xmoto` commit `539984a`. File:line references below are relative to that repo. Key constants were spot-checked against `bin/Physics/original.xml`.

## A. What playing it showed

- **Controls:** Up = throttle, Down = brake, Left/Right = rotate (lean back/forward), Space = change direction.
- **HUD:**
  - timer `MM:SS:cc` top-left, with your best and the world record underneath;
  - a minimap bottom-left;
  - tutorial text overlays and "THIS WAY" signs in the level.
- **Lean is very strong.** A 0.6 s lean back at speed on flat ground flipped the bike over backwards, and the head hit the ground. Dead.
- **The crash is a spectacle.**
  - The bike comes apart: wheels detach and the rider goes limp like a ragdoll.
  - The camera zooms out and the screen dims, with "Press ENTER to try again / ESC for menu".
  - A few seconds later an "Oops!" menu appears: try again, view replay, save replay, quit level, quit game.
- **Retry is instant.** Enter restarts at any time, even mid-crash, and the level intro is skipped on a restart.
- **Every run is recorded.** "View the replay" is offered straight after a crash.
- **The levels are puzzles, not races.**
  - You collect every strawberry, then touch the flower to finish.
  - Some levels require driving the "wrong" way first: "Jumping" makes you go left before the jump.
  - This is the biggest structural difference from MSM, which is linear left-to-right racing. **Use X-Moto as a physics reference, not a level-design reference.**
- **Limits of this play-test:** software rendering, bot inputs rather than skilled play, and no online levels (the server was unreachable). Feel numbers for our targets have to come from the team's play-tests ([05](05-playtest-protocol.md)).

## B. How it works (source study)

### Physics architecture

- **Two physics engines.**
  - **ODE** simulates the bike and rider, one world per player (`src/xmscene/BikePlayer.cpp:163-179`).
  - **Chipmunk** simulates only movable "physics blocks" in levels.
  - The coupling is one-way: the bike pushes blocks, and blocks act as moving terrain for the bike, but blocks never push back.
- **Fixed 100 Hz tick.** Game time is an integer count of hundredths of a second (`src/xmscene/Scene.h:36`). At most 10 catch-up steps run before the clock resyncs. Rendering is capped at 50 fps with **no interpolation**.
- **Slow-motion clock: the hidden "feel" knob.** Each 0.01 s tick advances the simulation only 0.006 s (`simulation_speed_factor` 0.6).
  - So gravity of 9.81 feels like about **3.5 m/s²** in real time.
  - That explains X-Moto's floaty, moon-like jumps.
  - One parameter rescales the feel of the whole game.
- **The bike body.**
  - A 90 kg frame plus two 10 kg wheels of radius 0.35 m, with a wheelbase of 1.4 m.
  - **There are no joints.** Each wheel is held to its rest point by a 2D spring-damper force (k = 21000 N/m), so it isn't a slider fork.
- **The rider is a puppet.**
  - Two mirrored ragdolls (facing left and facing right) are both simulated all the time. They are pulled toward fixed poses by springs that **don't push back on the bike**.
  - Rider weight never loads the bike, and there is **no weight-shift physics**.
  - The ragdoll exists for animation and for the head position used in death checks.
- **Throttle:** a constant 560 N·m torque on the driven wheel, cut above 60 rad/s.
  - Derived top speed is about 12.6 m/s (45 km/h) in real time.
  - Facing left drives the front wheel instead; the frame never actually turns around.
- **Brake:** viscous (torque ∝ −wheel spin), not a wheel lock. Rolling resistance is always on.
- **Lean is a decaying torque pulse.**
  - A press gives the frame a 10000 N·m torque that decays ×0.75 per tick, lasting about 17 ticks.
  - Holding the key re-fires the pulse every **0.6 s**; reversing direction bypasses that wait.
  - It works the same on the ground and in the air, which gives a rhythmic, "kicky" control feel.
- **Change direction** just flips a flag (no impulse), blended visually over about 0.33 s.
- **Grip:** wheel friction μ = 20, effectively no slip. Ice is made by setting per-block grip to 0–1.
- **Collision:** only the two wheel circles and the head touch the ground while alive.
  - The frame passes through terrain, so a spike between the wheels does nothing.
  - Terrain edges are one-sided.
  - Wheels have **no tunnelling protection**; only the head is swept.

### Key constants

| Constant | Value | Notes |
|---|---|---|
| Physics tick | 100 Hz (1/100 s) | Integer tick time is used for scoring |
| simulation_speed_factor | 0.6 | Felt gravity ≈ 9.81 × 0.36 ≈ 3.5 m/s² |
| Gravity | 9.81 m/s² (sim) | |
| Frame / wheel mass | 90 / 10 kg | Rider parts 5 kg each, but no feedback to the bike |
| Wheel radius / wheelbase | 0.35 / 1.4 m | Frame centre 0.9 m above ground point |
| Suspension spring / damp | 21000 N/m / 205000 per tick-delta (≈1230 N·s/m) | Damping is defined per tick, so it depends on dt |
| Engine torque | 1400 × 0.4 = 560 N·m | Cut above 60 rad/s wheel spin |
| Brake | 80 × ω | Viscous |
| Lean torque / decay | 10000 N·m / ×0.75 per tick | Repeats every 0.6 s |
| Wheel grip μ | 20 | Effectively no slip |
| Head radius / neck | 0.18 / 0.22 m | Only the head kills on terrain |
| Wheel detach on death | > 40 km/h | Gives the crash its spectacle |

### Death and finish rules

- **Only the head kills on terrain.** It is a circle placed past the shoulder and swept every tick.
- **Wrecker** entities kill.
- **Finishing:** touching the end flower wins only once every strawberry has been collected.
- **Death beats a win in the same tick.**
- **Checkpoints** set a respawn point. Using one invalidates the run's highscore replay.

### Level format

- **XML `.lvl` files.**
  - **Blocks** are polygons (vertex list plus a texture), with per-edge materials such as "Grass".
  - Block flags: background, dynamic (moved by script), physics (Chipmunk) and parallax layer.
  - Each block has its own grip, mass, friction and elasticity.
- **Entities** are circles: PlayerStart, EndOfLevel, Strawberry, Wrecker, Checkpoint, ParticleSource, Sprite, plus pin Joints between physics blocks.
- **Zones** are rectangles that trigger scripts.
- **Lua scripting:** OnLoad, a Tick at 100 Hz, Touch, and zone enter/leave. About 65 `Game.*` functions, including SetGravity, moving blocks, adding penalty time, and camera zoom/rotate.
- **Shipped corpus:** 307 levels, around 21k blocks and 510k vertices.
- **Terrain rendering:**
  - Concave polygons are split into convex pieces for the textured fill.
  - Edges are drawn as textured strips. The "angle" mode extrudes in a fixed world direction, so grass drapes downward on any slope; other modes extrude perpendicular to the edge.

### Replays and ghosts

- **Replays store state snapshots, not inputs.**
  - 25 frames per second, about 40 bytes each: frame position as floats, joint positions as 8-bit offsets, and 16-bit rotations.
  - Plus timestamped events and moving-block tracks, all zlib-compressed.
- **No determinism is needed.** Replays survive physics changes, but **they can't be verified** by re-simulating them.
- **Ghost playback** uses 4-sample cubic interpolation. Gaps over 3 s or jumps over 5 m are treated as teleports.
  - Ghosts have no physics, plus optional motion blur and a trail line.
  - The default ghosts are "my best" and "room best".
- **Split times** against the ghost are taken at each strawberry pickup: free checkpoints.
- **Online upload** posts the replay file with the login and password. The server-side checks aren't in the repo.
  - The network multiplayer server is authoritative at 100 Hz, and clients send their inputs.

### Camera

- **Locked to the frame centre** with no lag.
  - Only a look-ahead offset is smoothed: 1.7 m toward the facing direction, easing 0.5% of the gap per update. The easing isn't scaled by frame time.
- **Zoom:** about 8.3 m of visible half-height by default.
  - Auto-zoom eases out after 1 s above 24 km/h and back in after 1 s below 15 km/h. Using two thresholds (hysteresis) stops it flickering.
- **Death camera** follows the ragdoll.
- **Level start** plays a zoom-out preview, skipped on a restart.

### Editor, structure and progression

- **No in-game editor.**
  - Creators draw SVG paths in **Inkscape**, using the external "Inksmoto" plugin, and export `.lvl`.
  - The old `xmoto-edit` is deprecated. This dependency is a known barrier for creators.
- **All levels are open; there are no unlocks.** About 35 automatic "virtual packs": not completed, no highscore, by length, hardest, by author, medals, and so on.
- **Medals relative to the world record:** platinum = hold the WR; gold ≤ WR/0.95; silver ≤ WR/0.90; bronze ≤ WR/0.80 (`src/xmoto/Game.cpp:274-276`).
- **Modes:** single-player time attack, local split-screen (time attack, race, team), and an online server with Lua rules.
- **Practice:** Trainer mode saves and restores positions and disables highscores. Backspace returns to the last checkpoint.

## C. What to take into our spec

| Take (as an idea) | Avoid / improve |
|---|---|
| Fixed-step simulation with integer tick time for scoring; catch-up cap | **Add render interpolation**: X-Moto doesn't have it |
| Frame + 2 wheels + spring-damper suspension | **Velocity-based damping**, so tuning doesn't depend on tick rate |
| **Time scale and gravity as top-level feel knobs** | The rider as a feedback-free puppet. MSM-style riding probably needs **weight shift** |
| Head-only death plus "death beats win" | Wheel tunnelling: use continuous collision (Box2D has it) |
| Instant restart with one key, intro skipped | Lean pulses on a 0.6 s timer: prefer continuous torque with an angular-speed cap, separate for ground and air, unless playtests prefer the "kick" |
| Ghosts with cubic interpolation, teleport guards and split times | Unverifiable snapshot replays: we want **input logs** on a deterministic sim ([04](04-box2d-notes.md)) |
| Medal tiers as a % of the best time (plus fixed "author times" offline) | An editor only available as a plugin to a third-party drawing app: plan an **in-game or browser editor** |
| Per-block grip and materials; draped edge rendering; parallax | Mandatory puzzle-style collectibles. Our core is linear racing |
| Speed-based camera zoom with hysteresis | Camera smoothing that isn't scaled by frame time |
