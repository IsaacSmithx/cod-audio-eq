# Equalizer APO / Peace EQ

Use this folder for sanitized Equalizer APO and Peace EQ presets.

## Current profiles

- `cod-eq-v1.txt` - daily/conservative
- `cod-eq-v2.txt` - competitive/stronger
- `cod-eq-off.txt` - bypass/flat, for A/B reference
- `cod-eq-v3.txt` - competitive/refined (new; see the full audit and build
  rationale in [`docs/cod-audio-eq-v3-audit.md`](../../docs/cod-audio-eq-v3-audit.md))

These are git-tracked reference copies. The deployable scripts that write them
into Equalizer APO's config file live in `scripts/cod-eq-*.ps1`. Both are
scoped only to the Elgato 4K X capture endpoint - never to Discord, Windows
system audio, Chrome, Spotify, or the HyperX microphone.

Avoid committing personal device IDs unless they are needed and safe to share.
