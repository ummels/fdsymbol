#!/usr/bin/python

import argparse
from itertools import product
import fontforge

FAMILY = "FdSymbol"
ALIASES = {"uni2A3D": ("uni2319",),
           "uni219D": ("uni21DD", "uni2933"),
           "uni219C": ("uni21DC", "uni2B3F"),
           "uni22A5": ("uni27C2",),
           "uni2AE7": ("uni3012",),
           "uni2223": ("bar",),
           "uni2225": ("uni2016",)}

def addlig(iterable, glyph):
    """Make glyph a ligature for iterable."""
    components = tuple(iterable)
    if all((font.findEncodingSlot(name) in font) for name in components):
        # Translate to real glyphnames
        glyphs = tuple(font[font.findEncodingSlot(name)].glyphname
                       for name in components)
        glyph.addPosSub("Ligature subtable", glyphs)

parser = argparse.ArgumentParser(description="""
Create one OpenType font from several Type1 fonts.
""")
parser.add_argument("-f", "--featurefile", help="OpenType feature file",
                    metavar="featurefile")
parser.add_argument("fontfile", nargs="+",help="original font file (.pfb)")
parser.add_argument("otffile", help="output file (.otf)")
args = parser.parse_args()

# Read PFB files
font = fontforge.open(args.fontfile[0])
for fname in args.fontfile[1:]:
    font.mergeFonts(fname)
font.encoding = "UnicodeBmp"

# Set the font name
weight = font.fontname.rpartition("-")[2]
font.familyname = FAMILY
font.fontname = FAMILY + "-" + weight
font.fullname = FAMILY + " " + weight

# Add space
space = font.createChar(0x20, "space")
space.width = 400

# Map each glyph of the form sym0xx to uniE0xx
for i in xrange(0x100): # Adapt if necessary
    glyphname = "sym{0:03X}".format(i)
    if glyphname in font:
        font[glyphname].unicode = 0xE000 + i

# Add ligature table
font.addLookup("Ligature lookup",
               "gsub_ligature", (),
               (("liga", (("DFLT", ("dflt",)),
                          ("grek", ("dflt",)),
                          ("latn", ("dflt",)))),))
font.addLookupSubtable("Ligature lookup", "Ligature subtable")
for glyph in font.glyphs():
    glyphname = glyph.glyphname
    # Skip glyph variants
    if "." in glyphname:
        pass
    # Test for glyph1_glyph2_... ligature
    elif "_" in glyphname:
        components = glyphname.split("_")
        addlig(components, glyph)
    # Test for uniXXXXYYYY... ligature
    elif (glyphname.startswith("uni") and len(glyphname) > 7 and
          len(glyphname) % 4 == 3):
        components = ("uni" + glyphname[k:k + 4]
                      for k in xrange(3, len(glyphname), 4))
        addlig(components, glyph)

# Read feature file
if args.featurefile:
    font.mergeFeature(args.featurefile)

# Add alias glyphs
for glyphname in ALIASES:
    if glyphname in font:
        for name in ALIASES[glyphname]:
            glyph = font.createMappedChar(name)
            if not glyph.isWorthOutputting():
                glyph.addReference(glyphname)
# Amend lookup tables
for glyph in font.glyphs():
    for row in glyph.getPosSub("*"):
        if row[1] == "Substitution":
            for name in ALIASES.get(glyph.glyphname, ()):
                font[name].addPosSub(row[0], row[2])
        elif row[1] in ("AltSubs", "MultSubs"):
            for name in ALIASES.get(glyph.glyphname, ()):
                font[name].addPosSub(row[0], row[2:])
        elif row[1] == "Ligature":
            for components in product(*(ALIASES.get(name, ()) + (name,)
                                        for name in row[2:])):
                if components != row[2:]:
                    glyph.addPosSub(row[0], components)

# Adjust vertical metrics
font.os2_typolinegap = 500 # Change?
font.hhea_linegap = 0
font.hhea_ascent_add = 0
font.hhea_descent_add = 0
font.hhea_ascent = font.ascent + font.os2_typolinegap / 2
font.hhea_descent = -(font.descent + font.os2_typolinegap / 2)

# Write OTF file
font.generate(args.otffile, flags=("opentype",))
print "Succesfully generated " + args.otffile + "."
