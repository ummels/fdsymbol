INSTALL = install
INSTALLDATA = install -m 644

TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all install clean

all:

install:
	$(INSTALL) -d $(TEXMFDIR)/fonts/map/dvips/fdsymbol
	$(INSTALLDATA) fdsymbol.map $(TEXMFDIR)/fonts/map/dvips/fdsymbol
	$(INSTALL) -d $(TEXMFDIR)/fonts/enc/dvips/fdsymbol
	$(INSTALLDATA) *.enc $(TEXMFDIR)/fonts/enc/dvips/fdsymbol

clean:
