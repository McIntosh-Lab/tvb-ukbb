#!/bin/sh
#
# This script renames parcellation-specific files by appending original parcellation name as suffix
# to be run before re-parcellation if parcellation-specific files are generically named
# This script is intended for use on a processed subject that was run on an earlier version of the 
# TVB-UKBB pipeline that did not generate parcellation-specific filenames for parcellation-specific 
# intermediate and output files.
#
# usage, in the directory containing subjects:
#	rename_origParcel <subject ID> <parcellation name>
​
subjID=$1
parcName=$2
​
# T1
mv $subjID/T1/transforms/parcel_to_T1.nii.gz $subjID/T1/transforms/parcel_to_T1_$parcName.nii.gz
mv $subjID/T1/labelled_GM.nii.gz $subjID/T1/labelled_GM_$parcName.nii.gz
mv $subjID/T1/labelled_GMI.nii.gz $subjID/T1/labelled_GMI_$parcName.nii.gz
​
# dMRI
mv $subjID/dMRI/dMRI/parcellation.nii.gz $subjID/dMRI/dMRI/parcellation_$parcName.nii.gz
mv $subjID/dMRI/probtrackx $subjID/dMRI/probtrackx_$parcName
mv $subjID/dMRI/sc.txt $subjID/dMRI/sc_$parcName.txt
mv $subjID/dMRI/distance.txt $subjID/dMRI/distance_$parcName.txt
mv $subjID/dMRI/probtrackx_$parcName/labelledWM_GM.nii.gz $subjID/dMRI/probtrackx_$parcName/labelledWM_GM_${PARC_NAME}.nii.gz
​
# fMRI
## TODO: must add sth to loop through multiple iterations of rsfMRI
array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find $subjID/fMRI -maxdepth 1 -type d -name "*.ica" -print0)

#for each .ica file
for t in ${array[@]}; do
	rfMRI_ver=`basename $t`
	mv $subjID/fMRI/${rfMRI_ver}/parcellation.nii.gz $subjID/fMRI/${rfMRI_ver}/parcellation_$parcName.nii.gz 
	mv $subjID/fMRI/${rfMRI_ver}/ts_roied.txt $subjID/fMRI/${rfMRI_ver}/ts_roied_$parcName.txt
	mv $subjID/fMRI/${rfMRI_ver}/ts.txt $subjID/fMRI/${rfMRI_ver}/ts_$parcName.txt
	mv $subjID/fMRI/${rfMRI_ver}/stats.sum /fMRI/${rfMRI_ver}/stats_$parcName.sum
	mv $subjID/fMRI/${rfMRI_ver}/fc.txt $subjID/fMRI/${rfMRI_ver}/fc_$parcName.txt
	​
done



​mv $subjID/IDP_files/${scriptName}.txt $subjID/IDP_files/${scriptName}_${PARC_NAME}.txt

#tvb inputs
#IDP and QC files