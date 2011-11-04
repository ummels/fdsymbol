SHELL := /bin/sh
FONTFORGE := fontforge
MF := mf -interaction nonstopmode -halt-on-error
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
T1TESTPAGE := t1testpage
PSTOPDF := ps2pdf
PYTHON := python2.7
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

fontdir := fonts
testdir := test
outdirs := $(fontdir) $(testdir)

# $(call lc,text)
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

depfiles := $(names:%=$(font)%.dep)
encfiles := $(foreach i,$(names),dvips/$(pkg)-$(call lc,$i).enc)
mapfile := dvips/$(pkg).map
fonts := $(foreach i,$(names),$(weights:%=$(font)$(i)-%))
tfmfiles := $(fonts:%=$(fontdir)/%.tfm)
pfbfiles := $(fonts:%=$(fontdir)/%.pfb)
otffiles := $(weights:%=$(fontdir)/$(font)-%.otf)
gffiles := $(fonts:%=$(testdir)/%.2602gf)
prooffiles := $(fonts:%=$(testdir)/%.dvi)
chartfiles := $(fonts:%=$(testdir)/%.pdf)
srcfiles := $(fonts:%=source/%.mf) $(names:%=source/$(font)%.mf) $(addprefix source/,fdbase.mf fdaccents.mf fdarrows.mf fddelims.mf fdgeometric.mf fdoperators.mf fdrelations.mf fdturnstile.mf)
tempfiles := $(addprefix latex/,$(pkg).aux $(pkg).log $(pkg).out $(pkg).toc $(pkg).hd)

# create output directories

ifeq (,$(findstring clean,$(MAKECMDGOALS)))
create-dirs := $(shell $(MKDIR) $(outdirs))
endif

# macro for generating font-specific rules

# $(call fontrule,weight)
define fontrule
.PHONY: $1
$1: $(fontdir)/$(font)-$1.otf

$(fontdir)/$(font)-$1.otf: $(foreach i,$(names),$(fontdir)/$(font)$i-$1.pfb)

.PHONY: $1-test
$1-test: $1-proofs $1-charts

.PHONY: $1-proofs
$1-proofs: $(filter %-$1.dvi,$(prooffiles))

.PHONY: $1-charts
$1-charts: $(filter %-$1.pdf,$(chartfiles))
endef

# default rule

.PHONY: all
all: texfonts opentype latex $(mapfile)

# rules for building Makefiles with additional dependencies

$(depfiles): %.dep: source/%.mf scripts/finddeps.py
	@echo "$(weights:%=$(fontdir)/$*-%.tfm) $(weights:%=$(fontdir)/$*-%.pfb) $(weights:%=$(testdir)/$*-%.2602gf) $@: $< $$($(PYTHON) scripts/finddeps.py $<)" > $@
	@echo "$(weights:%=$(fontdir)/$*-%.pfb): dvips/$$(echo $* | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]).enc" >> $@

# rules for building Postscript fonts and TeX metrics

.PHONY: texfonts
texfonts: $(pfbfiles) $(tfmfiles)

$(foreach weight,$(weights),$(eval $(call fontrule,$(weight))))

$(pfbfiles): $(fontdir)/%.pfb: source/%.mf scripts/process.pe
	cd $(fontdir) && $(MFTOPT1) --rounding 0.25 --encoding=$(abspath $(filter %.enc,$^)) --ffscript=$(abspath scripts/process.pe) $(abspath $<)

$(tfmfiles): $(fontdir)/%.tfm: source/%.mf
	cd $(fontdir) && MFINPUTS=$(abspath source) $(MF) '\mode=nullmode; input $*'

ifneq ($(MAKECMDGOALS),clean)
-include $(depfiles)
endif

# rules for building OpenType fonts

.PHONY: opentype
opentype: $(otffiles)

$(otffiles): source/features.fea scripts/makeotf.py
	$(PYTHON) scripts/makeotf.py -f $< $(filter %.pfb,$^) $@

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

.PHONY: dist
dist: $(pkg).tar.gz

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

$(chartfiles): $(testdir)/%.pdf: $(fontdir)/%.pfb
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
	$(INSTALLDIR) $(TEXMFDIR)/fonts/opentype/public/$(pkg)
	$(INSTALLDATA) $(otffiles) $(TEXMFDIR)/fonts/opentype/public/$(pkg)
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
	$(RM) $(TEXMFDIR)/fonts/opentype/public/$(pkg)
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
	$(RM) $(mapfile) latex/$(pkg).sty $(pkg).tds.zip $(pkg).tar.gz
	$(RM) $(tempfiles)

# delete files on error

.DELETE_ON_ERROR:
