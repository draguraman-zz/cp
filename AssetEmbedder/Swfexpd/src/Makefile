C=gcc -c -W -Wall -g3
L=gcc $(DEFS)
LIBS=-L/usr/local/lib -lrfxswf -lbase -lz

# libtool stuff
OBJEXT=o
EXEEXT=
ifdef WINDIR
EXEEXT=.exe
endif
AREXT=.a
E=$(EXEEXT)
O=$(OBJEXT)
A=$(AREXT)

all: swfexpd$(E)

swfexpd.$(O): swfexpd.c
	$(C) swfexpd.c -o $@

swfexpd$(E): swfexpd.$(O)
	$(L) $< -o $@ $(LIBS)

clean: 
	rm -f *.$(O) *.lo *.la *~ gmon.out
	rm -f swfexpd$(E)

.PHONY: clean