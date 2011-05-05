INSTALL = install
INSTALLDIR = $(INSTALL) -d
INSTALLDATA = $(INSTALL) -m 644

PKG := fdsymbol
FONT := FdSymbol
NAMES := A B C D E F
WEIGHTS := Book Regular Medium Bold
TEXMFDIR := $(shell (kpsewhich -expand-var='$$TEXMFHOME'))

.PHONY: all install uninstall clean

all: $(PKG).map

$(PKG).map:
	for name in $(NAMES); do \
	  n=$$(echo $${name} | tr [:upper:] [:lower:]); \
	  for weight in $(WEIGHTS); do \
	    echo "$(FONT)$${name}-$${weight} $(FONT)-$${weight} \"$(FONT)$${name} ReEncodeFont\" <[$(PKG)-$$n.enc <$(FONT)-$${weight}.pfb" >> $@; \
	  done; \
	done

install: all
	$(INSTALLDIR) $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	$(INSTALLDATA) $(PKG).map $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	$(INSTALLDIR) $(TEXMFDIR)/fonts/enc/dvips/$(PKG)
	$(INSTALLDATA) *.enc $(TEXMFDIR)/fonts/enc/dvips/$(PKG)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	rm -rf $(TEXMFDIR)/fonts/enc/dvips/$(PKG)

clean:
	rm -f $(PKG).map
