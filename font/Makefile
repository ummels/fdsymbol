FONTFORGE = fontforge
MF = mf
MFTRACE = mftrace
INSTALL = install
INSTALLDATA = install -m 644

FONT = FdSymbol
NAMES = A B C D E F
WEIGHTS = Book Regular Medium Bold
TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

MFFILES = accents.mf arrows.mf base.mf delims.mf geometric.mf operators.mf relations.mf
TFMFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.tfm,$(WEIGHTS)))
PFAFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.pfa,$(WEIGHTS)))
LOGFILES = $(foreach i,$(NAMES),$(patsubst %,$(FONT)$(i)-%.log,$(WEIGHTS)))
PFBFILES = $(patsubst %,$(FONT)-%.pfb,$(WEIGHTS))

getName = $(shell (echo $(1) | sed 's/$(FONT)\([A-Z]\).*/\1/'))
getname = $(shell (echo $(call getName,$(1)) | tr "[:upper:]" "[:lower:]"))

.PHONY: all metrics type1 install clean

all: metrics type1

metrics: $(TFMFILES)

type1: $(PFBFILES)

$(PFBFILES): $(FONT)-%.pfb: $(foreach i,$(NAMES),$(FONT)$(i)-%.pfa)
	$(FONTFORGE) merge-fonts.pe $*

install: all
	$(INSTALL) -d $(TEXMFDIR)/fonts/tfm/public/$(FONT)
	$(INSTALLDATA) $(TFMFILES) $(TEXMFDIR)/fonts/tfm/public/$(FONT)
	$(INSTALL) -d $(TEXMFDIR)/fonts/type1/public/$(FONT)
	$(INSTALLDATA) $(PFBFILES) $(TEXMFDIR)/fonts/type1/public/$(FONT)

clean:
	$(RM) $(LOGFILES) $(PFAFILES) $(TFMFILES) $(PFBFILES)

.SECONDEXPANSION:

$(TFMFILES): %.tfm: %.mf $(FONT)$$(call getName,$$*).mf $(MFFILES)
	$(MF) '\mode=nullmode; input $*'

$(PFAFILES): %.pfa: ../enc/fdsymbol-$$(call getname,$$*).enc %.tfm
	$(MFTRACE) --simplify -e $< $*
