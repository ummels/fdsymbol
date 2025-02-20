# FdSymbol - A math symbol font

FdSymbol is a math symbol font, designed as a companion to the
[Fedra family](https://www.typotheque.com/fonts) by Typotheque, but it might
also fit other contemporary typefaces.

The development of this font package is hosted at
[GitHub](https://github.com/ummels/fdsymbol).

## Usage

To use this font in LaTeX, include

    \usepackage{fdsymbol}

in the preamble of your LaTeX document. See the
[PDF documentation](latex/fdsymbol.pdf) for the details.

If you are interested in a full integration with
[Fedra Serif](https://www.typotheque.com/fonts/fedra-serif), take a look at the
[fedraserif](https://github.com/ummels/fedraserif) package.

## Installation

The following instructions have been written for TeX Live. If you use
a different TeX distribution, please check its documentation on how to
accomplish the required steps.

After extracting the archive into a local texmf tree, run

    texhash

to update the file database, followed by

    updmap-sys --enable Map=fdsymbol.map

to activate the map file `fdsymbol.map`.

If you prefer to install the package into a private texmf tree, replace
`updmap-sys` by `updmap-user`. Before doing so, make sure you have read
https://tug.org/texlive/scripts-sys-user.html for the caveats.

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
