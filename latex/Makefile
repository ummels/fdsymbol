LATEX = pdflatex
INSTALL = install
INSTALLDIR = $(INSTALL) -d
INSTALLDATA = $(INSTALL) -m 644

TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

pkg := fdsymbol

.PHONY: all package doc install uninstall clean

all: package

package: $(pkg).sty

doc: $(pkg).pdf

$(pkg).sty: $(pkg).ins $(pkg).dtx
	rm -f $@
	$(LATEX) $(pkg).ins

$(pkg).pdf: $(pkg).dtx
	$(LATEX) $(pkg).dtx
	while grep -s 'Rerun to get' $(pkg).log; do \
	  $(LATEX) $(pkg).dtx; \
	done

install: all doc
	$(INSTALLDIR) -d $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDATA) $(pkg).sty $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDIR) -d $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDATA) $(pkg).pdf $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDIR) -d $(TEXMFDIR)/source/latex/$(pkg)
	$(INSTALLDATA) $(pkg).ins $(pkg).dtx $(TEXMFDIR)/source/latex/$(pkg)

uninstall:
	rm -rf $(TEXMFDIR)/tex/latex/$(pkg)
	rm -rf $(TEXMFDIR)/doc/latex/$(pkg)
	rm -rf $(TEXMFDIR)/source/latex/$(pkg)

clean:
	rm -f $(pkg).aux $(pkg).log $(pkg).out $(pkg).sty $(pkg).toc
