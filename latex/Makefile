LATEX = pdflatex
INSTALL = install
INSTALLDATA = install -m 644

PKG = fdsymbol
TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all package doc install clean

all: package

package: $(PKG).sty

doc: $(PKG).pdf

$(PKG).sty: $(PKG).ins $(PKG).dtx
	$(LATEX) $(PKG).ins

$(PKG).pdf: $(PKG).dtx
	$(LATEX) $(PKG).dtx
	while grep -s 'Rerun to get' $(PKG).log; do \
	  $(LATEX) $(PKG).dtx; \
	done

install: all doc
	$(INSTALL) -d $(TEXMFDIR)/tex/latex/fdsymbol
	$(INSTALLDATA) $(PKG).sty $(TEXMFDIR)/tex/latex/fdsymbol
	$(INSTALL) -d $(TEXMFDIR)/doc/latex/fdsymbol
	$(INSTALLDATA) $(PKG).pdf $(TEXMFDIR)/doc/latex/fdsymbol

clean:
	rm -f $(PKG).aux $(PKG).log $(PKG).out $(PKG).sty $(PKG).toc
