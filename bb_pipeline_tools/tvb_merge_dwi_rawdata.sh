#!/bin/bash
#
#  This script concatenates diffusion nii.gz, bvec and bval rawdata files for all subject_list.txt subs in the current working directory. The new files will be in the rawdata/ dir for each subject.
#
#  Usage while in the directory containing all subjects:  <path>/<to>/merge_diffusion.sh  <path>/<to>/subject_list.txt  unique_suffix_for_first.nii.gz  unique_suffix_for_second.nii.gz  unique_suffix_for_first.bval  unique_suffix_for_second.bval  unique_suffix_for_first.bvec  unique_suffix_for_second.bvec  unique_suffix_for_dwi.json 
#
#  The unique suffixes are the latter ends of the names of files you want to merge/rename. These suffixes must be unique for each nii.gz, bval, bvec, and json to be merged or renamed by this script. These suffixes must be consistent between all subjects. For example, "acq-b1000_dwi.nii.gz" could be unique_suffix_for_first.nii.gz and "acq-b2000_dwi.nii.gz" could be unique_suffix_for_second.nii.gz. This script will fail if your suffixes are not consistent between subjects or are insufficiently unique within subjects.
#
# Author: Leanne Rokos


bb_pipe_tools=$(dirname $0)

while IFS= read -r subjname; do
if [ -d $subjname ]
	then
        cd ${subjname}/rawdata						
    	

    	nii_1=$(find . -name *${2})
    	nii_2=$(find . -name *${3})
    	newname=${subjname}_dwi.nii.gz
  		fslmerge -t $newname $nii_1 $nii_2


		bval_1=$(find . -name *${4})
		bval_2=$(find . -name *${5})
        bvec_1=$(find . -name *${6})
        bvec_2=$(find . -name *${7})
        ${bb_pipe_tools}/tvb_merge_bvecbval.py bval_1 bval_2 bvec_1 bvec_2 ${subjname}_dwi.bval ${subjname}_dwi.bvec


        dwi_json=$(find . -name *${8}) 
		cp ${dwi_json} ${subjname}_dwi.json 
		

		mkdir orig_dwi_files
		mv -t orig_dwi_files $nii_1 $nii_2 $bval_1 $bval_2 $bvec_1 $bvec_2 $dwi_json
		cd ../..
        fi
done < "$1"

echo ""
