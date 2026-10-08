"""Trims the bundled fonts to what the app actually draws.

Run after changing any text in lib/:
    pip install fonttools uharfbuzz
    python3 tool/subset_fonts.py

Full source fonts are not committed; download them into tool/fonts_src/
(see tool/fonts_src/README.md). Trimmed copies go to assets/fonts/.
"""
import pathlib
import re
import sys

import uharfbuzz as hb
from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

root = pathlib.Path(__file__).resolve().parent.parent
src = root / "tool" / "fonts_src"
out_dir = root / "assets" / "fonts"
text = "".join(p.read_text(encoding="utf-8") for p in (root / "lib").rglob("*.dart"))
literals = re.findall(r"'([^'\n]*)'", text)

ascii_ = "".join(chr(c) for c in range(0x20, 0x7F))
latin = ascii_ + "".join(sorted({c for c in text if 0x80 <= ord(c) < 0x600})) + "—’…"
arabic = "".join(sorted({c for c in text if re.match("[؀-ۿﹰ-﻿]", c)}))
arabic += "".join(chr(c) for c in range(0x0660, 0x066A)) + "،۝ "

# Urdu strings are the ones using Urdu-only letters (ے ہ ی ک گ ں ٹ ڈ ڑ ھ).
urdu_letters = "[ےہیکگںٹڈڑھ]"
urdu_strings = [s for s in literals if re.search(urdu_letters, s)]


def options():
    o = subset.Options()
    o.layout_features = ["*"]  # keep shaping, ligatures and mark positioning
    o.name_IDs = ["*"]
    o.notdef_outline = True
    o.hinting = False
    return o


def save(font, name, src_size):
    out = out_dir / name
    font.save(str(out))
    print(f"{name}: {src_size // 1024} KB -> {out.stat().st_size // 1024} KB")
    return out


def subset_chars(path, chars, name, font=None):
    o = options()
    font = font or subset.load_font(str(path), o)
    s = subset.Subsetter(o)
    s.populate(text=chars)
    s.subset(font)
    return save(font, name, path.stat().st_size)


def shape(path, strings, gids=None):
    """Glyph outlines and positions HarfBuzz produces for each string and
    word. Outlines stand in for glyph names, which some fonts leave blank."""
    blob = hb.Blob.from_file_path(str(path))
    font = hb.Font(hb.Face(blob))
    tt = TTFont(str(path))
    order, glyf = tt.getGlyphOrder(), tt["glyf"]
    outline = lambda i: glyf[order[i]].compile(glyf)
    runs = []
    for s in strings:
        for piece in [s, *s.split()]:
            buf = hb.Buffer()
            buf.add_str(piece)
            buf.guess_segment_properties()
            if gids is not None:
                # Nastaliq ligatures form in stages; keep the glyphs seen
                # between lookups too, or the rules that use them are dropped.
                def seen(_message, buf=buf):
                    gids.update(i.codepoint for i in buf.glyph_infos)
                    return True

                buf.set_message_func(seen)
            hb.shape(font, buf)
            if gids is not None:
                gids.update(i.codepoint for i in buf.glyph_infos)
            runs.append([
                (outline(i.codepoint), p.x_advance, p.x_offset, p.y_offset)
                for i, p in zip(buf.glyph_infos, buf.glyph_positions)
            ])
    return runs


def subset_shaped(path, strings, name):
    """Keeps only the glyphs the given strings shape to. Nastaliq fonts hold
    thousands of precomposed ligatures, so this is far smaller than keeping
    every glyph reachable from the characters."""
    gids = {0}
    before = shape(path, strings, gids)
    o = options()
    o.layout_closure = False
    font = subset.load_font(str(path), o)
    s = subset.Subsetter(o)
    s.populate(gids=gids, text="".join(strings) + " ۔")
    s.subset(font)
    out = save(font, name, path.stat().st_size)
    if shape(out, strings) != before:
        sys.exit(f"{name}: shaping changed after trimming; keep more glyphs")


out_dir.mkdir(exist_ok=True)
for old in out_dir.glob("*.ttf"):
    old.unlink()

sans = src / "GoogleSans[GRAD,opsz,wght].ttf"
for weight, style in [(400, "Regular"), (600, "SemiBold"), (700, "Bold")]:
    static = instancer.instantiateVariableFont(
        TTFont(str(sans)), {"wght": weight, "opsz": 18, "GRAD": 0}
    )
    o = options()
    s = subset.Subsetter(o)
    s.populate(text=latin)
    s.subset(static)
    save(static, f"GoogleSans-{style}.ttf", sans.stat().st_size)

subset_chars(src / "Boldonse-Regular.ttf", ascii_, "Boldonse-Regular.ttf")
subset_chars(src / "PDMS_Saleem_QuranFont.ttf", arabic, "PDMSSaleemQuran.ttf")
subset_shaped(src / "JameelNooriNastaleeq.ttf", urdu_strings, "JameelNooriNastaleeq.ttf")
