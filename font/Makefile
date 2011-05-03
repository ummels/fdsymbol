FONTFORGE = fontforge
MF = mf
MFTRACE = mftrace
INSTALL = install
INSTALLDATA = install -m 644

FONT = FdSymbol
NAMES = A B C D E F
WEIGHTS = Book Regular Medium Bold
TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME'))

TFMFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.tfm,$(WEIGHTS)))
PFAFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.pfa,$(WEIGHTS)))
LOGFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.log,$(WEIGHTS)))
MKFILES = $(patsubst %,$(FONT)%.mak,$(NAMES))
PFBFILES = $(patsubst %,$(FONT)-%.pfb,$(WEIGHTS))

tolower = $(shell (echo $(1) | tr "[:upper:]" "[:lower:]"))

.PHONY: all metrics type1 install uninstall clean

all: metrics type1

metrics: $(TFMFILES)

type1: $(PFBFILES)

$(MKFILES): %.mak: %.mf
	@echo "$(patsubst %,$*-%.tfm,$(WEIGHTS)): $*.mf $(sort $(shell awk -f finddeps.awk $*.mf))" > $@
	@echo "$(patsubst %,$*-%.pfa,$(WEIGHTS)): ../enc/$(call tolower,$*).enc" >> $@

-include $(MKFILES)

$(TFMFILES): %.tfm: %.mf
	$(MF) '\mode=nullmode; input $*'

$(PFAFILES): %.pfa: %.tfm
	$(MFTRACE) --simplify -e $(filter %.enc,$^) $*

$(PFBFILES): $(FONT)-%.pfb: $(foreach i,$(NAMES),$(FONT)$(i)-%.pfa)
	$(FONTFORGE) merge-fonts.pe $*

install: all
	$(INSTALL) -d $(TEXMFDIR)/fonts/tfm/public/$(FONT)
	$(INSTALLDATA) $(TFMFILES) $(TEXMFDIR)/fonts/tfm/public/$(FONT)
	$(INSTALL) -d $(TEXMFDIR)/fonts/type1/public/$(FONT)
	$(INSTALLDATA) $(PFBFILES) $(TEXMFDIR)/fonts/type1/public/$(FONT)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/tfm/public/$(FONT)
	rm -rf $(TEXMFDIR)/fonts/type1/public/$(FONT)

clean:
	rm -f $(MKFILES) $(PFAFILES) $(TFMFILES) $(PFBFILES) $(LOGFILES)
