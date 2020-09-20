.PHONY : build_mcrv_file
.PHONY : all

MKDIR_P=mkdir -p

MCCOPTS=-mv -R -nojvm -R -nodisplay

REQ_FSL=fix_1a_extract_features fix_2c_loo_results functionmotionconfounds
REQ_CIFnFSL=fix_3_clean

# all: directories MCR $(REQ_FSL) $(REQ_CIFnFSL) 
all: directories $(REQ_FSL) $(REQ_CIFnFSL) 
	
MCR:
	$(eval MCRV := $(shell echo "${FSL_FIX_MATLAB} $(FSL_FIX_MOPTS) -r \"[maj,min,upd,pt] = mcrversion; if upd ~= 0, disp(sprintf('MCR=%d%d', maj, min, upd)); else; disp(sprintf('MCR=v%d%d', maj, min)); end\"" | sh | grep "MCR=" | awk -F"=" '{ print $$2 }'))
ifeq ($(FSL_FIX_OS),Darwin)
	$(eval mccdeploydir := maci64)
else
ifeq ($(FSL_FIX_OS),Linux)
ifeq ($(FSL_FIX_ARCH),x86_64)
	$(eval mccdeploydir := glnxa64)
else
	$(eval mccdeploydir := glnx86)
endif
else
	echo "Platform unknown"
	false
endif
endif
	
	$(eval RTI := ${FSL_FIX_MATLAB_ROOT}/toolbox/compiler/deploy/$(mccdeploydir)/MCRInstaller.zip)
	if [ -f ${FSL_FIX_MLCDIR}/MCRInstaller.zip ]; then \
		rm -f ${FSL_FIX_MLCDIR}/MCRInstaller.zip; \
	fi
	cp $(RTI) ${FSL_FIX_MLCDIR}/
	echo $(MCRV) > MCR.version

directories: ${FSL_FIX_MLCDIR}

${FSL_FIX_MLCDIR}:
	${MKDIR_P} ${FSL_FIX_MLCDIR}
	echo "HERE"
        
functionmotionconfounds: functionmotionconfounds.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<
	
fix_1a_extract_features: fix_1a_extract_features.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<

fix_2c_loo_results: fix_2c_loo_results.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<
	
fix_3_clean: fix_3_clean.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -I ${FSL_FIX_CIFTIRW} -d ${FSL_FIX_MLCDIR} $<


	
