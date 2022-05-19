#!/bin/bash
#
# this script should be run while in an ADNI3 directory (ls should show AD, CN, LMCI, etc directories)
# This script checks processed subjects for rawdata files 
# missing expected rawdata files will be printed if not found.
#
# Usage while in directory containing subjects: 
#		check_rawdata_inputs.sh  list_of_subjects.tsv
#
#   list_of_subjects.tsv should be a file containing list of subjects to be checked, one per line. subj name and group (AD, CN, etc) should be on each line, separated by a tab
# 
# Author: Justin Wang


#required rawdata filename wildcards
T1=("*T1*.nii.gz" "*MPRAGE*.nii.gz" "*IR-FSPGR*.nii.gz")
T2=("T2*FLAIR*.nii.gz" "*FLAIR*.nii.gz")
rfMRI=("*FMRI*RESTING*.nii.gz" "MB8*RESTING*.nii.gz" "*TASK*REST*.nii.gz" "*task*rest*.nii.gz" "*epi_rest*.nii.gz" "*rsfMRI*.nii.gz" "*fcMRI*.nii.gz")
tfMRI=("*fmri*task*.nii.gz" "*FMRI*TASK*.nii.gz" "MB8*TASK*.nii.gz" "*epi_movie*.nii.gz" "*epi_smt*.nii.gz")
SWI=("SWI*nii.gz")
DWI=("DIFF_*" "MB3_*" "*dwi*.*" "*DWI*.*")


#iterate through subjlist
while IFS=$' \t\r\n' read -r subjname group; do
	currentdir=`pwd`
	cd "${group}/${subjname}/rawdata/"

	T1_flag="false"
	T2_flag="false"
	rfMRI_flag="false"
	tfMRI_flag="false"
	SWI_flag="false"
	DWI_flag="false"

	#check t1 rawdatas
  	for t in ${T1[@]}; do
		if compgen -G "$t" > /dev/null; then
		    T1_flag="true"
		else
			:
		fi

	done
	if [ $T1_flag = "false" ]; then
		echo "${group}/${subjname} is missing T1"
	fi


	#check t2 rawdatas
	for t in ${T2[@]}; do
		if compgen -G "$t" > /dev/null; then
		    T2_flag="true"
		else
			:
		fi

	done
	if [ $T2_flag = "false" ]; then
		echo "${group}/${subjname} is missing T2"
	fi

	#check rfmri rawdatas
	rfMRI_counter=0
	rfMRI_last=""
	for t in ${rfMRI[@]}; do
		if compgen -G "$t" > /dev/null; then
		    rfMRI_flag="true"
		    rfMRI_counter=$((rfMRI_counter+1))
		    rfMRI_last=`ls ${t}`
		else
			:
		fi

	done
	if [ $rfMRI_flag = "false" ]; then
		echo "${group}/${subjname} is missing rfMRI"
	fi
	if [ $rfMRI_counter -eq 1 ]; then
		mydim4=`${FSLDIR}/bin/fslval ${rfMRI_last} dim4`
		if [ $mydim4 -eq 1 ]; then
			echo "${group}/${subjname} is missing rfMRI. only SBREF exists."
		fi
	fi

	#check tfmri rawdatas
	# for t in ${tfMRI[@]}; do
	# 	if compgen -G "$t" > /dev/null; then
	# 	    tfMRI_flag="true"
	# 	else
	# 		:
	# 	fi

	# done
	#if [ $tfMRI_flag = "false" ]; then
	#	echo "${group}/${subjname} is missing tfMRI"
	#fi

	#check swi rawdatas
	# for t in ${SWI[@]}; do
	# 	if compgen -G "$t" > /dev/null; then
	# 	    SWI_flag="true"
	# 	else
	# 		:
	# 	fi

	# done
	#if [ $SWI_flag = "false" ]; then
	#	echo "${group}/${subjname} is missing SWI"
	#fi


	#check dwi rawdatas
	for t in ${DWI[@]}; do
		if compgen -G "$t" > /dev/null; then
		    DWI_flag="true"
		else
			:
		fi

	done
	if [ $DWI_flag = "false" ]; then
		echo "${group}/${subjname} is missing DWI"
	fi


	cd $currentdir
done < "$1"

echo ""