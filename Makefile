SHELL := /bin/sh
FONTFORGE := fontforge
MF := mf-nowin -progname=mf -interaction nonstopmode -halt-on-error
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
T1TESTPAGE := t1testpage
PSTOPDF := pstopdf
PYTHON := python2.7
LATEX := latex -interaction nonstopmode -halt-on-error
PDFLATEX := pdflatex -interaction nonstopmode -halt-on-error
LUALATEX := lualatex -interaction nonstopmode -halt-on-error
DVIPS := dvips
RM := rm -rf
TAR := gtar --owner=root --group=root --mode='a+r'
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

tempdir := temp
sourcedir := source
scriptdir := scripts
fontdir := fonts
encdir := dvips
testdir := test
latexdir := latex
outdirs := $(fontdir) $(testdir)

# Need DVIPSHEADERS for older versions of dvips
texvars := TEXINPUTS=$(latexdir): ENCFONTS=$(encdir): TFMFONTS=$(fontdir): T1FONTS=$(fontdir): DVIPSHEADERS=$(fontdir):
latex := $(texvars) $(LATEX)
pdflatex := $(texvars) $(PDFLATEX)
lualatex := $(texvars) $(LUALATEX)
dvips := $(texvars) $(DVIPS)

# $(call lc,text)
lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

depfiles := $(names:%=$(font)%.dep)
encfiles := $(foreach i,$(names),$(encdir)/$(pkg)-$(call lc,$i).enc)
mapfile := $(encdir)/$(pkg).map
fonts := $(foreach i,$(names),$(weights:%=$(font)$(i)-%))
tfmfiles := $(fonts:%=$(fontdir)/%.tfm)
sfdfiles := $(fonts:%=$(fontdir)/%.sfd)
pfbfiles := $(fonts:%=$(fontdir)/%.pfb)
otffiles := $(weights:%=$(fontdir)/$(font)-%.otf)
logfiles := $(fonts:%=$(fontdir)/%.log)
gffiles := $(fonts:%=$(testdir)/%.2602gf)
prooffiles := $(fonts:%=$(testdir)/%.dvi)
chartfiles := $(fonts:%=$(testdir)/%.pdf)
srcfiles := $(fonts:%=$(sourcedir)/%.mf) $(names:%=$(sourcedir)/$(font)%.mf) $(addprefix $(sourcedir)/,fdbase.mf fdaccents.mf fdarrows.mf fddelims.mf fdgeometric.mf fdoperators.mf fdrelations.mf fdturnstile.mf)
latexfiles := $(addprefix $(latexdir)/,$(pkg).ins $(pkg).dtx $(pkg).sty $(pkg).pdf)
tempfiles := $(addprefix $(latexdir)/,$(pkg).aux $(pkg).log $(pkg).out $(pkg).toc $(pkg).hd)

# create output directories

ifeq (,$(findstring clean,$(MAKECMDGOALS)))
create-dirs := $(shell $(MKDIR) $(outdirs))
endif

# macro for generating font-specific rules

# $(call fontrule,weight)
define fontrule
.PHONY: $1
$1: $(fontdir)/$(font)-$1.otf

$(fontdir)/$(font)-$1.otf: $(foreach i,$(names),$(fontdir)/$(font)$i-$1.sfd)

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

$(depfiles): %.dep: $(sourcedir)/%.mf
	@echo "$(weights:%=$(fontdir)/$*-%.tfm) $(weights:%=$(testdir)/$*-%.2602gf) $@: $< $$($(PYTHON) $(scriptdir)/finddeps.py $<)" > $@
	@echo "$(weights:%=$(fontdir)/$*-%.sfd): | $< $$($(PYTHON) $(scriptdir)/finddeps.py $<)" > $@
	@echo "$(weights:%=$(fontdir)/$*-%.sfd): | $(encdir)/$$(echo $* | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]).enc" >> $@

# rules for building Postscript fonts and TeX metrics

.PHONY: ffsources
ffsources: $(sfdfiles)

.PHONY: texfonts
texfonts: $(pfbfiles) $(tfmfiles)

$(foreach weight,$(weights),$(eval $(call fontrule,$(weight))))

$(sfdfiles): $(fontdir)/%.sfd: | $(sourcedir)/%.mf
	$(MKDIR) $(tempdir)
	cd $(tempdir) && $(MFTOPT1) --encoding=$(abspath $(filter %.enc,$|)) --ffscript=$(abspath $(scriptdir)/process.pe) $(abspath $<) && cp $*.sfd $(abspath $@)

$(pfbfiles): $(fontdir)/%.pfb: $(fontdir)/%.sfd
	$(FONTFORGE) -lang=ff -c 'Open("$<"); Generate("$@", "", 0); Quit(0)'

$(tfmfiles): $(fontdir)/%.tfm: source/%.mf
	cd $(fontdir) && MFINPUTS=$(abspath source) $(MF) '\mode=nullmode; input $*'

ifneq ($(MAKECMDGOALS),clean)
-include $(depfiles)
endif

# rules for building OpenType fonts

.PHONY: opentype
opentype: $(otffiles)

$(otffiles): $(sourcedir)/features.fea
	$(PYTHON) $(scriptdir)/makeotf.py -f $< $(filter %.sfd,$^) $@

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
latex: $(latexdir)/$(pkg).sty $(latexdir)/test-$(pkg).tex

$(latexdir)/$(pkg).sty $(latexdir)/test-$(pkg).tex: $(latexdir)/$(pkg).ins $(latexdir)/$(pkg).dtx
	$(LATEX) -output-directory $(latexdir) $<

