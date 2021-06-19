########################################################################
### Panagiotis Velissariou <panagiotis.velissariou@noaa.gov> - 18/05/2021
###
### Version: 1.0 (18/05/2021)
########################################################################

# Location of source code and installation
SCHISM_ROOTDIR?=$(ROOTDIR)/SCHISM
SCHISM_SRCDIR?=$(SCHISM_ROOTDIR)/src
SCHISM_BLDDIR?=$(SCHISM_ROOTDIR)/build
SCHISM_BINDIR?=$(ROOTDIR)/SCHISM_INSTALL

# SCHISM needs the compilers for C, Fortran and CXX, the latter ones
# are defined in ESMFMKFILE, the former is computed here (@todo test), by
# trying mpicxx, mpiicpc and mpicpc as CXXCOMPILER
include $(ESMFMKFILE)
ESMF_CCOMPILER=$(subst mpicxx,mpicc,$(ESMF_CXXCOMPILER))
ifeq ($(ESMF_CCOMPILER),$(ESMF_CXXCOMPILER))
ESMF_CCOMPILER:=$(subst mpiicpc,mpiicc,$(ESMF_CXXCOMPILER))
endif
ifeq ($(ESMF_CCOMPILER),$(ESMF_CXXCOMPILER))
ESMF_CCOMPILER:=$(subst mpicpc,mpicc,$(ESMF_CXXCOMPILER))
endif

# Location of the ESMF makefile fragment for this component:
schism_mk = $(SCHISM_BINDIR)/schism.mk
all_component_mk_files+=$(schism_mk)

# Make sure the expected directories exist and are non-empty:
$(call require_dir,$(SCHISM_SRCDIR),SCHISM source directory)

# ENV for SCHISM - exchange with NEMS ENV

SCHISM_ALL_OPTS= \
  COMP_SRCDIR="$(SCHISM_SRCDIR)" \
  COMP_BINDIR="$(SCHISM_BINDIR)" \
  MACHINE_ID="$(MACHINE_ID)"

########################################################################

# Rule for building this component:

build_SCHISM: $(schism_mk)

$(schism_mk): configure $(CONFDIR)/configure.nems
   ### Configure CMake build for SCHISM
	+$(MODULE_LOGIC); echo "SCHISM_SRCDIR = $(SCHISM_SRCDIR)"; exec cmake -S $(SCHISM_SRCDIR) -B $(SCHISM_ROOTDIR)/build -DCMAKE_VERBOSE_MAKEFILE=TRUE \
	 -DCMAKE_Fortran_COMPILER=$(ESMF_F90COMPILER) -DCMAKE_CXX_COMPILER=$(ESMF_CXXCOMPILER) -DCMAKE_C_COMPILER=$(ESMF_CCOMPILER)
   ### Compile the SCHISM components
	+cd $(SCHISM_BLDDIR); exec $(MAKE) pschism
#	cd $(SCHISM_BLDDIR); exec $(MAKE) install
	make -C  $(SCHISM_ROOTDIR)/../schism-esmf install-nuopc DESTDIR=$(SCHISM_BINDIR) SCHISM_BUILD_DIR=$(SCHISM_ROOTDIR)/build
	#+$(MODULE_LOGIC); cd $(SCHISM_SRCDIR)/../schism-esmf/src/schism; exec $(MAKE) $(SCHISM_ALL_OPTS) install-nuopc  \
        #  DESTDIR=/ "INSTDIR=$(SCHISM_BINDIR)"
	@echo ""
	test -d "$(SCHISM_BINDIR)"
	@echo ""
	test -s $(schism_mk)
	@echo ""

########################################################################

# Rule for cleaning the SRCDIR and BINDIR:

clean_SCHISM:
#	+cd $(SCHISM_SRCDIR); exec $(MAKE) -f build/Makefile -k clean
#	@echo ""

distclean_SCHISM: clean_SCHISM
	+cd $(SCHISM_SRCDIR)/work ; exec $(MAKE) -k distclean
	rm -rf $(SCHISM_BINDIR)
	@echo ""

distclean_NUOPC:
	+cd $(SCHISM_SRCDIR)/thirdparty/schism-esmf/src/schism ; exec rm -f *.o *.mod *.a schism.mk  # make clean/distclean here
	rm -rf $(SCHISM_BINDIR)
	@echo ""
