.PHONY: all clean

all: fdsymbol.pdf fdsymbol.sty

fdsymbol.pdf: fdsymbol.dtx
	pdflatex fdsymbol.dtx
	while grep -s 'Rerun to get cross-references right.' fdsymbol.log; do \
	  pdflatex fdsymbol.dtx; \
	done

fdsymbol.sty: fdsymbol.ins fdsymbol.dtx
	latex fdsymbol.ins

clean:
	rm -f fdsymbol.aux fdsymbol.log fdsymbol.out fdsymbol.sty fdsymbol.pdf fdsymbol.toc
