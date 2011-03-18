LATEX = pdflatex
INSTALL = install
INSTALLDATA = install -m 644

pkg = fdsymbol
texmfdir = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all package doc install clean

all: package doc

package: $(pkg).sty

doc: $(pkg).pdf

$(pkg).sty: $(pkg).ins $(pkg).dtx
	$(LATEX) $(pkg).ins

$(pkg).pdf: $(pkg).dtx
	$(LATEX) $(pkg).dtx
	while grep -s 'Rerun to get' $(pkg).log; do \
	  $(LATEX) $(pkg).dtx; \
	done

install: all
	$(INSTALL) -d $(texmfdir)/tex/latex/fdsymbol
	$(INSTALLDATA) $(pkg).sty $(texmfdir)/tex/latex/fdsymbol
	$(INSTALL) -d $(texmfdir)/doc/latex/fdsymbol
	$(INSTALLDATA) $(pkg).pdf $(texmfdir)/doc/latex/fdsymbol

clean:
	rm -f $(pkg).aux $(pkg).log $(pkg).out $(pkg).sty $(pkg).pdf $(pkg).toc
