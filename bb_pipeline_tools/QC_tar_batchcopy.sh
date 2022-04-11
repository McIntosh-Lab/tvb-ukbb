#!/bin/bash
# this script should be run while in an ADNI3 directory (ls should show AD, CN, LMCI, etc directories)
# this script will batch QC_tar your run subjects
#
# usage: QC_tar_batchcopy.sh ADNI_subject_list.tsv $tvb_dir

tvb_dir="${2}"	
mkdir -p QC_tar
while IFS=$' \t\r\n' read -r subjname group; do
	mkdir -p QC_tar/${group}
	${tvb_dir}/bb_pipeline_tools/QC_tar.sh ${subjname} ${group}
	mv ${group}/${subjname}_QC.tar QC_tar/${group}/
done < "$1"