# rules for testing the build

.PHONY: test
test: all
	@echo "Testing pdflatex..."
	$(pdflatex) -output-directory $(testdir) "\pdfmapfile{$(mapfile)}\input{test-$(pkg)}"
	@echo ""
	@echo "Testing latex+dvips..."
	$(latex) -output-directory $(testdir) "\input{test-$(pkg)}"
	$(dvips) -u $(mapfile) $(testdir)/test-$(pkg).dvi -o $(testdir)/test-$(pkg).ps
	@echo ""
	@echo "Testing lualatex..."
	$(lualatex) -output-directory $(testdir) -jobname test-$(pkg)-luatex "\directlua{pdf.mapfile('$(mapfile)')}\input{test-$(pkg)}"

# rules for rebuilding the documentation

.PHONY: doc
doc: $(latexdir)/$(pkg).pdf

$(latexdir)/$(pkg).pdf: $(latexdir)/$(pkg).dtx $(mapfile)
	$(texvars) $(PDFLATEX) -output-directory $(latexdir) "\pdfmapfile{+$(mapfile)}\input{$(pkg).dtx}" && \
	(while grep -s 'Rerun to get' $(latexdir)/$(pkg).log; do \
	  $(texvars) $(PDFLATEX) -output-directory $(latexdir) "\pdfmapfile{+$(mapfile)}\input{$(pkg).dtx}"; \
	done)

# rules for building a TDS zip file

.PHONY: tds
tds: $(pkg).tds.zip

$(pkg).tds.zip: $(pfbfiles) $(otffiles) $(tfmfiles) $(mapfile) $(encfiles) $(srcfiles) $(latexfiles) FONTLOG.txt OFL.txt
	$(MAKE) install TEXMFDIR:=tds.tmp
	(cd tds.tmp && $(ZIP) -r - *) > $@
	$(RM) tds.tmp

# rules for building a tarball for CTAN

.PHONY: dist
dist: $(pkg).tar.gz

$(pkg).tar.gz: $(pkg).tds.zip README.ctan $(pfbfiles) $(otffiles) $(tfmfiles) $(mapfile) $(encfiles) $(srcfiles) $(latexdir)/$(pkg).ins $(latexdir)/$(pkg).dtx $(latexdir)/$(pkg).pdf FONTLOG.txt OFL.txt
	$(TAR) -c - z --transform 's,^,$(pkg)/,g' --transform 's,README\.ctan,README,' --transform 's,$(latexdir)/,,' --transform 's,$(sourcedir)/,source/,' --transform 's,$(fontdir)/\(.*\.otf\),\1,' --transform 's,$(fontdir)/\(.*\.tfm\),tfm/\1,' --transform 's,$(fontdir)/\(.*\.pfb\),type1/\1,' --transform 's,$(encdir)/,dvips/,' --transform 's,$(pkg)/$(pkg).tds.zip,$(pkg).tds.zip,' $^ > $@

# rules for building proofs and charts

.PHONY: proofs
proofs: $(prooffiles)

$(gffiles): $(testdir)/%.2602gf: $(sourcedir)/%.mf
	cd $(testdir) && MFINPUTS=$(abspath source) $(MF) '\mode=proofmofe; nodisplays; input $*'

$(prooffiles): $(testdir)/%.dvi: $(testdir)/%.2602gf
	cd $(testdir) && $(GFTODVI) $*

.PHONY: charts
charts: $(chartfiles)

$(chartfiles): $(testdir)/%.pdf: $(fontdir)/%.pfb
	$(T1TESTPAGE) $< | $(PSTOPDF) -i -o $@

# rule for validating the generated Postscript fonts

.PHONY: check
check: $(sfdfiles)
	@echo "Validating fonts..."
	@for file in $(sfdfiles); do \
	  if [ -e $$file ]; then \
	    $(FONTFORGE) -script $(scriptdir)/validate.pe $$file 2> /dev/null; \
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
	$(INSTALLDATA) $(latexdir)/$(pkg).sty $(TEXMFDIR)/tex/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/doc/fonts/$(pkg)
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDATA) $(latexdir)/$(pkg).pdf $(TEXMFDIR)/doc/latex/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/source/latex/$(pkg)
	$(INSTALLDATA) $(latexdir)/$(pkg).ins $(latexdir)/$(pkg).dtx $(TEXMFDIR)/source/latex/$(pkg)

.PHONY: uninstall
uninstall:
	$(RM) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/opentype/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)
	$(RM) $(TEXMFDIR)/tex/latex/$(pkg)
	$(RM) $(TEXMFDIR)/doc/latex/$(pkg)
	$(RM) $(TEXMFDIR)/doc/fonts/$(pkg)
	$(RM) $(TEXMFDIR)/source/latex/$(pkg)

# rules for cleaning the source tree

.PHONY: clean
clean:
	$(RM) $(otffiles) $(pfbfiles) $(tfmfiles) $(logfiles)
	$(RM) $(tempdir) $(testdir)
	$(RM) $(depfiles)
	$(RM) $(mapfile) $(latexdir)/$(pkg).sty $(latexdir)/test-$(pkg).tex $(pkg).tds.zip $(pkg).tar.gz
	$(RM) $(tempfiles)

.PHONY: maintainer-clean
maintainer-clean: clean
	$(RM) $(fontdir)

# delete files on error

.DELETE_ON_ERROR:
