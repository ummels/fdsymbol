# FdSymbol - A math symbol font

FdSymbol is a math symbol font, designed as a companion to the
[Fedra family](https://www.typotheque.com/fonts) by Typotheque, but it might
also fit other contemporary typefaces.

## Usage

To use this font in LaTeX, include

    \usepackage{fdsymbol}

in the preamble of your LaTeX document. See the
[PDF documentation](latex/fdsymbol.pdf) for the details.

If you are interested in a full integration with
[Fedra Serif](https://www.typotheque.com/fonts/fedra-serif), take a look at the
[fedraserif](https://github.com/ummels/fedraserif) package.

## Installation

Building the fonts requires Metafont (>=2.718281), FontForge (>=20201107) and
Python 3 with the `fontforge` module enabled.

Rebuilding the FontForge source files from the Metafont sources additionally
requires MetaPost (>=1.902) and mf2pt1 (>= 2.5).

To install the fonts, the accompanying LaTeX package and the documentation
in your private texmf tree, run:

    make install

If you want to use a different texmf tree, you can specify it using the
variable TEXMFDIR:

    make install TEXMFDIR=/usr/local/texlive/texmf-local

Afterwards, make sure to update the file database using `mktexlsr` or
`texhash` (the command may vary depending on what distribution you use).

Finally, you need to activate the map file `fdsymbol.map`. For TeX Live, this
can be achieved by the following command:

    updmap-user --enable Map=fdsymbol.map

For installation in a system-wide texmf tree, replace `updmap-user` by
`updmap-sys`.

Make sure you have read https://tug.org/texlive/scripts-sys-user.html before
invoking `updmap-user`.

## License

Copyright (c) 2011-2025 by Michael Ummels <michael@ummels.de>

The font components of this software, e.g. MetaFont (.mf), TeX font metric
(.tfm), Type 1 (.pfb), and OpenType (.otf) files, are licensed under the
[SIL Open Font License](https://openfontlicense.org), Version 1.1.

The LaTeX support files contained in this software may be modified and
distributed under the terms and conditions of the
[LaTeX Project Public License](https://www.latex-project.org/lppl/),
version 1.3c or greater (your choice).

This work has the LPPL maintenance status `maintained'.

The Current Maintainer of this work is Michael Ummels.

This work consists of the files fdsymbol.dtx, fdsymbol.ins
and the derived files fdsymbol.sty and fdsymbol.pdf.

All other files distributed with these sources, e.g. the Makefile and
the Python scripts are in the public domain.
