SUBDIRS = enc font latex
INSTALL = install
INSTALLDATA = install -m 644

FONT := FdSymbol
TEXMFDIR := $(shell (kpsewhich -expand-var='$$TEXMFHOME'))

.PHONY: all install uninstall clean

all:
	for d in $(SUBDIRS); do $(MAKE) -C $$d; done

install:
	for d in $(SUBDIRS); do $(MAKE) -C $$d install; done
	$(INSTALL) -d $(TEXMFDIR)/doc/fonts/$(FONT)
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/$(FONT)

uninstall:
	for d in $(SUBDIRS); do $(MAKE) -C $$d uninstall; done
	rm -rf $(TEXMFDIR)/doc/fonts/$(FONT)

clean:
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done
