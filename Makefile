SHELL := /bin/sh
FONTFORGE := fontforge
MF := mf -interaction nonstopmode -halt-on-error
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
T1TESTPAGE := t1testpage
PSTOPDF := ps2pdf
PYTHON := python
PDFLATEX := pdflatex -interaction nonstopmode -halt-on-error
RM := rm -rf
TAR := tar
ZIP := zip
MKDIR := mkdir -p
INSTALL := install
INSTALLDIR := $(INSTALL) -d
INSTALLDATA := $(INSTALL) -m 644

ifneq (,$(findstring install,$(MAKECMDGOALS)))
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')
endif

pkg := fdsymbol
font := FdSymbol
names := A B C D E F
weights := Book Regular Medium Bold

tfmdir := tfm
pfbdir := type1
testdir := test
outdirs := $(tfmdir) $(pfbdir) $(testdir)

# $(call lc,text)
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

depfiles := $(names:%=$(font)%.dep)
encfiles := $(foreach i,$(names),dvips/$(pkg)-$(call lc,$i).enc)
mapfile := dvips/$(pkg).map
fonts := $(foreach i,$(names),$(weights:%=$(font)$(i)-%))
tfmfiles := $(fonts:%=$(tfmdir)/%.tfm)
pfbfiles := $(fonts:%=$(pfbdir)/%.pfb)
gffiles := $(fonts:%=$(testdir)/%.2602gf)
prooffiles := $(fonts:%=$(testdir)/%.dvi)
chartfiles := $(fonts:%=$(testdir)/%.pdf)
srcfiles := $(fonts:%=source/%.mf) $(names:%=source/$(font)%.mf) $(addprefix source/,fdbase.mf fdaccents.mf fdarrows.mf fddelims.mf fdgeometric.mf fdoperators.mf fdrelations.mf fdturnstile.mf)
tempfiles := $(addprefix latex/,$(pkg).aux $(pkg).log $(pkg).out $(pkg).toc)

# create output directories

ifeq (,$(findstring clean,$(MAKECMDGOALS)))
create-dirs := $(shell $(MKDIR) $(outdirs))
endif

# default rule

.PHONY: all
all: metrics type1 latex $(mapfile)

# rules for building Makefiles with additional dependencies

$(depfiles): %.dep: source/%.mf
	@echo "$(weights:%=$(tfmdir)/$*-%.tfm) $(weights:%=$(pfbdir)/$*-%.pfb) $(weights:%=$(testdir)/$*-%.2602gf): $< $$($(PYTHON) scripts/finddeps.py $<)" > $@
	@echo "$(weights:%=$(pfbdir)/$*-%.pfb): dvips/$$(echo $* | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]).enc" >> $@

# rules for building metrics and Postscript fonts

.PHONY: metrics
metrics: $(tfmfiles)

.PHONY: type1
type1: $(pfbfiles)

$(tfmfiles): $(tfmdir)/%.tfm: source/%.mf
	cd $(tfmdir) && MFINPUTS=$(abspath source) $(MF) '\mode=nullmode; input $*'

$(pfbfiles): $(pfbdir)/%.pfb: source/%.mf
	cd $(pfbdir) && $(MFTOPT1) --rounding 0.25 --encoding=$(abspath $(filter %.enc,$^)) --ffscript=$(abspath scripts/process.pe) $(abspath $<)

ifneq ($(MAKECMDGOALS),clean)
-include $(depfiles)
endif

# rules for building the mapfile

$(mapfile):
	for i in $(names); do \
	  n=$$(echo $$i | tr [:upper:] [:lower:]); \
	  for weight in $(weights); do \
	    echo "$(font)$$i-$${weight} $(font)$$i-$${weight} <$(font)$$i-$${weight}.pfb" >> $@; \
	  done; \
	done

# rules for building the LaTeX package

.PHONY: latex
latex: latex/$(pkg).sty

