# 03: Elasto Mania / Action SuperCross study

Elasto Mania (2000) and its predecessor Action SuperCross ("Across") are the ancestors of the 2D bike-physics genre. Their creators published the source on GitHub: `elastomania/elma-classic`, `elastomania/across`, and `Smibu/eol2`, an archived fan successor whose physics is derived from Elma.

## Licence: read first

The licence was checked word for word against `elma-classic/LICENSE.md` and `across/LICENSE.md`.

- Licence 2 opens with this preamble: *"it is explicitly forbidden to use this source code, **or any algorithms and mathematical formulas present in this source code** for: any commercial purpose; any purpose resulting in financial loss or negative impact for any party; … degraded gameplay …; … competitive gameplay advantage …"*.
- After the preamble comes **CC BY-NC-SA 4.0**: attribution, non-commercial use only, and anything derived must use the same licence.
- Licence 1 keeps every right for the Elasto Mania Team.
- The README says the code was published "for the purpose of exploring the original source code". Assets aren't included. Any other use requires contacting info@elastomania.com.
- Across has the same preamble and CC licence.
- Outside its physics folder, EOL2 has **no licence at all**, which means all rights reserved.

**What this means for us.** We're probably building a commercial game. We must not use Elma's code, **or its specific algorithms, formulas or constants**. Whether a ban on using *algorithms* can be enforced is a question for a lawyer, but we won't test it.

So this document deliberately records only three kinds of thing:

1. behaviour anyone can observe by playing Elma;
2. general concepts found in every 2D bike game and in physics textbooks;
3. lessons about pitfalls and process.

The detailed study notes (constants, formulas, how inputs are processed) are **intentionally not committed**. Whoever implements our physics should work from our spec, Box2D and textbooks, not from this source.

## Observable behaviour and general architecture

- **The world runs in slow motion.** Game time runs at roughly 0.44× real time, so gravity feels low compared with the size of the bike. X-Moto does the same thing at 0.6× ([02](02-xmoto-study.md)). **Both genre ancestors trade realism for long air time**, which gives the player time to control rotation in the air. This is a deliberate genre convention that our spec has to set explicitly.
- **Bike structure:**
  - A frame plus two wheels on springy suspension, which also flexes slightly sideways. That flex is the "elasto" in the name.
  - Only the wheels and the head touch terrain.
  - The rider is cosmetic: their mass lags behind for the look and for the head position, but never pushes on the bike.
- **Grip is effectively infinite:**
  - wheels roll without ever sliding;
  - control is very precise and the bike can climb very steep slopes;
  - but a wheel wedged in a V-shaped gap can stop dead.
- **No bounce from collisions.** All bounciness comes from the suspension.
- **Rotation comes in discrete bursts ("volts")** with a cooldown, and auto-repeats while the key is held.
- **Turning around is instant in the physics.** It's dressed up with a short flip animation and a camera pan.
- **Sound is driven by the physics:**
  - engine pitch follows wheel spin;
  - suspension squeak follows how hard the springs are working;
  - the landing thump follows impact speed.

  This is cheap and very readable. We'll adopt the *idea*.

## Rules

- **Head contact with the ground kills.** "Killer" objects kill on contact with a wheel or the head.
- **The flower finishes the level only after every apple** has been collected. Apples can be taken in any order, and some apples change the direction of gravity.
- **Within one step, killers are checked before the flower, so death beats finishing.** X-Moto has the same rule.
- **Finish time** is shown in hundredths of a second and is truncated, not rounded.
- **In two-player modes bikes never collide.** There's a split-screen "flag tag" mode.

## Level format: concepts

- **Terrain:**
  - Closed polygons; whether a point is ground or air is decided by counting overlaps (odd = air).
  - Separate "grass" polygons are decorative and don't collide.
  - Pictures are placed with a depth value and clipped to either sky or ground.
- **A validator rejects broken levels:** self-intersecting edges, a start point inside ground, too many vertices.
- **A checksum of the level geometry** identifies the level, and records are tied to it.
- **Hard limits:** 300 polygons, 52 objects, about 188 units across. The fan successor removed them.

## Replays and determinism: the most important lessons

- **Replays store sampled positions,** about 30 per second, plus a list of timed events.
  - Playback interpolates between samples and doesn't run the physics.
  - Tamper protection relies on obfuscation (hidden bits, XOR-encrypted tables), which is weak.
- **Classic Elma isn't deterministic.** The physics step length and input sampling are tied to the rendering frame rate, so the same inputs can give different results on different machines.
- **The fan successor EOL2 had to fix this after the fact.**
  - It forced a constant 500 Hz physics rate and added tests requiring byte-identical replays.
  - It still needed **separate reference files for x86 and x64 CPUs**, because floating-point results differed between architectures.
  - **Lesson: build in determinism from day one.** Box2D v3's cross-platform determinism exists to solve exactly this ([04](04-box2d-notes.md)).
- **EOL2 never got to online play.** Time submission, replay verification and anti-cheat don't exist in its archive.

## Lessons

- **Emergent exploits become part of the culture.**
  - Pressing both rotation keys at the same moment produces a lasting spin. Players named it the "alovolt" and adopted it as a technique, and EOL2 even gave it its own key.
  - Lesson: **specify what happens with simultaneous inputs.** Emergent tricks can become loved features, but that should be a deliberate choice.
- **Physics gets locked in to protect records.**
  - Elma's source admits that known physics "mistakes" were kept so the bike would "behave the same as before".
  - Lesson: **version the physics from day one.** Bind every record and replay to a physics version and a level hash.
- **What changed from Across to Elma, and made the feel better:**
  - The rider and head became a lagging spring-mass instead of a rigid part, which looks much more alive.
  - Penetration tolerance got tighter, and contacts are handled more cleverly.
  - The physics step length was chosen specifically to avoid suspension resonance.
  - The core numbers (throttle, rotation, gravity, time scale) didn't change. **The feel came from polish, not from retuning the basics.**
- **Camera:**
  - The bike sits about 15% in from the trailing edge of the screen, leaving about 70% of the width ahead.
  - Turning around pans the camera across.
  - There's **no vertical smoothing** and a fixed scale.
  - EOL2 later added free zoom and a centred-camera option.
- **No protection against fast-moving wheels passing through thin terrain.** This is a known weakness of the genre; Box2D's continuous collision detection addresses it.
