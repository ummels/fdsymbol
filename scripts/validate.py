#!/usr/bin/python3

import sys
import fontforge

fname = sys.argv[1]
font = fontforge.open(fname)
if font.validate() == 0:
    sys.exit(0)
else:
    print(fname + " did not validate.")
    for glyph in font.glyphs():
        state = glyph.validation_state
        if state > 1:
            print("Problems with glyph %s (%x)" % (glyph.glyphname, state))
            if (state & 0x2) > 0:
                print(" - Glyph has an open contour.")
            if (state & 0x4) > 0:
                print(" - Glyph intersects itself somewhere.")
            if (state & 0x8) > 0:
                print(" - At least one contour is drawn in the wrong direction.")
            if (state & 0x10) > 0:
                print(" - At least one reference in the glyph has been flipped.")
            if (state & 0x20) > 0:
                print(" - Missing extrema")
            if (state & 0x80000) > 0:
                print(" - Points non-integral")
    sys.exit(1)
