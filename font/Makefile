FONTFORGE := fontforge
MF := mf
MFTOPT1 := mf2pt1
GFTODVI := gftodvi
FONTCHART := t1testpage
PSTOPDF := ps2pdf
INSTALL := install
INSTALLDIR := $(INSTALL) -d
INSTALLDATA := $(INSTALL) -m 644
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

pkg := fdsymbol
font := FdSymbol
names := A B C D E F
weights := Book Regular Medium Bold

fonts := $(weights:%=$(font)-%.pfb)
tfmfiles := $(foreach i,$(names),$(weights:%=$(font)$(i)-%.tfm))
pfbfiles := $(tfmfiles:%.tfm=%.pfb)
charts := $(fonts:%.pfb=%.pdf)
gffiles := $(tfmfiles:%.tfm=%.2602gf)
dvifiles := $(tfmfiles:%.tfm=%.dvi)
makfiles := $(names:%=$(font)%.mak)
logfiles := $(tfmfiles:%.tfm=%.log)

getenc = $(shell (echo $(1) | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]))

.PHONY: all metrics type1 validate install uninstall clean

all: metrics type1

metrics: $(tfmfiles)

type1: $(fonts)

$(makfiles): %.mak: %.mf
	@echo "$(patsubst %,$*-%.tfm,$(weights)) $(patsubst %,$*-%.pfb,$(weights)): $*.mf $(sort $(shell awk -f finddeps.awk $*.mf))" > $@
	@echo "$(patsubst %,$*-%.pfb,$(weights)): ../dvips/$(call getenc,$*).enc" >> $@

$(tfmfiles): %.tfm: %.mf
	$(MF) '\mode=nullmode; input $*'

$(pfbfiles): %.pfb: %.mf
	$(MFTOPT1) --rounding 0.25 --encoding=$(filter %.enc,$^) --ffscript=process.pe $*.mf

-include $(makfiles)

$(fonts): $(font)-%.pfb: $(foreach i,$(names),$(font)$(i)-%.pfb)
	@echo "Generating $@..."
	$(FONTFORGE) merge.pe $*

proofs: $(dvifiles)

$(gffiles): %.2602gf: %.mf
	$(MF) '\mode=proofmofe; nodisplays; input $*'

$(dvifiles): %.dvi: %.2602gf
	$(GFTODVI) $<

charts: $(charts)

$(charts): %.pdf: %.pfb
	$(FONTCHART) $< | $(PSTOPDF) - $@

validate: $(pfbfiles)
	@echo "Validating fonts..."
	@for file in $(pfbfiles); do $(FONTFORGE) -script validate.pe $$file 2> /dev/null; done

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDATA) $(tfmfiles) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDATA) $(fonts) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(INSTALLDATA) *.mf $(TEXMFDIR)/fonts/source/public/$(pkg)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/type1/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/source/public/$(pkg)

clean:
	rm -f $(makfiles)
	rm -f $(pfbfiles)
	rm -f $(tfmfiles)
	rm -f $(fonts)
	rm -f $(gffiles)
	rm -f $(dvifiles)
	rm -f $(charts)
	rm -f $(logfiles)
