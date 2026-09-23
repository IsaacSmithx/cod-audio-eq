# cod-audio-eq

Call of Duty audio EQ and OBS setup notes for repeatable local tuning, streaming scenes, and cloud coding sessions.

## What this repo is for

This repository is a small home base for:

- Equalizer APO / Peace EQ presets
- Call of Duty audio tuning notes
- OBS scene, filter, and recording setup notes
- Scripts or utilities used to swap, back up, or document audio settings
- Claude Cloud or other coding agent sessions that need a GitHub-backed project

It does not need to contain private game captures, stream keys, tokens, or personal audio devices unless you explicitly choose to add sanitized examples.

## Layout

```text
configs/
  equalizer-apo/    Equalizer APO and Peace EQ config notes or exported presets
  obs/              OBS scene, filter, recording, and streaming setup notes
docs/
  cloud-session-prompt.md
scripts/           Helper scripts for backups, exports, or setup checks
```

## First setup

1. Add sanitized Equalizer APO or Peace EQ exports under `configs/equalizer-apo/`.
2. Add OBS setup notes or exported scene collections under `configs/obs/`.
3. Keep secrets out of the repo, including stream keys, account tokens, and private device identifiers.
4. Use `docs/cloud-session-prompt.md` when starting a Claude Cloud session from this repo.

## Suggested GitHub description

Call of Duty audio EQ and OBS streaming setup workspace for repeatable tuning, config notes, and cloud coding sessions.
