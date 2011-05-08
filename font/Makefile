FONTFORGE = fontforge
MF = mf
MFTRACE = mftrace
INSTALL = install
INSTALLDIR = $(INSTALL) -d
INSTALLDATA = $(INSTALL) -m 644

TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

pkg := fdsymbol
font := FdSymbol
names := A B C D E F
weights := Book Regular Medium Bold

tfmfiles := $(foreach i,$(names),$(patsubst %,$(font)$(i)-%.tfm,$(weights)))
pfafiles := $(foreach i,$(names),$(patsubst %,$(font)$(i)-%.pfa,$(weights)))
logfiles := $(foreach i,$(names),$(patsubst %,$(font)$(i)-%.log,$(weights)))
makfiles := $(patsubst %,$(font)%.mak,$(names))
pfbfiles := $(patsubst %,$(font)-%.pfb,$(weights))

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

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/tfm/public/$(font)
	$(INSTALLDATA) $(tfmfiles) $(TEXMFDIR)/fonts/tfm/public/$(font)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/type1/public/$(font)
	$(INSTALLDATA) $(pfbfiles) $(TEXMFDIR)/fonts/type1/public/$(font)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/source/public/$(font)
	$(INSTALLDATA) *.mf $(TEXMFDIR)/fonts/source/public/$(font)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/tfm/public/$(font)
	rm -rf $(TEXMFDIR)/fonts/type1/public/$(font)

clean:
	rm -f $(makfiles) $(pfafiles) $(tfmfiles) $(pfbfiles) $(logfiles)
