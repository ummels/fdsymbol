#!/usr/bin/python

import sys
import argparse
import fontforge

family = "FdSymbol"

def setnames(font):
    """Set the font name."""
    weight = font.fontname.rpartition("-")[2]
    font.familyname = family
    font.fontname = family + "-" + weight
    font.fullname = family + " "  + weight

def fillpua(font):
    """Map each glyph of the form sym0xx to uniE0xx."""
    for i in range(0x100): # Adapt if necessary
        glyphname = "sym{0:03X}".format(i)
        if glyphname in font:
            font[glyphname].unicode = 0xE000 + i

def addligatures(font):
    """Add ligature table."""
    
    def addlig(components, glyph):
        # Test whether all components are in the font before adding ligature
        if reduce(lambda b, g: b and (g in font), components, True):
            glyph.addPosSub("Ligature subtable", tuple(components))

    font.addLookup("Ligature lookup",
                   "gsub_ligature", (),
                   (('liga', (('DFLT', ('dflt',)),
                              ('grek', ('dflt',)),
                              ('latn', ('dflt',)))),))
    font.addLookupSubtable("Ligature lookup", "Ligature subtable")
    for glyph in font.glyphs():
        glyphname = glyph.glyphname
        if "." in glyphname: break
        # Test for glyph1_glyph2_... ligature
        components = glyphname.split("_")
        if len(components) > 1:
            addlig(components, glyph)
        # Test for uniXXXXYYYY... ligature
        if (glyphname.startswith("uni") and "_" not in glyphname and
            len(glyphname) > 7 and len(glyphname) % 4 == 3):
            components = ["uni" + glyphname[k:k + 4] for
                          k in range(3, len(glyphname), 4)]
            addlig(components, glyph)

def addspace(font):
    space = font.createChar(0x20, "space")
    space.width = 400

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
    Create one OpenType font from several Type1 fonts.
    """)
    parser.add_argument("-f", "--featurefile",
                        help="OpenType feature file",
                        metavar="featurefile")
    parser.add_argument("fontfile", nargs="+", help="original font file (.pfb)")
    parser.add_argument("otffile", help="output file (.otf)")
    args = parser.parse_args()

    font = fontforge.open(args.fontfile[0])
    for fname in args.fontfile[1:]:
        font.mergeFonts(fname)

    setnames(font)
    fillpua(font)
    addligatures(font)
    if args.featurefile:
        font.mergeFeature(args.featurefile)
    addspace(font)

    font.generate(args.otffile, flags=("opentype"))
    print "Succesfully generated " + args.otffile + "."
