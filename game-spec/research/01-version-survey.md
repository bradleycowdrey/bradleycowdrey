# 01: Mad Skills Motocross version survey

Researched 2026-11-07. Unconfirmed claims are marked as such. Some sources (gamedev.net, racerxonline.com, jayisgames) couldn't be opened from the research sandbox. Details from those come from search summaries.

## Releases

| Title | Released | Platforms | Availability now | Technical notes |
|---|---|---|---|---|
| **Mad Skills Motocross (MSM1)** | PC demo Aug 2009; iOS Jan 2011; free iOS "Lite" May 2011 | Windows, Mac, **Linux**, iOS. Android **not confirmed** | No current store found. Mac version was US$25.95 | 2D. 52 tracks and challenges, 5 divisions, 5 power-ups (including nitro, turbo and jump boosts). Desktop-only track editor |
| **Mad Skills Motocross 2 (MSM2)** | Feb 2014 | iOS (`id695531774`), Android (`com.turborilla.MadSkillsMotocross2`) | App Store / Play Store, free with IAP and ads | Unity client with Turborilla's own C++ physics engine. Rockets (career speed boost, earned daily or bought in packs), weekly JAM, async Versus with time windows |
| **MSM2 web (Poki)** | Apr 2025 (updated Oct 2025) | Browser | Free on Poki | Rebuilt from scratch in the Defold engine by Refold Games. The C++ physics engine was carried over unchanged as a native extension. Track, rider, shadows and scenery are dynamic meshes, not sprites. Fewer modes than mobile |
| **Mad Skills Motocross 3 (MSM3)** | 25 May 2021 | iOS (`id1508275130`), Android | Stores, free with IAP | Moved from 2D to 3D and rebuilt the physics (per lead designer Joe Welch). First in the series with **whips**. Track builder **not confirmed** (only a third-party emulator page claims it). Engine not confirmed |
| **MSM: Chasing the Dream** | Announced Feb 2024 | PC (Steam app 2820080) | Release listed "TBA" when checked | Made with LCQ Studios. First with turning, so it's a different genre from a side-scroller |
| Sibling games | 2017 / 2022 | Mobile | Stores | Mad Skills BMX 2 (test launch Dec 2017), Mad Skills Snocross (Nov 2022) |

Turborilla is based in Umeå, Sweden, with an office in Skellefteå. It reports 200M+ downloads across all its games, BMX included.

## Corrections to the brief we started from

- **MSM1 "rocket boots":** not confirmed. Reviews describe turbo/nitro and jump boosts. Rockets are an MSM2 career-mode feature.
- **MSM1 on Android (2012):** not confirmed.
- **MSM3 track builder:** not confirmed.
- **"100M+ installs":** Turborilla's figure is 200M+ across all its games, not MSM alone.
- **Licensed gear in MSM3 (FOX, FXR, Thor):** not checked.

## Which versions we can study, and how

| Target | How we study it |
|---|---|
| MSM2 mobile, MSM3 | Play on our own devices and screen-record. See [05 play-test protocol](05-playtest-protocol.md) |
| MSM2 web (Poki) | Play in a desktop browser and screen-record. It runs Turborilla's real physics, so it's the easiest to measure. (poki.com was blocked in the research sandbox) |
| MSM1 (only Linux build) | Discontinued, no legitimate source. Skip |
| X-Moto (Linux, GPL) | Read the source and play. See [02](02-xmoto-study.md) |
| Elasto Mania / Across (published source) | Read only. See [03](03-elasto-mania-study.md) |

Not done, on purpose: decompiling APKs or desktop binaries, or pulling APKs from mirror sites.

**Legal basis (not legal advice):** under EU Software Directive Art. 5(3), a lawful user may observe, study and test a running program to find its underlying ideas, and Art. 9(1) stops a licence from overriding that. Decompiling (Art. 6) is allowed only to make programs work together, which "inspiration" doesn't qualify for. The CJEU's *SAS Institute v World Programming* ruling (C-406/10, 2012) held that a program's functionality isn't protected by copyright.

## Sources

- [WorthPlaying: MSM demo, 2009](https://worthplaying.com/article/2009/8/25/news/64664-mad-skills-motocross-demo-available-now)
- [MacTech: MSM on Mac](https://www.mactech.com/2009/08/25/mad-skills-motocross-drives-onto-mac-os-x/amp/)
- [LinuxLinks: MSM](https://www.linuxlinks.com/madskillsmotocross/)
- [Macworld review](https://www.macworld.com/article/201173/msmreview.html)
- [GamersGate listing](https://uk.gamersgate.com/DD-MSM/mad-skills-motocross-pc)
- [Racer X: MSM Lite](https://racerxonline.com/2011/05/18/free-lite-version-of-mad-skills-motocross-released)
- [Racer X: MSM2 release](https://racerxonline.com/2014/02/20/mad-skills-motocross-2-mobile-game-released)
- [AppGoblin: MSM2](https://appgoblin.info/apps/com.turborilla.MadSkillsMotocross2)
- [App Store: MSM2](https://apps.apple.com/us/app/id695531774?l=en-us)
- [TouchArcade: MSM2](https://toucharcade.com/games/mad-skills-motocross-2)
- [Turborilla KB: Red Bull JAM](https://turborilla.happyfox.com/kb/article/120-what-is-the-red-bull-jam/)
- [Defold blog: MSM2 for Poki](https://defold.com/2026/06/02/Mad-Skills-Motocross-2/)
- [GameDev.net: MSM2 with Defold](https://gamedev.net/news/3728-building-mad-skills-motocross-2-for-poki-with-defold/)
- [Poki: MSM2](https://poki.com/jp/g/mad-skills-motocross-2)
- [Game Developer: MSM3 launch](https://www.gamedeveloper.com/press-release/mad-skills-motocross-3-mobile-game-released-globally-today)
- [MotoOnline: Joe Welch interview](https://www.motoonline.com/au/industry-mad-skills-motocross-3s-joe-welch/)
- [App Store: MSM3](https://apps.apple.com/US/app/id1508275130)
- [Steam: Chasing the Dream](https://store.steampowered.com/app/2820080)
- [Turborilla: who we are](https://www.turborilla.com/who-we-are)
- [Racer X: Snocross](https://racerxonline.com/2022/11/09/turborilla-producers-of-mad-skills-motocross-releases-mad-skills-snocross-game)
- [TouchArcade: BMX 2](https://toucharcade.com/2017/12/11/mad-skills-bmx-2-soft-launch/)
- [EU Software Directive Art. 6](https://www.legislation.gov.uk/eudr/2009/24/article/6)
- [Fieldfisher: SAS v WPL](https://www.fieldfisher.com/en/insights/sas-institute-inc-v-world-programming-limited)
