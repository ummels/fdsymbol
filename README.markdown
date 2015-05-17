FdSymbol - A math symbol font
=============================

FdSymbol is a math symbol font, designed as a companion to the
[Fedra family][FD] by Typotheque, but it might also fit other contemporary
typefaces.

[![Build Status](https://travis-ci.org/ummels/fdsymbol.svg?branch=master)](https://travis-ci.org/ummels/fdsymbol)

[FD]: http://www.typotheque.com/fonts

Usage
-----

To use this font in LaTeX, include

    \usepackage{fdsymbol}

in the preamble of your LaTeX document. See the [PDF documentation](fdsymbol.pdf)
for the details.

Installation
------------

Building the fonts requires FontForge (>=20110222), afm2tfm and Python 2.7 with the
`fontforge` module enabled.

Rebuilding the FontForge source files from the Metafont sources additionally requires
Metafont (>=2.718281), MetaPost (>=1.902) and mf2pt1 (>= 2.5).

To install the fonts, the accompanying LaTeX package and the documentation
in your home texmf tree, run:

    make install

If you want to use a different texmf tree, you can specify it using the
variable TEXMFDIR:

    make install TEXMFDIR=/usr/local/texlive/texmf-local

Afterwards, you may need to regenerate the file database:

    texhash

Finally, you need to activate the map file:

    updmap --enable Map=fdsymbol.map

For a system-wide installation, replace updmap by updmap-sys.

License
-------

Copyright (c) 2012-2015 by Michael Ummels <michael.ummels@rwth-aachen.de>

The font components of this software, e.g. MetaFont (.mf), TeX font metric
(.tfm), Type 1 (.pfb), and OpenType (.otf) files, are licensed under the
[SIL Open Font License][OFL], Version 1.1.

[OFL]: http://scripts.sil.org/OFL

The LaTeX support files contained in this software may be modified and
distributed under the terms and conditions of the
[LaTeX Project Public License][LPPL], version 1.3c or greater (your choice).

[LPPL]: http://www.latex-project.org/lppl/

This work has the LPPL maintenance status `maintained'.

The Current Maintainer of this work is Michael Ummels.

This work consists of the files fdsymbol.dtx, fdsymbol.ins
and the derived files fdsymbol.sty and fdsymbol.pdf.

All other files distributed with these sources, e.g. the Makefile and
the Python scripts are in the public domain.
