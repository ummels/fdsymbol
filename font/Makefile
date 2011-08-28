FONTFORGE := fontforge
MF := mf
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
PDFTEX := pdftex
PYTHON := python
RM := rm -rf
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

tfmfiles := $(foreach i,$(names),$(weights:%=$(font)$(i)-%.tfm))
pfbfiles := $(tfmfiles:%.tfm=%.pfb)
pt1files := $(weights:%=$(font)-%.pfb)
gffiles := $(tfmfiles:%.tfm=%.2602gf)
prooffiles := $(tfmfiles:%.tfm=%.dvi)
chartfiles := $(tfmfiles:%.tfm=%.pdf)
depfiles := $(names:%=$(font)%.dep)
logfiles := $(tfmfiles:%.tfm=%.log)

.PHONY: all metrics type1 validate install uninstall clean

all: metrics type1

metrics: $(tfmfiles)

type1: $(pt1files)

$(depfiles): %.dep: %.mf
	@echo "$(weights:%=$*-%.tfm) $(weights:%=$*-%.pfb) $(weights:%=$*-%.2602gf): $*.mf $$($(PYTHON) finddeps.py $*.mf)" > $@
	@echo "$(weights:%=$*-%.pfb): ../dvips/$$(echo $* | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]).enc" >> $@

$(tfmfiles): %.tfm: %.mf
	$(MF) '\mode=nullmode; input $*'

$(pfbfiles): %.pfb: %.mf
	$(MFTOPT1) --rounding 0.25 --encoding=$(filter %.enc,$^) --ffscript=process.pe $*.mf

ifneq ($(MAKECMDGOALS),clean)
-include $(depfiles)
endif

$(pt1files): $(font)-%.pfb: $(foreach i,$(names),$(font)$(i)-%.pfb)
	@echo "Generating $@..."
	$(FONTFORGE) merge.pe $*

proofs: $(prooffiles)

$(gffiles): %.2602gf: %.mf
	$(MF) '\mode=proofmofe; nodisplays; input $*'

$(prooffiles): %.dvi: %.2602gf
	$(GFTODVI) $<

charts: $(chartfiles)

$(chartfiles): %.pdf: %.pfb %.tfm
	echo $* | $(PDFTEX) --jobname $* "\\pdfmapline{=$* FdSymbol <$*.pfb}\\input fontchart.tex"

validate: $(pfbfiles)
	@echo "Validating fonts..."
	@for file in $(pfbfiles); do $(FONTFORGE) -script validate.pe $$file 2> /dev/null; done

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDATA) $(tfmfiles) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDATA) $(pt1files) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(INSTALLDATA) *.mf $(TEXMFDIR)/fonts/source/public/$(pkg)

uninstall:
	$(RM) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/source/public/$(pkg)

clean:
	$(RM) $(depfiles)
	$(RM) $(pfbfiles)
	$(RM) $(tfmfiles)
	$(RM) $(pt1files)
	$(RM) $(gffiles)
	$(RM) $(prooffiles)
	$(RM) $(chartfiles)
	$(RM) $(logfiles)
