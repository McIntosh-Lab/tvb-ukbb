#!/bin/bash
#
#  This script concatenates diffusion nii.gz, bvec and bval files for all subject_list.txt subs in the current working directory.
#
#  Usage:  <path>/<to>/merge_diffusion.sh  <path>/<to>/subject_list.txt
#

tvb_dir="/<path>/<to>/tvb-ukbb"                   #TO BE MODIFIED BY USER

while IFS= read -r subjname; do
if [ -d $subjname ]
	then
        cd $subjname                              #TO BE MODIFIED BY USER
        	b1000=$(ls *acq-b1000_dwi.nii.gz) #TO BE MODIFIED BY USER
        	b2000=$(ls *acq-b2000_dwi.nii.gz) #TO BE MODIFIED BY USER
        	newname=${subjname}_dwi.nii.gz

  		fslmerge -t $newname $b1000 $b2000

		bval1000=$(ls *acq-b1000_dwi.bval) #TO BE MODIFIED BY USER
		bval2000=$(ls *acq-b2000_dwi.bval) #TO BE MODIFIED BY USER

                bvec1000=$(ls *acq-b1000_dwi.bvec) #TO BE MODIFIED BY USER
                bvec2000=$(ls *acq-b2000_dwi.bvec) #TO BE MODIFIED BY USER

		mv $bval1000 1000.bval
		mv $bval2000 2000.bval
		mv $bvec1000 1000.bvec
		mv $bvec2000 2000.bvec

		${tvb_dir}/bb_pipeline_tools/merge_bvecbval.py $subjname


		mv bval ${subjname}_dwi.bval
                mv bvec ${subjname}_dwi.bvec
		cp $(ls *acq-b1000_dwi.json) ${subjname}_dwi.json #TO BE MODIFIED BY USER
		mkdir orig_dwi_files
		mv -t orig_dwi_files 1000.bv* 2000.bv* $(ls *acq*)
		cd ..
        fi
done < "$1"

echo ""
