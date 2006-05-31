CFLAGS = -O3 -Wall -fomit-frame-pointer -Izlib -pipe -ffast-math -MMD \
	-mtune=i686
LDFLAGS =
RM = rm -f FILE
ZLIBDIR = zlib/

ifeq (Windows_NT,$(OS))
  EXE = zdbsp.exe
  LDFLAGS += -luser32 -lgdi32
  ifneq (msys,$(OSTYPE))
    RM = del /q /f FILE 2>nul
    ZLIBDIR = "zlib\"
  endif
else
  EXE = zdbsp
  CFLAGS += -Dstricmp=strcasecmp -Dstrnicmp=strncasecmp -DNO_MAP_VIEWER=1
endif

CC = gcc
CXX = g++

CXXFLAGS = $(CFLAGS)

OBJS = main.o getopt.o getopt1.o blockmapbuilder.o processor.o view.o wad.o \
	nodebuild.o nodebuild_events.o nodebuild_extract.o nodebuild_gl.o \
	nodebuild_utility.o \
	zlib/adler32.o zlib/compress.o zlib/crc32.o zlib/deflate.o zlib/trees.o \
	zlib/zutil.o

all: $(EXE)

profile:
	$(MAKE) clean
	$(MAKE) all CFLAGS="$(CFLAGS) -fprofile-generate" LDFLAGS="$(LDFLAGS) -lgcov"
	@echo "Process a few maps, then rebuild with make profile-use"

profile-use:
	$(MAKE) clean
	$(MAKE) all CXXFLAGS="$(CXXFLAGS) -fprofile-use"

$(EXE): $(OBJS)
	$(CCDV) $(CXX) -o $(EXE) $(OBJS) $(LDFLAGS)

.PHONY: clean

clean:
	$(subst FILE,$(EXE),$(RM))
	$(subst FILE,*.o,$(RM))
	$(subst FILE,*.d,$(RM))
	$(subst FILE,$(ZLIBDIR)*.o,$(RM))
	$(subst FILE,$(ZLIBDIR)*.d,$(RM))

cleanprof:
	$(subst FILE,*.gc*,$(RM))
	$(subst FILE,$(ZLIBDIR)*.gc*,$(RM))
	
cleanall: clean cleanprof

ifneq ($(MAKECMDGOALS),clean)
-include $(OBJS:%.o=%.d)
endif