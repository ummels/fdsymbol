SUBDIRS = latex source

.PHONY: all $(SUBDIRS) clean $(SUBDIRS:%=clean%)

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

clean: $(SUBDIRS:%=clean%)

$(SUBDIRS:%=clean%): clean%:
	$(MAKE) -C $* clean
