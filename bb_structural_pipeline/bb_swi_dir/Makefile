.PHONY : build_mcrv_file
.PHONY : all

MKDIR_P=mkdir -p

MCCOPTS=-mv -R -nojvm -R -nodisplay

REQ_FSL=swiProcessing

all: directories MCR $(REQ_FSL) 

MCR:
	$(eval MCRV := $(shell echo "${FSL_SWI_MATLAB} $(FSL_SWI_MOPTS) -r \"[maj,min,upd,pt] = mcrversion; if upd ~= 0, disp(sprintf('MCR=%d%d', maj, min, upd)); else; disp(sprintf('MCR=v%d%d', maj, min)); end\"" | sh | grep "MCR=" | awk -F"=" '{ print $$2 }'))
ifeq ($(FSL_SWI_OS),Darwin)
	$(eval mccdeploydir := maci64)
else
ifeq ($(FSL_SWI_OS),Linux)
ifeq ($(FSL_SWI_ARCH),x86_64)
	$(eval mccdeploydir := glnxa64)
else
	$(eval mccdeploydir := glnx86)
endif
else
	echo "Platform unknown"
	false
endif
endif
	
	$(eval RTI := ${FSL_SWI_MATLAB_ROOT}/toolbox/compiler/deploy/$(mccdeploydir)/MCRInstaller.zip)
	if [ -f ${FSL_SWI_MLCDIR}/MCRInstaller.zip ]; then \
		rm -f ${FSL_SWI_MLCDIR}/MCRInstaller.zip; \
	fi
	cp $(RTI) ${FSL_SWI_MLCDIR}/
	echo $(MCRV) > MCR.version

directories: ${FSL_SWI_MLCDIR}

${FSL_SWI_MLCDIR}:
	${MKDIR_P} ${FSL_SWI_MLCDIR}
        
swiProcessing: swiProcessing.m
	${FSL_SWI_MCC} $(MCCOPTS) -I ${FSL_SWI_FSLMATLAB} -d ${FSL_SWI_MLCDIR} $<

