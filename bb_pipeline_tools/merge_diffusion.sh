#!/bin/bash
#
#  This script concatenates diffusion nii.gz, bvec and bval files for all subject_list.txt subs in the current working directory. 
#
#  Usage:  <path>/<to>/merge_diffusion.sh  <path>/<to>/subject_list.txt  <relative>/<path>/<to>/first.nii.gz  <relative>/<path>/<to>/second.nii.gz  <relative>/<path>/<to>/first.bval  <relative>/<path>/<to>/second.bval  <relative>/<path>/<to>/first.bvec  <relative>/<path>/<to>/second.bvec  <relative>/<path>/<to>/dwi.json 
#
#	User needs to be in the directory above each subject directory (i.e. running ls should show all subject directories).
#
# Author: Leanne Rokos


bb_pipe_tools=dirname "$0"

while IFS= read -r subjname; do
if [ -d $subjname ]
	then
        cd $subjname						
    	
    	nii_1=$2 	
    	nii_2=$3 	
    	
    	newname=${subjname}_dwi.nii.gz

  		fslmerge -t $newname $nii_1 $nii_2

		bval_1=$4 
		bval_2=$5 

        bvec_1=$6 
        bvec_2=$7
        dwi_json=$8

		${bb_pipe_tools}/merge_bvecbval.py bval_1 bval_2 bvec_1 bvec_2 ${subjname}_dwi.bval ${subjname}_dwi.bvec


		cp $(dwi_json) ${subjname}_dwi.json 

		mkdir orig_dwi_files
		mv -t orig_dwi_files $nii_1 $nii_2 $bval_1 $bval_2 $bvec_1 $bvec_2 $dwi_json
		cd ..
        fi
done < "$1"

echo ""
