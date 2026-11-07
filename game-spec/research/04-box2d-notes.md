# 04: Box2D notes (candidate physics engine)

Read from `erincatto/box2d` (main branch, commit `dd8bd3f`, 29 Oct 2026). MIT licence, so it's usable as a dependency.

## Why it matters

Turborilla wrote its own C++ physics engine for MSM. A small team doesn't have to. Box2D already includes the building blocks a 2D bike needs, plus two features that make leaderboards and ghosts much cheaper to build.

## Relevant features

| Feature | What it gives us | Where it's documented |
|---|---|---|
| **Wheel joint** | Each wheel slides along a suspension axis on the chassis, with a spring (stiffness in Hz plus a damping ratio), travel limits, and a rotational motor (target speed plus max torque). That's a complete motorbike wheel: spring + damper + drive in one joint | `include/box2d/types.h` (`b2WheelJointDef`) |
| **Car sample** | A worked vehicle: chassis polygon plus two circle wheels, wheel friction 1.5 vs chassis 0.2, rolling resistance on the wheels, suspension travel ±0.25 × scale. The commented defaults suggest motor speed ~35 rad/s, spring 5 Hz, damping 0.7, torque 2.5 × scale | `samples/car.cpp` |
| **Material options** | Friction, restitution, rolling resistance and tangent speed per shape. Good for mud, sand or ice surfaces as data | `include/box2d/types.h` |
| **Cross-platform determinism** (since v3.1) | Same inputs give the same simulation on every 64-bit platform and thread count. It's tested on every pull request. Needs the same Box2D source and compiler flags on every build (no fast-math; FP contraction off) | `docs/simulation.md` §Determinism, `docs/questions.md` |
| **Snapshots** | Save and restore world state, which supports rollback, instant restart and checkpoints | `docs/questions.md` → snapshot |
| **Recording/replay** | Records a world snapshot plus every world-changing call, then replays it exactly. Built mainly as a debugging tool (bug repro files), and it needs an identical build | `docs/recording.md` |
| Character movers | Not relevant to a bike | `docs/character.md` |

## Implications for the spec

1. **Ghosts and replays can store inputs only:** throttle, brake and lean per fixed physics step. Replaying them through the same deterministic simulation reproduces the run. That keeps files tiny. X-Moto and Elma both took other approaches; see 02/03.
2. **Server-verified leaderboards become possible.** A submitted time can come with its input log, and a server running the same build re-simulates it to check. That's strong protection against cheating.
3. **Fixed timestep is required.** The spec has to set a physics rate (for example 120 Hz or 240 Hz) that doesn't depend on rendering frame rate.
4. **Versioning rule:** any physics change invalidates old ghosts and replays. Leaderboards need a physics version per entry, and seasons or weekly events should reset on physics updates.
5. **What Box2D doesn't give us:** the "arcade" layer. That means rider lean (torque or mass shift), air rotation control, landing grading, crash rules, boost, and how the camera feels. These are our design decisions and the core of the spec.
