SUBDIRS = source enc latex
INSTALL = install
INSTALLDATA = install -m 644

texmfdir = $(shell (kpsewhich -expand-var='$$TEXMFHOME' | sed 's/:.*//'))

.PHONY: all $(SUBDIRS) install $(SUBDIRS:%=install-%) clean $(SUBDIRS:%=clean-%)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

install: $(SUBDIRS:%=install-%)
	$(INSTALL) -d $(texmfdir)/doc/fonts/FdSymbol
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(texmfdir)/doc/fonts/FdSymbol

$(SUBDIRS:%=install-%): install-%:
	$(MAKE) -C $* install

clean: $(SUBDIRS:%=clean-%)

$(SUBDIRS:%=clean-%): clean-%:
	$(MAKE) -C $* clean
