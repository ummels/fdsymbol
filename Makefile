SUBDIRS = enc font latex
INSTALL = install
INSTALLDATA = install -m 644

FONT = FdSymbol
TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME'))

.PHONY: all $(SUBDIRS) install $(SUBDIRS:%=install-%) clean $(SUBDIRS:%=clean-%)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

install: $(SUBDIRS:%=install-%)
	$(INSTALL) -d $(TEXMFDIR)/doc/fonts/$(FONT)
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/$(FONT)

$(SUBDIRS:%=install-%): install-%:
	$(MAKE) -C $* install

clean: $(SUBDIRS:%=clean-%)

$(SUBDIRS:%=clean-%): clean-%:
	$(MAKE) -C $* clean
