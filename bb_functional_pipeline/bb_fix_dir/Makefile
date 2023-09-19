.PHONY : build_mcrv_file
.PHONY : all
.PHONY : release

MKDIR_P=mkdir -p

MCCOPTS=-mv -R -nodisplay

REQ_FSL=fix_1a_extract_features fix_2c_loo_results functionmotionconfounds
REQ_CIFnFSL=fix_3_clean
parent:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
folder:=$(shell basename $(parent))

all: directories MCR $(REQ_FSL) $(REQ_CIFnFSL) fix_permissions

MCR:
	$(eval MCRV := $(shell echo "${FSL_FIX_MATLAB} $(FSL_FIX_MLOPTS) -r \"[maj,min,upd,pt] = mcrversion; if upd ~= 0, disp(sprintf('MCR=%d%d', maj, min, upd)); else; disp(sprintf('MCR=v%d%d', maj, min)); end\"" | sh | grep "MCR=" | awk -F"=" '{ print $$2 }'))
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

	echo $(MCRV) > ${FSL_FIX_MLCDIR}/MCR.version

directories: ${FSL_FIX_MLCDIR}

${FSL_FIX_MLCDIR}:
	${MKDIR_P} ${FSL_FIX_MLCDIR}

fix_permissions:
	for file in ${FSL_FIX_MLCDIR}/*; do \
		chmod 0755 $${file}; done
	for nonexe in mccExcludedFiles.log readme.txt; do \
		chmod 0644 ${FSL_FIX_MLCDIR}/$${nonexe}; done

functionmotionconfounds: functionmotionconfounds.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<

fix_1a_extract_features: fix_1a_extract_features.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<

fix_2c_loo_results: fix_2c_loo_results.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -d ${FSL_FIX_MLCDIR} $<

fix_3_clean: fix_3_clean.m
	${FSL_FIX_MCC} $(MCCOPTS) -I ${FSL_FIX_FSLMATLAB} -I ${FSL_FIX_CIFTIRW} -d ${FSL_FIX_MLCDIR} $<

release: fix.tar.gz

fix.tar.gz:
	(cd "$(parent)/.."; tar zcf "$(parent)/fix.tar.gz" --exclude ".git*" --exclude ".nfs*" --exclude "fix.tar.gz" -s "/^$(folder)/fix/" "$(folder)")
