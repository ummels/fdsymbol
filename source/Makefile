FONTFORGE = fontforge
MF = mf
MFTRACE = mftrace
INSTALL = install
INSTALLDATA = install -m 644

font = FdSymbol
NAMES = A B C D E F
WEIGHTS = Book Regular Medium Bold
texmfdir = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

MFFILES = accents.mf arrows.mf base.mf delims.mf operators.mf ordinary.mf relations.mf
TFMFILES = $(foreach i,$(NAMES),$(patsubst %,$(font)$(i)-%.tfm,$(WEIGHTS)))
PFAFILES = $(foreach i,$(NAMES),$(patsubst %,$(font)$(i)-%.pfa,$(WEIGHTS)))
LOGFILES = $(foreach i,$(NAMES),$(patsubst %,$(font)$(i)-%.log,$(WEIGHTS)))
PFBFILES = $(patsubst %,$(font)-%.pfb,$(WEIGHTS))

getName = $(shell (echo $(1) | sed 's/$(font)\([A-Z]\).*/\1/'))
getname = $(shell (echo $(call getName,$(1)) | tr "[:upper:]" "[:lower:]"))

.PHONY: all metrics type1 install clean

all: metrics type1

metrics: $(TFMFILES)

type1: $(PFBFILES)

$(PFBFILES): $(font)-%.pfb: $(foreach i,$(NAMES),$(font)$(i)-%.pfa)
	$(FONTFORGE) merge-fonts.pe $*

install: all
	$(INSTALL) -d $(texmfdir)/fonts/tfm/public/$(font)
	$(INSTALLDATA) $(TFMFILES) $(texmfdir)/fonts/tfm/public/$(font)
	$(INSTALL) -d $(texmfdir)/fonts/type1/public/$(font)
	$(INSTALLDATA) $(PFBFILES) $(texmfdir)/fonts/type1/public/$(font)

clean:
	rm -f $(LOGFILES) $(PFAFILES) $(TFMFILES) $(PFBFILES)

.SECONDEXPANSION:

$(TFMFILES): %.tfm: %.mf $(font)$$(call getName,$$*).mf $(MFFILES)
	$(MF) '\mode=nullmode; input $*'

$(PFAFILES): %.pfa: ../enc/fdsymbol-$$(call getname,$$*).enc %.tfm
	$(MFTRACE) --simplify -e $< $*
