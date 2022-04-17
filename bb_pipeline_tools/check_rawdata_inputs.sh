#!/bin/bash
# 
# This script checks processed subjects for rawdata files 
# missing rawdata files will be printed if not found.
#
# Usage while in directory containing subjects: 
#		check_rawdata_inputs.sh  list_of_subjects.tsv
#
#   list_of_subjects.tsv should be a file containing list of subjects to be checked, one per line
# 
# Author: Justin Wang


#iterate through subjlist
while IFS= read -r subjname; do

	#check for 41 rawdata files (typical for Cam-CAN subjects)
	num_lines=`find $subjname -type f | wc -l`
	if [ $num_lines -ne 41 ] ; then
		echo ""
		echo "incorrect number of raw files in $subjname : $num_lines"
	fi

	#check for rawdata files from this list
	raw_array=(${subjname}/rawdata/epi_movie/${subjname}_epi_movie_echo4.nii.gz ${subjname}/rawdata/epi_movie/${subjname}_epi_movie_echo3.nii.gz ${subjname}/rawdata/epi_movie/${subjname}_epi_movie_echo5.nii.gz ${subjname}/rawdata/epi_movie/${subjname}_epi_movie_echo2.nii.gz ${subjname}/rawdata/epi_movie/${subjname}_epi_movie_echo1.nii.gz ${subjname}/rawdata/fmap_smt/${subjname}_run-02_fmap_smt.nii.gz ${subjname}/rawdata/fmap_smt/${subjname}_fmap_smt.nii.gz ${subjname}/rawdata/fmap_smt/${subjname}_run-01_fmap_smt.nii.gz ${subjname}/rawdata/anat/${subjname}_T2w.nii.gz ${subjname}/rawdata/anat/${subjname}_T1w.nii.gz ${subjname}/rawdata/epi_rest/${subjname}_epi_rest.nii.gz ${subjname}/rawdata/dwi/${subjname}_dwi.bval ${subjname}/rawdata/dwi/${subjname}_dwi.nii.gz ${subjname}/rawdata/dwi/${subjname}_dwi.bvec ${subjname}/rawdata/epi_smt/${subjname}_epi_smt_onsets.tsv ${subjname}/rawdata/epi_smt/${subjname}_epi_smt.nii.gz ${subjname}/rawdata/fmap_movie/${subjname}_run-01_fmap_movie.nii.gz ${subjname}/rawdata/fmap_movie/${subjname}_run-02_fmap_movie.nii.gz ${subjname}/rawdata/fmap_movie/${subjname}_fmap_movie.nii.gz ${subjname}/rawdata/fmap_rest/${subjname}_run-01_fmap_rest.nii.gz ${subjname}/rawdata/fmap_rest/${subjname}_run-02_fmap_rest.nii.gz ${subjname}/rawdata/fmap_rest/${subjname}_fmap_rest.nii.gz)


	for t in ${raw_array[@]}; do
  		num_results=`find $subjname -name $t | wc -l`
  		if [ $num_results -eq 0 ]; then
  			echo "$subjname has $t missing"
  		fi
	done

done < "$1"

echo ""