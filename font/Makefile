FONTFORGE := fontforge
MF := mf
MFTRACE := mftrace
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

tfmfiles := $(foreach i,$(names),$(weights:%=$(font)$(i)-%.tfm))
pfafiles := $(tfmfiles:%.tfm=%.pfa)
makfiles := $(names:%=$(font)%.mak)
pfbfiles := $(weights:%=$(font)-%.pfb)
gffiles := $(tfmfiles:%.tfm=%.2602gf)
dvifiles := $(tfmfiles:%.tfm=%.dvi)
logfiles := $(tfmfiles:%.tfm=%.log)
charts := $(pfbfiles:%.pfb=%.pdf)

getenc = $(shell (echo $(1) | sed 's/$(font)/$(pkg)-/' | tr [:upper:] [:lower:]))

.PHONY: all metrics type1 install uninstall clean

all: metrics type1

metrics: $(tfmfiles)

type1: $(pfbfiles)

$(makfiles): %.mak: %.mf
	@echo "$(patsubst %,$*-%.tfm,$(weights)): $*.mf $(sort $(shell awk -f finddeps.awk $*.mf))" > $@
	@echo "$(patsubst %,$*-%.pfa,$(weights)): ../dvips/$(call getenc,$*).enc" >> $@

$(tfmfiles): %.tfm: %.mf
	$(MF) '\mode=nullmode; input $*'

$(pfafiles): %.pfa: %.tfm
	$(MFTRACE) --simplify -e $(filter %.enc,$^) $*

-include $(makfiles)

$(pfbfiles): $(font)-%.pfb: $(foreach i,$(names),$(font)$(i)-%.pfa)
	$(FONTFORGE) merge-fonts.pe $*

proofs: $(dvifiles)

$(gffiles): %.2602gf: %.mf
	$(MF) '\mode=proofmofe; nodisplays; input $*'

$(dvifiles): %.dvi: %.2602gf
	$(GFTODVI) $<

charts: $(charts)

$(charts): %.pdf: %.pfb
	$(FONTCHART) $< | $(PSTOPDF) - $@

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDATA) $(tfmfiles) $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDATA) $(pfbfiles) $(TEXMFDIR)/fonts/type1/public/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/source/public/$(pkg)
	$(INSTALLDATA) *.mf $(TEXMFDIR)/fonts/source/public/$(pkg)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/tfm/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/type1/public/$(pkg)
	rm -rf $(TEXMFDIR)/fonts/source/public/$(pkg)

clean:
	rm -f $(makfiles)
	rm -f $(pfafiles)
	rm -f $(tfmfiles)
	rm -f $(pfbfiles)
	rm -f $(gffiles)
	rm -f $(dvifiles)
	rm -f $(charts)
	rm -f $(logfiles)
