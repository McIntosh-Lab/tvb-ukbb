#!/bin/sh
#
# Script name: tvb_susceptibility_mask_gen
#
# Description: Script to generate the susceptible vs non-susceptible ROIs masks




origDir=`pwd`
scriptName=`basename "$0"`
direc=$1

cd $direc

bin_suscept_parc_img=`basename $PARC_IMG`
bin_suscept_parc_img="IDP_files/binmask_$bin_suscept_parc_img"
fslmaths $PARC_IMG -bin $bin_suscept_parc_img

bin_suscept_rois=`basename $SUSCEPT_ROIS`
bin_suscept_rois="IDP_files/binmask_$bin_suscept_rois"
fslmaths $SUSCEPT_ROIS -bin $bin_suscept_rois

inv_bin_suscept_rois=`basename $SUSCEPT_ROIS`
inv_bin_suscept_rois="IDP_files/inv_binmask_$inv_bin_suscept_rois"
fslmaths $bin_suscept_parc_img -sub $bin_suscept_rois $inv_bin_suscept_rois
#TODO: register parcellations to T1 
#${FSLDIR}/bin/applywarp --rel --interp=nn --in=$PARC_IMG --ref=T1 -w T1_to_MNI_warp_coef_inv -o parcel_to_T1

# ${FSLDIR}/bin/applywarp --rel --interp=nn --in=$bin_suscept_rois --ref=fMRI/rfMRI_0.ica/filtered_func_data -w fMRI/rfMRI_0.ica/reg/standard2example_func_warp -o "IDP_files/suscept_parc_to_func"

# ${FSLDIR}/bin/applywarp --rel --interp=nn --in=$inv_bin_suscept_rois --ref=fMRI/rfMRI_0.ica/filtered_func_data -w fMRI/rfMRI_0.ica/reg/standard2example_func_warp -o "IDP_files/non_suscept_parc_to_func"

echo "$inv_bin_suscept_rois"
echo "$bin_suscept_rois"

cd $origDir


