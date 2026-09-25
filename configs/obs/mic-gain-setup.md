# Mic is too quiet: OBS gain/compressor setup

Goal: raise perceived mic loudness for viewers without clipping or raising the
noise floor. EQ shape is assumed to already be good — this is about level only.

## 1. Rule out non-OBS gain first

Software gain amplifies everything, including hiss and room noise. Before
touching OBS filters, get as much *clean* gain as possible upstream:

- If the mic plugs into an audio interface/mixer (GoXLR, Scarlett, Cloudlift,
  etc.), raise the analog/hardware gain knob until the interface's own meter
  sits comfortably, then let OBS do only the fine-tuning.
- If it's a USB mic, check Windows Sound settings → Recording device →
  Properties → Levels, and make sure "Microphone Boost" isn't left low/off.
- Confirm mic distance/technique — moving 2-3 inches closer often buys more
  loudness than any plugin.

Software-only fixes (below) are for when hardware gain is already maxed out
sensibly, or you don't want to touch OS-level settings mid-stream.

## 2. Recommended OBS filter chain and order

In OBS, filters process top-to-bottom in the order they're listed, so order
matters. On the mic source's Filters panel, use:

1. **Noise Suppression** (RNNoise or NVIDIA Broadcast) — only if there's
   background hiss/hum to remove. Do this before boosting gain so you're not
   amplifying noise.
2. **Noise Gate / Expander** (optional) — mutes/attenuates the mic below a
   threshold when you're not talking. Keep the threshold just below your
   quietest speech so it doesn't clip word starts.
3. **Gain** — a small, flat boost. Start at **+3 to +6 dB**. This is a
   pre-compressor "drive" boost, not the main loudness fix.
4. **Compressor** — evens out your dynamic range so quiet and loud words end
   up closer in level, then the compressor's own output/makeup gain adds
   perceived loudness on top:
   - Ratio: **3:1 to 4:1**
   - Threshold: **-18 dB**
   - Attack: **6 ms**
   - Release: **60-100 ms**
   - Output Gain (makeup gain): **+6 to +10 dB** — this is usually the
     biggest lever for "make me louder"
5. **Limiter** — a safety net, not a loudness tool. Set threshold to
   **-3 dB** (or -1 dB if you want to ride closer to 0). This catches any
   peak that would otherwise clip after the gain/compressor boost.
6. Your existing EQ, unchanged, last in the chain (or before the limiter if
   you'd rather the limiter catch post-EQ peaks).

## 3. Checking levels

- Watch the OBS audio mixer meter for the mic while talking at normal
  stream volume. Average level should sit around **-18 to -12 dB**, with
  peaks reaching **-6 dB**, never hitting **0 dB / the red zone**.
- If you're still too quiet after Gain +6 dB and Compressor makeup +10 dB,
  raise Gain further in 2-3 dB steps rather than pushing Compressor makeup
  past +12 dB — heavy makeup gain on top of a big Gain boost is what
  introduces audible noise/hiss.
- If you start hearing hiss/room noise creep in, back off the Gain filter
  first (it boosts noise floor equally with signal) and lean more on
  Compressor makeup gain (which only boosts once the mic is already above
  the compressor's threshold).

## 4. Quick troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Still quiet after all filters | Hardware gain too low upstream | Raise interface/OS mic gain, redo step 1 |
| Loud but noisy/hissy | Gain filter pushed too high | Lower Gain filter, raise Compressor makeup instead |
| Occasional clipping/crackle on loud words | No limiter, or limiter threshold too high | Add/lower Limiter threshold to -3 dB |
| Level pumps up/down noticeably | Compressor ratio/attack too aggressive | Lower ratio to ~3:1, raise attack to 10-15 ms |
