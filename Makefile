SUBDIRS = dvips font latex
INSTALL = install
INSTALLDIR = $(INSTALL) -d
INSTALLDATA = $(INSTALL) -m 644

PKG := fdsymbol
FONT := FdSymbol
TEXMFDIR := $(shell kpsewhich -expand-var='$$TEXMFHOME')

.PHONY: all install uninstall ctan clean

all:
	for d in $(SUBDIRS); do $(MAKE) -C $$d; done

install:
	for d in $(SUBDIRS); do $(MAKE) -C $$d install; done
	$(INSTALLDIR) $(TEXMFDIR)/doc/fonts/$(FONT)
	$(INSTALLDATA) FONTLOG.txt OFL.txt $(TEXMFDIR)/doc/fonts/$(FONT)

uninstall:
	for d in $(SUBDIRS); do $(MAKE) -C $$d uninstall; done
	rm -rf $(TEXMFDIR)/doc/fonts/$(FONT)

ctan: $(PKG).tar.gz

$(PKG).tar.gz: all
	$(MAKE) install TEXMFDIR:=$(abspath ctan.tmp)
	cd ctan.tmp && zip -r $(PKG).tds.zip doc fonts tex source
	cd ctan.tmp && rm -rf doc fonts tex source
	cd ctan.tmp && mkdir -p doc dvips tfm type1 latex source
	cp FONTLOG.txt OFL.txt latex/$(PKG).pdf ctan.tmp/doc
	cp dvips/*.enc dvips/*.map ctan.tmp/dvips
	cp font/*.tfm ctan.tmp/tfm
	cp font/*.pfb ctan.tmp/type1
	cp latex/$(PKG).dtx latex/$(PKG).ins ctan.tmp/latex
	cp font/*.mf ctan.tmp/source
	cp README.ctan ctan.tmp/README
	(cd ctan.tmp && tar -c *) | gzip - > $@
	rm -rf ctan.tmp

clean:
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done
	rm -f $(PKG).tar.gz
