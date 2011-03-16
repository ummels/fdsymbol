NAMES = A B C D E F
WEIGHTS = Book Regular Medium Bold
MFFILES = accents.mf arrows.mf base.mf delims.mf operators.mf ordinary.mf relations.mf
TFMFILES = $(foreach i,$(NAMES),$(patsubst %,FdSymbol$(i)-%.tfm,$(WEIGHTS)))
PFAFILES = $(foreach i,$(NAMES),$(patsubst %,FdSymbol$(i)-%.pfa,$(WEIGHTS)))
PFBFILES = $(patsubst %,FdSymbol-%.pfb,$(WEIGHTS))

getName = $(shell (echo $(1) | sed 's/FdSymbol\([A-Z]\).*/\1/'))
getname = $(shell (echo $(call getName,$(1)) | tr "[:upper:]" "[:lower:]"))

all: $(PFBFILES) $(TFMFILES)

.PHONY: clean

clean:
	rm -f *.log *.tfm *.pfa *.pfb

$(PFBFILES): FdSymbol-%.pfb: $(foreach i,$(NAMES),FdSymbol$(i)-%.pfa)
	fontforge merge-fonts.pe $*

.SECONDEXPANSION:

$(TFMFILES): %.tfm: %.mf FdSymbol$$(call getName,$$*).mf $(MFFILES)
	mf '\mode=nullmode; input $*'

$(PFAFILES): %.pfa: ../enc/fdsymbol-$$(call getname,$$*).enc %.tfm
	mftrace --simplify -e $< $*
