PDFLATEX := pdflatex
RM := rm -rf
INSTALL := install
INSTALLDIR := $(INSTALL) -d
INSTALLDATA := $(INSTALL) -m 644

ifneq (,$(findstring install,$(MAKECMDGOALS)))
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')
endif

pkg := fdsymbol

.PHONY: all package doc install uninstall clean

all: package

package: $(pkg).sty

doc: $(pkg).pdf

$(pkg).sty: $(pkg).ins $(pkg).dtx
	$(PDFLATEX) $(pkg).ins

$(pkg).pdf: $(pkg).dtx
	$(PDFLATEX) $(pkg).dtx
	while grep -s 'Rerun to get' $(pkg).log; do \
	  $(PDFLATEX) $(pkg).dtx; \
	done

install: all
	$(INSTALLDIR) $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDATA) $(pkg).sty $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDATA) $(pkg).pdf $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/source/latex/$(pkg)
	$(INSTALLDATA) $(pkg).ins $(pkg).dtx $(TEXMFDIR)/source/latex/$(pkg)

uninstall:
	$(RM) $(TEXMFDIR)/tex/latex/$(pkg)
	$(RM) $(TEXMFDIR)/doc/latex/$(pkg)
	$(RM) $(TEXMFDIR)/source/latex/$(pkg)

clean:
	$(RM) $(pkg).aux $(pkg).log $(pkg).out $(pkg).sty $(pkg).toc
