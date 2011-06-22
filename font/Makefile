FONTFORGE := fontforge
MF := mf
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
PDFTEX := pdftex
INSTALL := install
INSTALLDIR := $(INSTALL) -d
INSTALLDATA := $(INSTALL) -m 644
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

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
makefiles := $(names:%=$(font)%.mak)
logfiles := $(tfmfiles:%.tfm=%.log)

getenc = $(shell (echo $(1) | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]))

.PHONY: all metrics type1 validate install uninstall clean

all: metrics type1

metrics: $(tfmfiles)

type1: $(pt1files)

$(makefiles): %.mak: %.mf
	@echo "$(patsubst %,$*-%.tfm,$(weights)) $(patsubst %,$*-%.pfb,$(weights)) $(patsubst %,$*-%.2602gf,$(weights)): $*.mf $(sort $(shell awk -f finddeps.awk $*.mf))" > $@
	@echo "$(patsubst %,$*-%.pfb,$(weights)): ../dvips/$(call getenc,$*).enc" >> $@

$(tfmfiles): %.tfm: %.mf
	$(MF) '\mode=nullmode; input $*'

$(pfbfiles): %.pfb: %.mf
	$(MFTOPT1) --rounding 0.25 --encoding=$(filter %.enc,$^) --ffscript=process.pe $*.mf

-include $(makefiles)

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
	echo $* | $(PDFTEX) --jobname $* "\pdfmapline{=$* FdSymbol <$*.pfb}\input fontchart.tex"

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
	rm -rf $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/type1/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/source/public/$(pkg)

clean:
	rm -f $(makefiles)
	rm -f $(pfbfiles)
	rm -f $(tfmfiles)
	rm -f $(pt1files)
	rm -f $(gffiles)
	rm -f $(prooffiles)
	rm -f $(chartfiles)
	rm -f $(logfiles)