latex/$(pkg).sty: latex/$(pkg).ins latex/$(pkg).dtx
	cd latex && $(PDFLATEX) $(pkg).ins

# rules for rebuilding the documentation

.PHONY: doc
doc: latex/$(pkg).pdf

latex/$(pkg).pdf: latex/$(pkg).dtx
	cd latex && $(PDFLATEX) $(pkg).dtx && \
	(while grep -s 'Rerun to get' $(pkg).log; do \
	  $(PDFLATEX) $(pkg).dtx; \
	done)

# rules for building a TDS zip file

.PHONY: tds
tds: $(pkg).tds.zip

$(pkg).tds.zip: $(tfmfiles) $(pfbfiles) $(mapfile) $(encfiles) $(srcfiles) $(addprefix latex/,$(pkg).ins $(pkg).dtx $(pkg).sty $(pkg).pdf) FONTLOG.txt OFL.txt
	$(MAKE) install TEXMFDIR:=tds.tmp
	(cd tds.tmp && $(ZIP) -r - *) > $@
	$(RM) tds.tmp

# rules for building a tarball for CTAN

.PHONY: ctan
ctan: $(pkg).tar.gz

$(pkg).tar.gz: $(pkg).tds.zip README.ctan $(tfmfiles) $(pfbfiles) $(mapfile) $(encfiles) $(srcfiles) $(addprefix latex/,$(pkg).ins $(pkg).dtx $(pkg).pdf) FONTLOG.txt OFL.txt
	$(TAR) -cz -s '/README\.ctan/README/' -s '/latex.//' $^ > $@

# rules for building proofs and charts

.PHONY: test
test: proofs charts

.PHONY: proofs
proofs: $(prooffiles)

$(gffiles): $(testdir)/%.2602gf: source/%.mf
	cd $(testdir) && MFINPUTS=$(abspath source) $(MF) '\mode=proofmofe; nodisplays; input $*'

$(prooffiles): $(testdir)/%.dvi: $(testdir)/%.2602gf
	cd $(testdir) && $(GFTODVI) $*

.PHONY: charts
charts: $(chartfiles)

$(chartfiles): $(testdir)/%.pdf: $(pfbdir)/%.pfb
	$(T1TESTPAGE) $< | $(PSTOPDF) - $@

# rule for validating the generated Postscript fonts

.PHONY: check
check:
	@echo "Validating fonts..."
	@for file in $(pfbfiles); do \
	  if [ -e $$file ]; then \
	    $(FONTFORGE) -script scripts/validate.pe $$file 2> /dev/null; \
	  fi; \
	done

# rules for (un)installing everything

.PHONY: install
install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDATA) $(pfbfiles) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDATA) $(tfmfiles) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(INSTALLDATA) $(srcfiles) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(INSTALLDATA) $(mapfile) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)
	$(INSTALLDATA) $(encfiles) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDATA) latex/$(pkg).sty $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/doc/fonts/$(pkg)
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDATA) latex/$(pkg).pdf $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/source/latex/$(pkg)
	$(INSTALLDATA) latex/$(pkg).ins latex/$(pkg).dtx $(TEXMFDIR)/source/latex/$(pkg)

.PHONY: uninstall
uninstall:
	$(RM) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)
	$(RM) $(TEXMFDIR)/tex/latex/$(pkg)
	$(RM) $(TEXMFDIR)/doc/latex/$(pkg)
	$(RM) $(TEXMFDIR)/doc/fonts/$(pkg)
	$(RM) $(TEXMFDIR)/source/latex/$(pkg)

# rule for cleaning the source tree

.PHONY: clean
clean:
	$(RM) $(outdirs)
	$(RM) $(depfiles)
	$(RM) mapfile latex/$(pkg).sty $(pkg).tds.zip $(pkg).tar.gz
	$(RM) $(tempfiles)

# delete files on error

.DELETE_ON_ERROR:
