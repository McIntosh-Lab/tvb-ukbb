#!/bin/bash
# this script should be run while in an CC directory (ls should show subject directories)
# this script will batch QC_tar your run subjects
#
# usage: QC_tar_batchcopy.sh CC_subject_list.tsv $tvb_dir

tvb_dir="${2}"	
mkdir -p QC_tar
while IFS=$' \t\r\n' read -r subjname; do
	mkdir -p QC_tar
	${tvb_dir}/bb_pipeline_tools/QC_tar.sh ${subjname}
	mv ${subjname}_QC.tar QC_tar/
done < "$1"
