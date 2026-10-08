"""Trims the bundled fonts to the characters the app actually uses.

Run after changing any text in lib/:
    pip install fonttools
    python3 tool/subset_fonts.py
Full fonts live in tool/fonts_src/; trimmed copies go to assets/fonts/.
"""
import pathlib
import re

from fontTools import subset

root = pathlib.Path(__file__).resolve().parent.parent
text = "".join(p.read_text(encoding="utf-8") for p in (root / "lib").rglob("*.dart"))

ascii_ = "".join(chr(c) for c in range(0x20, 0x7F))
latin = ascii_ + "".join(sorted({c for c in text if 0x80 <= ord(c) < 0x600}))
arabic = "".join(sorted({c for c in text if re.match("[؀-ۿﹰ-﻿]", c)}))
# Arabic-Indic digits, comma and the ayah mark, for any number shown in Arabic.
arabic += "".join(chr(c) for c in range(0x0660, 0x066A)) + "،۝ "

# Nastaliq is large, so it gets only the letters of Urdu strings (those using
# Urdu-only letters), leaving out the Arabic vowel marks it would otherwise keep.
urdu_strings = [
    s for s in re.findall(r"'([^'\n]*)'", text)
    if re.search("[ےہیکگںٹڈڑھ]", s)
]
urdu = "".join(sorted(set("".join(urdu_strings)))) + "۔"

fonts = {
    "GoogleSans.ttf": latin + "—’…",
    "Boldonse.ttf": ascii_,
    "AmiriQuran.ttf": arabic,
    "NotoNastaliqUrdu.ttf": urdu,
}

for name, chars in fonts.items():
    src = root / "tool" / "fonts_src" / name
    out = root / "assets" / "fonts" / name
    options = subset.Options()
    options.layout_features = ["*"]  # keep Arabic shaping and marks
    options.name_IDs = ["*"]
    options.notdef_outline = True
    options.hinting = False
    font = subset.load_font(str(src), options)
    s = subset.Subsetter(options)
    s.populate(text=chars)
    s.subset(font)
    subset.save_font(font, str(out), options)
    print(f"{name}: {src.stat().st_size // 1024} KB -> {out.stat().st_size // 1024} KB")
