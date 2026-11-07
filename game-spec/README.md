# Motocross game: spec and plan (pre-production)

**Phase:** research → specification. **No game code is written in this phase.**

We're planning an original, side-scrolling motocross physics racer in the genre of Mad Skills Motocross (MSM), Elasto Mania and X-Moto. This folder holds the research behind the spec, and later the spec itself.

## Ground rules (clean room)

1. **Study by playing, not by decompiling.** We observe, play, record and measure commercial games (MSM2, MSM3, the MSM2 web version on Poki) from legitimately obtained copies. We don't decompile, unpack or extract code or assets from them, and we don't download APKs from mirror sites.
2. **Read open source for ideas, then write our own.** X-Moto (GPL-2.0+) and the published Elasto Mania / Action SuperCross source can be read to understand mechanisms. No code, data or assets get copied from them into our project. Their licences forbid it (Elma/Across) or would make our game GPL (X-Moto).
3. **Box2D (MIT) is a candidate dependency.** Using it as a library is fine.
4. **The game is original.** No reuse of MSM's name, characters, art, tracks, UI look or audio. We match how the game *feels* (behaviour), not how it looks or how it's coded.

## Research index

| # | Document | What it covers |
|---|---|---|
| 01 | [Version survey](research/01-version-survey.md) | Every MSM release, platforms, package IDs, what's verified and what isn't |
| 02 | [X-Moto study](research/02-xmoto-study.md) | Hands-on play notes plus a source-level study of the physics, levels, replays and editor |
| 03 | [Elasto Mania study](research/03-elasto-mania-study.md) | Physics model, replays and determinism from the published Elma/Across source |
| 04 | [Box2D notes](research/04-box2d-notes.md) | What an off-the-shelf engine gives us: wheel joints, determinism, recording |
| 05 | [Play-test protocol](research/05-playtest-protocol.md) | How the team measures MSM2/MSM3 "feel" on their own devices |
| 06 | [Findings and spec inputs](research/06-findings-and-spec-inputs.md) | Synthesis: decisions the spec needs to make, with recommendations |

_Status: 01, 04 and 05 are written. 02, 03 and 06 are in progress while the source studies finish._
