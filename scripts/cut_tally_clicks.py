#!/usr/bin/env python3
"""Cuts the tally clicks in Shared/ (TallyPress1-3.caf, TallyRelease1-3.caf) out of a recording of a real counter:
"Tally Counter" by revdrmr, https://freesound.org/s/664698/ (CC0).

The recording is pairs of clicks about 0.2 s apart: the plunger going down, then the spring bringing it back up.
Three clean pairs are cut tightly (0.5 ms before the click, so it plays the instant the cap moves), with an
80 Hz high-pass for handling rumble and short fades. Each pair is scaled together, so the release stays as much
softer than the press as it is in the recording.

Loudness: the press's loudest 10 ms is set to TARGET_RMS_DB, measured against iOS's own sounds (iOS 26.5
simulator, same measure): the classic keyboard click (key_press_click) is -22.6 dBFS, the current keyboard tap
(keyboard_press_normal) -32.9, the lock sound -28.5. The counter sits between the two keyboard sounds: audible,
but no louder than the keyboard someone might be typing on.

Run from the repo root (macOS, for afconvert):
    python3 scripts/cut_tally_clicks.py ~/Downloads/664698__revdrmr__tally-counter.wav
"""
import math, os, struct, subprocess, sys, tempfile, wave

TARGET_RMS_DB = -26

# (press onset s, press length ms, release onset s, release length ms), found by measuring the recording.
PAIRS = [(3.134, 56, 3.345, 72), (5.972, 54, 6.186, 55), (30.051, 49, 30.296, 52)]


def load(path):
    """The recording as 16-bit samples (it's 32-bit float, which `wave` can't read)."""
    tmp = os.path.join(tempfile.mkdtemp(), "source.wav")
    subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEI16", path, tmp], check=True)
    with wave.open(tmp) as w:
        rate, n = w.getframerate(), w.getnframes()
        return rate, struct.unpack(f"<{n}h", w.readframes(n))


def cut(x, rate, t, ms):
    i = int(t * rate)
    # Start 0.5 ms before the first sample above 20% of the click's peak.
    seg = x[i - rate // 200 : i + int(ms / 1000 * rate)]
    p = max(abs(v) for v in seg)
    k = next(j for j, v in enumerate(seg) if abs(v) > 0.2 * p)
    start = i - rate // 200 + k - rate // 2000
    s = x[start : start + int((ms + 15) / 1000 * rate)]
    a = math.exp(-2 * math.pi * 80 / rate)
    y, px, py = [], 0.0, 0.0
    for v in s:
        py = a * (py + v - px)
        px = v
        y.append(py)
    fade_in, fade_out = rate // 2000, int(0.010 * rate)
    for j in range(fade_in):
        y[j] *= j / fade_in
    for j in range(fade_out):
        y[-fade_out + j] *= 1 - j / fade_out
    return y


def write(path, rate, samples, gain):
    tmp = os.path.join(tempfile.mkdtemp(), "click.wav")
    with wave.open(tmp, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(b"".join(struct.pack("<h", max(-32767, min(32767, int(v * gain)))) for v in samples))
    subprocess.run(["afconvert", "-f", "caff", "-d", "LEI16", tmp, path], check=True)


rate, x = load(sys.argv[1])
for take, (pt, pl, rt, rl) in enumerate(PAIRS, 1):
    press, release = cut(x, rate, pt, pl), cut(x, rate, rt, rl)
    win = int(0.010 * rate)
    loudest = max(math.sqrt(sum(v * v for v in press[i : i + win]) / win) for i in range(0, len(press) - win, win // 4))
    gain = 32768 * 10 ** (TARGET_RMS_DB / 20) / loudest
    write(f"Shared/TallyPress{take}.caf", rate, press, gain)
    write(f"Shared/TallyRelease{take}.caf", rate, release, gain)
