INSTALL = install
INSTALLDATA = install -m 644

PKG = fdsymbol
TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME'))

.PHONY: all install clean

all:

install:
	$(INSTALL) -d $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	$(INSTALLDATA) $(PKG).map $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	$(INSTALL) -d $(TEXMFDIR)/fonts/enc/dvips/$(PKG)
	$(INSTALLDATA) *.enc $(TEXMFDIR)/fonts/enc/dvips/$(PKG)

uninstall:
	rm -rf $(TEXMFDIR)/fonts/map/dvips/$(PKG)
	rm -rf $(TEXMFDIR)/fonts/enc/dvips/$(PKG)

clean:
