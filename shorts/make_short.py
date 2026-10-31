#!/usr/bin/env python3
"""Kiberxavfliy shorts generator: content/<name>.json -> videos/<name>.mp4 (1080x1920).

Ovoz: Microsoft uz-UZ-SardorNeural (edge-tts). Kerak: ffmpeg, pillow, edge-tts.
Ishlatish: python3 make_short.py content/parol.json
"""
import asyncio, json, os, subprocess, sys, tempfile, textwrap
import certifi
if os.path.exists("/root/.ccr/ca-bundle.crt"):  # sandbox proxy CA (tekshiruv yoqilgan holda)
    certifi.where = lambda: "/root/.ccr/ca-bundle.crt"
import edge_tts
from PIL import Image, ImageDraw, ImageFont

VOICE = "uz-UZ-SardorNeural"
W, H = 1080, 1920
BG_TOP, BG_BOT, ACCENT, FG = (8, 16, 36), (4, 40, 52), (0, 224, 168), (240, 246, 250)
FB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
FR = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

def gradient():
    img = Image.new("RGB", (W, H))
    px = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        px.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOT)))
    return img

def frame(kind, text, idx, total, title):
    img = gradient(); d = ImageDraw.Draw(img)
    d.text((70, 90), "KIBERXAVFLIY", font=ImageFont.truetype(FB, 44), fill=ACCENT)
    d.rectangle([70, 150, 330, 156], fill=ACCENT)
    # progress dots
    for i in range(total):
        x = W // 2 - total * 25 + i * 50
        d.ellipse([x, H - 150, x + 24, H - 126], fill=ACCENT if i <= idx else (60, 80, 96))
    size = 92 if kind == "hook" else 64
    font = ImageFont.truetype(FB if kind == "hook" else FR, size)
    wrap = 16 if kind == "hook" else 24
    lines = textwrap.wrap(text, wrap)
    lh = int(size * 1.35)
    y = (H - lh * len(lines)) // 2
    if kind == "point":
        d.text((70, y - 150), f"{idx}", font=ImageFont.truetype(FB, 120), fill=ACCENT)
    for ln in lines:
        w = d.textlength(ln, font=font)
        d.text(((W - w) / 2 if kind != "point" else 70, y), ln, font=font, fill=FG)
        y += lh
    d.text((70, H - 80), "@kiberxavfliy", font=ImageFont.truetype(FR, 36), fill=(150, 170, 185))
    return img

async def tts(text, path):
    await edge_tts.Communicate(text, VOICE).save(path)

def dur(path):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                                          "-of", "csv=p=0", path]).decode())

def main(spec_path):
    spec = json.load(open(spec_path))
    name = os.path.splitext(os.path.basename(spec_path))[0]
    scenes = [("hook", spec["hook"])] + [("point", p) for p in spec["points"]] + [("cta", spec["cta"])]
    tmp = tempfile.mkdtemp(prefix=name + "_")
    clips = []
    for i, (kind, text) in enumerate(scenes):
        a, im, clip = f"{tmp}/{i}.mp3", f"{tmp}/{i}.png", f"{tmp}/{i}.mp4"
        asyncio.run(tts(text, a))
        frame(kind, text, i, len(scenes) - 1, spec["title"]).save(im)
        d = dur(a) + 0.45
        subprocess.check_call(["ffmpeg", "-y", "-loglevel", "error", "-loop", "1", "-i", im, "-i", a,
                               "-af", "apad", "-t", f"{d:.2f}", "-r", "30", "-c:v", "libx264",
                               "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "128k", clip])
        clips.append(clip)
    lst = f"{tmp}/list.txt"
    open(lst, "w").write("".join(f"file '{c}'\n" for c in clips))
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "videos", name + ".mp4")
    subprocess.check_call(["ffmpeg", "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst,
                           "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac", "-movflags", "+faststart", out])
    print(out, f"{dur(out):.1f}s")

if __name__ == "__main__":
    main(sys.argv[1])
