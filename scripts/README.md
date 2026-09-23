# Scripts

- `cod-eq-v1.ps1` / `cod-eq-v2.ps1` / `cod-eq-off.ps1` / `cod-eq-v3.ps1` - write the
  matching profile from `configs/equalizer-apo/` into Equalizer APO's config file,
  scoped only to the Elgato 4K X capture endpoint. Each backs up the current config
  to `<EqualizerAPO>\config\backups\` before writing, and reports which profile is
  now active. See [`docs/cod-audio-eq-v3-audit.md`](../docs/cod-audio-eq-v3-audit.md)
  for the audit, filter-by-filter rationale, and A/B test steps.
- `publish-github.ps1` - creates and pushes this repo to GitHub via `gh`.

Possible future scripts:

- Export OBS scene/profile folders
- Validate that private files are not staged before commit
