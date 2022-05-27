###########################################################################
### NUOPC GNUMake Macro File for the Baroclinic Modeling Component (BARDATA)
###
### Author: Panagiotis Velissariou <panagiotis.velissariou@noaa.gov>
### Date:   March 04 2022
###########################################################################


########################################################################

# Location of source code and installation
BARDATA_SRCDIR?=$(ROOTDIR)/BARDATA
BARDATA_BINDIR?=$(ROOTDIR)/BARDATA_INSTALL
BARDATA_NUOPC_SRCDIR?=$(ROOTDIR)/BARDATA/nuopc

# Location of the ESMF makefile fragment for this component:
bardata_mk = $(BARDATA_BINDIR)/bardata.mk
all_component_mk_files+=$(bardata_mk)

# Make sure the expected directories exist and are non-empty:
$(call require_dir,$(BARDATA_SRCDIR),BARDATA source directory)

########################################################################

# Rule for building this component:

build_BARDATA: $(bardata_mk)

$(bardata_mk):
	+cd $(BARDATA_SRCDIR); exec ./build.sh --compiler=$(NEMS_COMPILER) --parallel=$(NEMS_PARALLEL) \
	   --component=ogcmdl --prefix=$(BARDATA_BINDIR) \
	   --cmake_flags="-DCMAKE_INSTALL_BINDIR=$(BARDATA_BINDIR) -DCMAKE_INSTALL_LIBDIR=$(BARDATA_BINDIR)" \
	   --verbose
	@if [ $$? -eq 0 ]; \
	then \
	  cd $(BARDATA_NUOPC_SRCDIR); \
          export BARDATA_BINDIR=$(BARDATA_BINDIR); \
          exec $(MAKE) install DESTDIR=/ "INSTDIR=$(BARDATA_BINDIR)"; \
	  echo ""; \
	  test -d "$(BARDATA_BINDIR)"; \
	  echo ""; \
	  test -s $(bardata_mk); \
	  echo ""; \
	else \
          echo "ERROR: could not compile the NUOPC Cap due to BARDATA build errors"; \
	  exit 1; \
	fi

########################################################################

# Rule for cleaning the SRCDIR and BINDIR:

clean_BARDATA_NUOPC:
	+cd $(BARDATA_NUOPC_SRCDIR); exec $(MAKE) clean
	@echo ""

distclean_BARDATA_NUOPC:
	+cd $(BARDATA_NUOPC_SRCDIR); exec $(MAKE) distclean
	@echo ""

clean_BARDATA: clean_BARDATA_NUOPC
	+cd $(BARDATA_SRCDIR); exec ./build.sh --clean=1
	@echo ""

distclean_BARDATA: distclean_BARDATA_NUOPC
	+cd $(BARDATA_SRCDIR); exec ./build.sh --clean=2
	rm -rf $(BARDATA_BINDIR)
	@echo ""
