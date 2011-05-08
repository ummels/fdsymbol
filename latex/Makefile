LATEX = pdflatex
INSTALL = install
INSTALLDIR = $(INSTALL) -d
INSTALLDATA = $(INSTALL) -m 644

PKG := fdsymbol
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

.PHONY: all package doc install uninstall clean

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
	$(INSTALLDIR) -d $(TEXMFDIR)/tex/latex/$(PKG)
	$(INSTALLDATA) $(PKG).sty $(TEXMFDIR)/tex/latex/$(PKG)
	$(INSTALLDIR) -d $(TEXMFDIR)/doc/latex/$(PKG)
	$(INSTALLDATA) $(PKG).pdf $(TEXMFDIR)/doc/latex/$(PKG)
	$(INSTALLDIR) -d $(TEXMFDIR)/source/latex/$(PKG)
	$(INSTALLDATA) $(PKG).ins $(PKG).dtx $(TEXMFDIR)/source/latex/$(PKG)

uninstall:
	rm -rf $(TEXMFDIR)/tex/latex/$(PKG)
	rm -rf $(TEXMFDIR)/doc/latex/$(PKG)

clean:
	rm -f $(PKG).aux $(PKG).log $(PKG).out $(PKG).sty $(PKG).toc
