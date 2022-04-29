#!/bin/sh
#
# Script name: tvb_struct_parcellation.sh
#
# Description: Script with all the parcellation-specific structural processing.
#
# Authors: Justin Wang, Kelly Shen
#


. $BB_BIN_DIR/bb_pipeline_tools/bb_set_header 

cd $1/T1

#register parcellation mask to T1
${FSLDIR}/bin/applywarp --rel --interp=nn --in=$PARC_IMG --ref=T1 -w transforms/T1_to_MNI_warp_coef_inv -o transforms/parcel_to_T1_${PARC_NAME}

#label GM with ROIs
${AFNIDIR}/3dROIMaker -inset cort_subcort_GM.nii.gz -thresh 0.1 -inflate 1 -prefix labelled -refset transforms/parcel_to_T1_${PARC_NAME}.nii.gz -nifti -neigh_upto_vert -dump_no_labtab

#rename labelled GM and GMI to include parcellation
mv labelled_GM.nii.gz labelled_GM_${PARC_NAME}.nii.gz 
mv labelled_GMI.nii.gz labelled_GMI_${PARC_NAME}.nii.gz 

#for some reason both labelled_GM and labelled_GMI are inflated; fix it here
${FSLDIR}/bin/fslmaths labelled_GM_${PARC_NAME} -mas cort_subcort_GM.nii.gz labelled_GM_${PARC_NAME}


. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer 

set +x