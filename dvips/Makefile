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

.PHONY: all install uninstall clean

all: $(pkg).map

$(pkg).map:
	for name in $(names); do \
	  n=$$(echo $${name} | tr [:upper:] [:lower:]); \
	  for weight in $(weights); do \
	    echo "$(font)$${name}-$${weight} $(font)-$${weight} \"$(font)$${name} ReEncodeFont\" <[$(pkg)-$$n.enc <$(font)-$${weight}.pfb" >> $@; \
	  done; \
	done

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(INSTALLDATA) $(pkg).map $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)
	$(INSTALLDATA) *.enc $(TEXMFDIR)/fonts/enc/dvips/$(pkg)

uninstall:
	$(RM) $(TEXMFDIR)/fonts/map/dvips/$(pkg)
	$(RM) $(TEXMFDIR)/fonts/enc/dvips/$(pkg)

clean:
	$(RM) $(pkg).map
