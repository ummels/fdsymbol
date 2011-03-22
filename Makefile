SUBDIRS = enc font latex
INSTALL = install
INSTALLDATA = install -m 644

TEXMFDIR = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all $(SUBDIRS) install $(SUBDIRS:%=install-%) clean $(SUBDIRS:%=clean-%)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

install: $(SUBDIRS:%=install-%)
	$(INSTALL) -d $(TEXMFDIR)/doc/fonts/FdSymbol
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/FdSymbol

$(SUBDIRS:%=install-%): install-%:
	$(MAKE) -C $* install

clean: $(SUBDIRS:%=clean-%)

$(SUBDIRS:%=clean-%): clean-%:
	$(MAKE) -C $* clean
