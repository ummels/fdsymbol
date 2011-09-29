#!/usr/bin/python

import sys
import argparse
import fontforge
from itertools import product

family = "FdSymbol"

aliases = {"uni2A3D": ["uni2319"],
           "uni219D": ["uni21DD", "uni2933"],
           "uni219C": ["uni21DC", "uni2B3F"],
           "uni22A5": ["uni27C2"],
           "uni2AE7": ["uni3012"],
           "uni2223": ["bar"],
           "uni2225": ["uni2016"]}

def setnames(font):
    """Set the font name."""
    weight = font.fontname.rpartition("-")[2]
    font.familyname = family
    font.fontname = family + "-" + weight
    font.fullname = family + " "  + weight

def addspace(font):
    """Add a space character."""
    space = font.createChar(0x20, "space")
    space.width = 400

def fillpua(font):
    """Map each glyph of the form sym0xx to uniE0xx."""
    for i in range(0x100): # Adapt if necessary
        glyphname = "sym{0:03X}".format(i)
        if glyphname in font:
            font[glyphname].unicode = 0xE000 + i

def addligatures(font):
    """Add ligature table."""
    def addlig(components, glyph):
        if all((font.findEncodingSlot(name) in font) for name in components):
            # Translate to real glyphnames
            components = [font[font.findEncodingSlot(name)].glyphname
                          for name in components]
            glyph.addPosSub("Ligature subtable", tuple(components))

    font.addLookup("Ligature lookup",
                   "gsub_ligature", (),
                   (('liga', (('DFLT', ('dflt',)),
                              ('grek', ('dflt',)),
                              ('latn', ('dflt',)))),))
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
            components = ["uni" + glyphname[k:k + 4]
                          for k in range(3, len(glyphname), 4)]
            addlig(components, glyph)

def addaliases(font):
    """Add alias glyphs."""
    
    for glyphname in aliases:
        if glyphname in font:
            for name in aliases[glyphname]:
                g = font.createMappedChar(name)
                if not g.isWorthOutputting():
                    g.addReference(glyphname)
    # Amend lookup tables
    for glyph in font.glyphs():
        for row in glyph.getPosSub("*"):
            if row[1] == "Substitution" and glyph.glyphname in aliases:
                for name in aliases[glyph.glyphname]:
                    font[name].addPosSub(row[0],row[2])
            elif (row[1] in ["AltSubs", "MultSubs"] and
                  glyph.glyphname in aliases):
                for name in aliases[glyph.glyphname]:
                    font[name].addPosSub(row[0],row[2:])
            elif row[1] == "Ligature":
                for components in product(*(aliases.get(name, []) + [name]
                                          for name in row[2:])):
                    if components != row[2:]:
                        glyph.addPosSub(row[0],components)

def adjustmetrics(font):
    """Adjust vertical metrics."""
    font.os2_typolinegap = 500 # Change?
    font.hhea_linegap = 0
    font.hhea_ascent_add = 0
    font.hhea_descent_add = 0
    font.hhea_ascent = font.ascent + font.os2_typolinegap / 2
    font.hhea_descent = -(font.descent + font.os2_typolinegap / 2)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
    Create one OpenType font from several Type1 fonts.
    """)
    parser.add_argument("-f", "--featurefile",
                        help="OpenType feature file",
                        metavar="featurefile")
    parser.add_argument("fontfile", nargs="+",
                        help="original font file (.pfb)")
    parser.add_argument("otffile", help="output file (.otf)")
    args = parser.parse_args()

    font = fontforge.open(args.fontfile[0])
    for fname in args.fontfile[1:]:
        font.mergeFonts(fname)
    font.encoding = "UnicodeBmp"
    setnames(font)
    addspace(font)
    fillpua(font)
    addligatures(font)
    if args.featurefile:
        font.mergeFeature(args.featurefile)
    addaliases(font)
    adjustmetrics(font)

    font.generate(args.otffile, flags=("opentype"))
    print "Succesfully generated " + args.otffile + "."
