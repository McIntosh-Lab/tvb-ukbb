#!/bin/bash
#
# This script renames parcellation-specific files by appending original parcellation name as suffix
# to be run before re-parcellation if parcellation-specific files are generically named
# This script is intended for use on a processed subject that was run on an earlier version of the 
# TVB-UKBB pipeline that did not generate parcellation-specific filenames for parcellation-specific 
# intermediate and output files.
#
# usage, in the directory containing subjects:
#       parcellation_filename_updater.sh <subject ID> <parcellation name>

set +e 

subjID=$1


if [[ "$subjID" =~ '/'$ ]]; then 
  subjID=${subjID%?}
fi



PARC_NAME=$2

# T1
mv $subjID/T1/transforms/parcel_to_T1.nii.gz $subjID/T1/transforms/parcel_to_T1_${PARC_NAME}.nii.gz
mv $subjID/T1/labelled_GM.nii.gz $subjID/T1/labelled_GM_${PARC_NAME}.nii.gz
mv $subjID/T1/labelled_GMI.nii.gz $subjID/T1/labelled_GMI_${PARC_NAME}.nii.gz

# dMRI
mv $subjID/dMRI/dMRI/parcellation.nii.gz $subjID/dMRI/dMRI/parcellation_${PARC_NAME}.nii.gz
mv $subjID/dMRI/probtrackx $subjID/dMRI/probtrackx_${PARC_NAME}
mv $subjID/dMRI/sc.txt $subjID/dMRI/sc_${PARC_NAME}.txt
mv $subjID/dMRI/distance.txt $subjID/dMRI/distance_${PARC_NAME}.txt
mv $subjID/dMRI/probtrackx_${PARC_NAME}/labelledWM_GM.nii.gz $subjID/dMRI/probtrackx_${PARC_NAME}/labelledWM_GM_${PARC_NAME}.nii.gz

# fMRI
array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find $subjID/fMRI -maxdepth 1 -type d -name "*.ica" -print0)

#for each .ica file
for t in ${array[@]}; do
        rfMRI_ver=`basename $t`
        mv $subjID/fMRI/${rfMRI_ver}/parcellation.nii.gz $subjID/fMRI/${rfMRI_ver}/parcellation_${PARC_NAME}.nii.gz 
        mv $subjID/fMRI/${rfMRI_ver}/ts_roied.txt $subjID/fMRI/${rfMRI_ver}/ts_roied_${PARC_NAME}.txt
        mv $subjID/fMRI/${rfMRI_ver}/ts.txt $subjID/fMRI/${rfMRI_ver}/ts_${PARC_NAME}.txt
        mv $subjID/fMRI/${rfMRI_ver}/stats.sum $subjID/fMRI/${rfMRI_ver}/stats_${PARC_NAME}.sum
        mv $subjID/fMRI/${rfMRI_ver}/fc.txt $subjID/fMRI/${rfMRI_ver}/fc_${PARC_NAME}.txt
done


# IDP
mv $subjID/IDP_files $subjID/IDP_files_${PARC_NAME}


# tvb_inputs
mv $subjID/${subjID}_tvb_inputs.zip $subjID/${subjID}_${PARC_NAME}_tvb_inputs.zip


#QC
mv $subjID/QC $subjID/QC_${PARC_NAME}


set -e 

