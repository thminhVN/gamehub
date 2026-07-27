#!/usr/bin/env python3
"""Build the Bé vui học brand set (logo, favicon, PWA icons) from one mascot PNG.

The mascot is `priv/static/images/ui/logo.svg`; rasterise it on a transparent
background first (any size, square, mascot centred), then:

    python3 tools/build_brand.py /tmp/owl_1024.png .

Rewrites priv/static/favicon.ico, priv/static/images/icons/*.png and
priv/static/images/ui/logo.png (convert that one to .webp afterwards). Bump
CACHE_NAME in priv/static/sw.js when these change. Needs Pillow.
"""
import sys
from PIL import Image, ImageDraw

CREAM = (255, 248, 238, 255)
CREAM_DEEP = (251, 238, 217, 255)

owl_path, root = sys.argv[1], sys.argv[2].rstrip("/")
owl = Image.open(owl_path).convert("RGBA")

# Trim to the mascot's real bounds so every derived icon centres identically.
owl = owl.crop(owl.getbbox())


def backdrop(size, radius_ratio=0.0):
    """Square cream backdrop with a soft vertical warm gradient."""
    bg = Image.new("RGBA", (size, size), CREAM)
    top, bottom = CREAM, CREAM_DEEP
    grad = Image.new("RGBA", (1, size))
    for y in range(size):
        t = y / max(size - 1, 1)
        grad.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    bg = grad.resize((size, size))
    if radius_ratio:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, size - 1, size - 1], radius=int(size * radius_ratio), fill=255
        )
        bg.putalpha(mask)
    return bg


def compose(size, scale, radius_ratio=0.0):
    """Owl centred on the backdrop, occupying `scale` of the square."""
    canvas = backdrop(size, radius_ratio)
    box = int(size * scale)
    w, h = owl.size
    ratio = min(box / w, box / h)
    art = owl.resize((max(1, round(w * ratio)), max(1, round(h * ratio))), Image.LANCZOS)
    canvas.alpha_composite(art, ((size - art.width) // 2, (size - art.height) // 2))
    return canvas


icons = f"{root}/priv/static/images/icons"

# "any" icons: rounded square, generous mascot.
compose(192, 0.78, 0.22).save(f"{icons}/icon-192.png")
compose(512, 0.78, 0.22).save(f"{icons}/icon-512.png")

# maskable: full-bleed square, mascot inside the 80% safe zone.
compose(192, 0.58).save(f"{icons}/icon-maskable-192.png")
compose(512, 0.58).save(f"{icons}/icon-maskable-512.png")

# iOS applies its own mask and dislikes transparency, so keep it square+opaque.
compose(180, 0.76).convert("RGB").save(f"{icons}/apple-touch-icon.png")

# favicon: multi-size ICO; at 16px only the silhouette survives, so zoom in.
fav = compose(256, 0.92, 0.18)
fav.save(
    f"{root}/priv/static/favicon.ico",
    format="ICO",
    sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
)

# Transparent logo for the header / footer / CTA.
logo_h = 256
logo = owl.resize((round(owl.width * logo_h / owl.height), logo_h), Image.LANCZOS)
logo.save(f"{root}/priv/static/images/ui/logo.png")

print("wrote icons + logo.png")
