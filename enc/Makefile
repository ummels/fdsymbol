INSTALL = install
INSTALLDATA = install -m 644

texmfdir = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all install clean

all:

install: all
	$(INSTALL) -d $(texmfdir)/fonts/map/dvips/fdsymbol
	$(INSTALLDATA) fdsymbol.map $(texmfdir)/fonts/map/dvips/fdsymbol
	$(INSTALL) -d $(texmfdir)/fonts/enc/dvips/fdsymbol
	$(INSTALLDATA) *.enc $(texmfdir)/fonts/enc/dvips/fdsymbol

clean:
