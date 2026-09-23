# COD Audio EQ Audit + V3 Build

Date: 2026-09-23
Scope: PS5 → Elgato 4K X capture endpoint → Windows "Listen to this device" → HyperX Cloud III (USB)

## A note on what this audit actually is

This session runs in an isolated cloud container, not on your Windows laptop. It cannot
read `C:\Program Files\EqualizerAPO\config\config.txt`, cannot read your live
`C:\Users\isaac\Documents\Codex\cod-eq-v1.ps1` / `v2.ps1` / `off.ps1`, and cannot query
Windows to see which profile is currently active or confirm the Elgato endpoint scoping
in the registry.

Everything below is built from the exact filter values you pasted (treated as ground
truth for v1/v2), reasoning about the pipeline you described, and current research. It is
not a live inspection. Two one-line checks you can run locally to close that gap are at
the bottom of this doc.

## 1. What v1, v2, and off are actually doing

All three share the same shape: a high-pass at 35 Hz, a cut around 90 Hz and 180 Hz, and
rising presence boosts from 850 Hz through 8.2 kHz, with a small cut at the very top.

| Filter | v1 (daily) | v2 (competitive) | Purpose |
|---|---|---|---|
| Preamp | -4.5 dB | -5.5 dB | Headroom so the boosts below don't clip |
| HPQ 35 Hz | on, Q 0.70 | on, Q 0.70 | Removes sub-bass rumble below anything gameplay-relevant |
| PK 90 Hz | -2.5 dB | -3.5 dB | Tames PS5/explosion low-end boom that masks everything above it |
| PK 180 Hz | -1.5 dB | -2.0 dB | Further declutters low-mid mud (footstep body lives higher than this) |
| PK 850 Hz | +1.0 dB | +1.5 dB | Footstep "thud" / impact definition |
| PK 1800 Hz | +1.8 dB | +2.2 dB | Directional presence, general clarity |
| PK 3200 Hz | +2.2 dB | +3.0 dB | Footstep grit / cloth texture - the main "footstep EQ" band |
| PK 5200 Hz | +1.4 dB | +1.8 dB | Air, distance cues, upper texture |
| PK 8200 Hz | -1.0 dB | -1.0 dB | Cuts sibilance/hiss at the very top |

v2 is not a different design, it's v1's exact same 8 filters pushed 0.5-1.0 dB harder in
every direction, with 1 dB more preamp headroom to match. That's a legitimate way to scale
a proven curve, but it also means whatever v1 was *missing*, v2 is missing too, just
louder.

**off** is presumably flat/bypassed (preamp 0 dB, filters disabled) - I've written it that
way in `configs/equalizer-apo/cod-eq-off.txt` since you didn't paste its actual values.
Confirm this matches your real `cod-eq-off.ps1`.

## 2. Is Equalizer APO correctly scoped?

Based on your description - APO installed and pointed only at the Elgato 4K X recording
endpoint, with Discord/Chrome/Spotify/HyperX mic all confirmed untouched - yes, this is
architecturally correct. I can't verify it live from here; see the verification commands
at the bottom.

One thing worth double-checking locally: Equalizer APO can store its config either as a
single `config.txt` (if it was installed scoped to exactly one device) or as
per-device folders under `config\<endpoint-GUID>\config.txt` (if it was installed against
multiple devices and routes by GUID). The v1/v2/v3/off scripts in this repo check for the
per-device path first and fall back to the root file, so this ambiguity shouldn't matter,
but if you ever add a script by hand, check which layout you actually have.

## 3. Is Equalizer APO still the best tool for this job?

Yes - confidently. Here's the comparison against the realistic alternatives, judged
against your actual constraints (near-zero latency, per-endpoint isolation, no pipeline
redesign):

| Option | Latency | Can target Elgato endpoint only | Risk to Discord/Windows audio | Verdict |
|---|---|---|---|---|
| **Equalizer APO** | Sub-millisecond, operates directly in the endpoint's audio graph | Yes - this is exactly what you have now | None, by design | **Keep** |
| SteelSeries Sonar | Low, but adds its own virtual audio device layer (Game/Chat/Media/Aux) | Poor fit. Your PS5 audio arrives via a "Listen to this device" loopback, not a normal per-app WASAPI session. Sonar's app-based routing model isn't built to isolate a loopback stream the way it isolates a game .exe | High - would require restructuring your whole playback device setup | Reject: solves a problem you don't have (per-app mixing) by adding the exact pipeline redesign you asked to avoid |
| FXSound | Low-moderate | No native per-endpoint scoping; it's a system-wide enhancement | High - bleeds into other apps unless carefully managed | Reject: less control than APO for the same or worse risk |
| Sonarworks / SoundID | Moderate (real-time correction engine, more overhead than a static IIR chain) | Not designed for capture-endpoint EQ; it's a playback correction tool for content creation | Low risk to other audio, but wrong tool | Reject: solves headphone calibration, not competitive tuning |
| Peace GUI | N/A | N/A | N/A | Not a competitor - Peace is just a GUI *for* Equalizer APO. If you want a visual editor for building v3 by ear later, install Peace on top of your existing APO; it edits the same config.txt this script writes |
| VST host (e.g. a DAW loopback chain) | Adds a real audio engine, buffers, and a process that has to stay running | Possible but requires a virtual cable to get PS5 audio into the host at all | High - new failure point, new routing, new process to crash | Reject: exactly the "software conflicts / routing problems" you said to avoid |

Equalizer APO wins because it is the only option here that is a thin filter sitting
directly on the one endpoint you already isolated, with no separate engine, no extra
process, and no virtual device restructuring. Nothing else on this list produces a
*measurable* competitive advantage over it for your setup - they mostly solve different
problems (per-app mixing, studio calibration) that you don't have.

## 4. Weaknesses in the current tuning

Your reported symptom - can hear general game audio fine, but wall jumps, reloads,
mantles, close directional detail, and small movement texture aren't coming through - maps
onto a real gap in v1/v2's design, not a flaw in the "push it harder" idea:

- **Every boost band in v1/v2 sits at 850 Hz, 1800 Hz, 3200 Hz, or 5200 Hz.** There's a gap
  between 180 Hz and 850 Hz with no shaping at all, and between 1800 Hz and 3200 Hz.
  Reload mechanical clicks and mantle hand-contact/scrape sounds have a lot of their
  identifying detail in the 2.5-3 kHz range specifically - narrower and more surgical than
  the broad 3200 Hz band gives them.
- **The 90 Hz / 180 Hz cuts remove some of the low-end "thump" that mantles, wall jumps,
  and landings actually use for their impact cue.** v2 cuts these harder than v1, which
  plausibly made mantle/wall-jump audio *less* present, not more, even though gunfights
  probably felt cleaner.
- **The 8200 Hz cut compounds a real weakness in your headset**, not a weakness in the
  game mix (see headset research below) - it's quietly removing exactly the frequency
  range that carries glass, ladder/climbing metal, and distant-footstep "air" detail.

## 5. Current game and headset research

**Game (Black Ops 7, live as of Sept 2026):**
- Competitive guides for BO7 consistently flag three levers before EQ ever comes into it:
  Effects Volume near 100, Enhanced Headphone Mode (binaural/HRTF processing, improves
  directional separation), and - PS5-specific - **Audio Focus with "Boost High Pitch"**
  under console Accessibility settings, which several guides call out as making a real
  difference for headphone players and is the closest console equivalent to PC's Loudness
  Equalization (which isn't available on PS5).
- These are free, zero-latency, source-level levers that don't touch your pipeline at all.
  If you haven't already turned on Enhanced Headphone Mode and Audio Focus / Boost High
  Pitch in-game, do that before judging how much more EQ can realistically buy you - I'm
  flagging this rather than changing it, per your PS5-settings restriction.
- MW4 (beta, launching Oct 23, 2026) has been patching footstep audio *down* in volume
  based on beta feedback. That's the next title, not what you're tuning for now, but worth
  knowing your v3 profile may need revisiting when MW4 ships.

**Headset (HyperX Cloud III, wired/USB):** Independent measurements (RTINGS, SoundGuys)
describe it as neutral through the mids but **"somewhat dark"** overall, with measured dips
in both bass and treble - HyperX's own NGENUITY "Optimizer" preset exists specifically to
compensate for those dips. This matters directly for your v3 tuning: your headset is
already naturally soft in the 7-10+ kHz range where glass, climbing, and distant-footstep
detail live. v1/v2's -1.0 dB cut at 8200 Hz was reasonable general sibilance control on a
brighter headset, but on a headset that's already dark up there, it's cutting a signal that
was never excessive to begin with.

## 6. Confidence level

**How much improvement should you expect over v2:** Moderate, not dramatic. v2 already
captures most of what a broad "footstep EQ" curve can give you - it's a well-formed,
sensibly-scaled design. v3 targets a real, specific gap (narrow-band detail around 2.5-3.4
kHz, preserved low-end impact for mantles/wall-jumps, recovered top-end for
climbing/glass) rather than just adding more gain, so expect a genuine but incremental
gain in the specific cues you flagged as missing - not a transformation of your overall
awareness.

**Where the remaining limitation lives:** Increasingly, it's the game's own mix and your
headset's raw driver response, not your EQ or hardware chain. Once v3's structural gaps
are closed, further competitive gains come primarily from the in-game/console levers above
(Enhanced Headphone Mode's HRTF spatialization in particular - EQ shapes frequency balance,
it cannot recreate directional/positional cues) and, over time, from BO7's own audio
patches. If v3 still feels insufficient after a real test session, the next lever isn't a
stronger EQ - it's confirming Enhanced Headphone Mode and Audio Focus are on, since those
address positioning/verticality in a way no parametric EQ can.

## 7. V3 build

File: [`scripts/cod-eq-v3.ps1`](../scripts/cod-eq-v3.ps1) (config reference:
[`configs/equalizer-apo/cod-eq-v3.txt`](../configs/equalizer-apo/cod-eq-v3.txt))

```
Preamp: -6.0 dB

Filter 1:  ON HPQ Fc 35 Hz    Q 0.70
Filter 2:  ON PK  Fc 90 Hz    Gain -3.0 dB Q 0.80
Filter 3:  ON PK  Fc 150 Hz   Gain -1.0 dB Q 1.00
Filter 4:  ON PK  Fc 650 Hz   Gain  1.0 dB Q 1.00
Filter 5:  ON PK  Fc 850 Hz   Gain  1.3 dB Q 1.10
Filter 6:  ON PK  Fc 1800 Hz  Gain  2.0 dB Q 1.00
Filter 7:  ON PK  Fc 2700 Hz  Gain  2.5 dB Q 1.30
Filter 8:  ON PK  Fc 3400 Hz  Gain  3.0 dB Q 1.20
Filter 9:  ON PK  Fc 5200 Hz  Gain  2.0 dB Q 1.00
Filter 10: ON PK  Fc 7000 Hz  Gain  0.8 dB Q 1.10
Filter 11: ON PK  Fc 10000 Hz Gain -1.0 dB Q 0.70
```

### Why each filter exists

- **HPQ 35 Hz, Q 0.70** - unchanged from v1/v2. Removes inaudible sub-bass rumble; no
  reason to touch a filter that isn't causing your reported problem.
- **PK 90 Hz, -3.0 dB** - between v1 (-2.5) and v2 (-3.5). Still controls boom, but less
  aggressively than v2 so mantle/wall-jump/landing impact thump (which lives partly down
  here) isn't scooped out along with the boom.
- **PK 150 Hz, -1.0 dB** (moved down from 180 Hz, cut reduced from v1's -1.5/v2's -2.0) -
  same reasoning: preserve low-end impact character for movement cues instead of just
  decluttering for gunfight clarity.
- **PK 650 Hz, +1.0 dB** - new. Fills the gap between the low-end cuts and the 850 Hz
  band. This is where reload mechanical body and mantle/climb grunt/vocal cues sit; v1/v2
  had nothing here.
- **PK 850 Hz, +1.3 dB** - carried over from v1/v2's footstep-impact band, gain landed
  between the two.
- **PK 1800 Hz, +2.0 dB** - carried over, general directional presence, gain landed
  between v1/v2.
- **PK 2700 Hz, +2.5 dB, Q 1.30** - new, and the key addition for your stated complaint.
  Narrower Q than the neighboring bands so it's surgical rather than broad. This is the
  primary reload-click / mantle-hand-contact / wall-jump-texture band that didn't exist in
  v1 or v2 at all.
- **PK 3400 Hz, +3.0 dB** (moved up slightly from 3200 Hz, same peak gain as v2) - the
  core footstep-grit/cloth-texture band, unchanged in strength from v2 since that part of
  v1/v2's design was already working for you.
- **PK 5200 Hz, +2.0 dB** - carried over, air/distance/upper texture, gain landed between
  v1/v2.
- **PK 7000 Hz, +0.8 dB** - new, replaces the top of v1/v2's range. A mild *boost*, not a
  cut, specifically because your headset is already measured as dark here. This is where
  glass, ladders/climbing metal, and distant-footstep "air" detail live - the cues you
  flagged as weak.
- **PK 10000 Hz, -1.0 dB, Q 0.70** - new home for sibilance/hiss control, moved higher and
  widened (lower Q) so it catches harshness without undoing the 7 kHz recovery band right
  below it.
- **Preamp -6.0 dB** - slightly more negative than v2's -5.5 dB to keep headroom safe with
  the extra/relocated boost bands (peak overlap in the 2.5-3.5 kHz region is the worst
  case, and -6.0 dB preamp leaves roughly 1-2 dB of margin there, consistent with the
  margin v1/v2 already used).

### What changed from v1/v2 in one sentence each

- v1 → v3: v1 is the conservative baseline; v3 keeps its restraint on gunfire but adds
  three new bands (650 Hz, 2700 Hz, 7000 Hz) v1 never had, specifically for the cues you
  said you're missing.
- v2 → v3: v2 is v1 turned up uniformly; v3 is *reshaped*, not just louder - same peak
  gain in the core footstep band, but redistributed low-end preservation and new
  narrow-band coverage where v2 had gaps.

### When to use each profile

- **v1 (daily)** - casual play, pubs, when you want the game to sound natural and aren't
  actively grinding ranked/comp.
- **v2 (competitive, stronger)** - if you specifically want a louder, more aggressive
  version of the same broad footstep curve and don't mind slightly less low-end impact
  character.
- **v3 (competitive, refined)** - your new default for ranked/comp play. Same restraint on
  gunfire as v1/v2, closes the reload/mantle/wall-jump/climb/glass gap you reported.
- **off (bypass)** - reference point for A/B testing, or if you suspect the EQ itself is
  causing an issue and need to rule it out fast.

### How to A/B test in a private match

1. Set up a private lobby (bot match or custom game) on a map with varied movement -
   something with ladders, mantle points, and multiple floor materials (e.g. a map with
   both concrete and metal/glass areas).
2. Run `cod-eq-off.ps1` first and walk the map: mantle a ledge, wall-jump, reload,
   climb a ladder, walk on 2-3 different surfaces. This is your uncolored baseline - note
   what you can and can't hear.
3. Run `cod-eq-v1.ps1`, repeat the same actions in the same spots.
4. Run `cod-eq-v2.ps1`, repeat again.
5. Run `cod-eq-v3.ps1`, repeat again, paying specific attention to the cues v1/v2
   struggled with: reload clicks from a distance, mantle contact sound as an enemy (bot)
   peeks a ledge, wall-jump texture, ladder climbing, and glass if the map has it.
6. Each script prints which profile is active and where it backed up the previous config -
   use that confirmation rather than trusting memory of which one you last ran.
7. If v3 sounds harsh or fatiguing after a full match (not just a quick test), that's a
   signal to dial back Filter 7 (2700 Hz) or Filter 8 (3400 Hz) by 0.3-0.5 dB rather than
   reverting to v2 wholesale - the new bands are the ones most likely to need a small trim
   for your ear.

## 8. Optional local verification commands

Run these on your Windows machine if you want to confirm the audit assumptions above
against your real files, rather than taking this document's reconstruction on faith:

```powershell
# Confirm which config file Equalizer APO is actually using, and see its live content
Get-Content "$Env:ProgramFiles\EqualizerAPO\config\config.txt" -ErrorAction SilentlyContinue
Get-ChildItem "$Env:ProgramFiles\EqualizerAPO\config" -Recurse -Filter config.txt

# Diff your real v1/v2/off scripts against this repo's reconstructions after cloning it
git diff --no-index C:\Users\isaac\Documents\Codex\cod-eq-v1.ps1 scripts\cod-eq-v1.ps1
git diff --no-index C:\Users\isaac\Documents\Codex\cod-eq-v2.ps1 scripts\cod-eq-v2.ps1
```
