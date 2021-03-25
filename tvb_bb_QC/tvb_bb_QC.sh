#!/bin/bash
#
# Script name: tvb_bb_QC.sh
#
# Description: Script to generate QC images 
#
## Author: Justin Wang

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_header

set -x

origDir=`pwd`

dirScript=`dirname $0`

dirSubject=`pwd`/$1

if [[ "$dirSubject" == "" ]] ; then
    echo "Error: The selected subject does not exist"
    exit 0
fi


	
export FSLDIR=/opt/fsl

#if image gen link exists remove 
rm -f $dirSubject"/QC/html/image_gen_links.js"

	
### T1 EXTRACTION ###
	echo ""
	echo "STARTING T1 EXTRACTION -------"
	#T1 extraction unmasked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh /T1/T1.nii.gz $dirSubject  T1_extraction_unmasked

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "ex_under" "../../T1/T1.nii.gz" "NA1" "NA1_link" "NA2" "NA2_link" 0


	#T1 extraction masked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /T1/T1_brain_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_extraction_masked

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "ex_under" "../../T1/T1.nii.gz" "ex_over1" "../../T1/T1_brain_mask.nii.gz" "NA3" "NA3_link" 0



### T1 SEGMENTATION ###
	echo ""
	echo "STARTING T1 SEGMENTATION -------"
	#T1 segmentation unlabelled WM
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /T1/T1_fast/T1_brain_WM_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_WM
		
		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "../../T1/T1.nii.gz" "uw_over1" "../../T1/T1_fast/T1_brain_WM_mask.nii.gz" "NA4" "NA4_link" 0


	#T1 segmentation unlabelled GM
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -a 45.0 -o /T1/T1_fast/T1_brain_GM_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_GM

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "ug_under" "../../T1/T1.nii.gz" "ug_over1" "../../T1/T1_fast/T1_brain_GM_mask.nii.gz" "NA5" "NA5_link" 0





	#T1 segmentation unlabelled subcort GM
		$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -o /T1/T1_first/subcort_GM.nii.gz  -x 28 -y 28 -z 28 /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_subcort_GM

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "us_under" "../../T1/T1.nii.gz" "us_over1" "../../T1/T1_first/subcort_GM.nii.gz" "NA7" "NA7_link" 0


	#T1 segmentation labelled cortex 3D/4D volume cort

		#label random big 
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /T1/labelled_GM.nii.gz -a 75.0 -p random_big -j label /T1/T1.nii.gz $dirSubject  T1_segmentation_labelled_cortex

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "lc_under" "../../T1/T1.nii.gz" "lc_over1" "../../T1/labelled_GM.nii.gz" "NA8" "NA8_link" 0


	#T1 segmentation labelled subcort GM volume subcort

		#label random big
		$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -o /T1/T1_first/T1_first_all_fast_firstseg.nii.gz -p random_big -a 40.0 -x 28 -y 28 -z 28 -j label /T1/T1.nii.gz $dirSubject  T1_segmentation_labelled_subcort_GM

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "ls_under" "../../T1/T1.nii.gz" "ls_over1" "../../T1/T1_first/T1_first_all_fast_firstseg.nii.gz" "NA9" "NA9_link" 0

		

	#T1 subcort unmasked
		$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -x 28 -y 28 -z 28 /T1/T1.nii.gz $dirSubject  T1_segmentation_unmasked_subcort

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "../../T1/T1.nii.gz" "NA10" "NA10_link" "NA11" "NA11_link" 0


### T1 REGISTRATION ###

	

	echo ""
	echo "STARTING T1 REGISTRATION -------"

	#T1 registration edges
		$BB_BIN_DIR/tvb_bb_QC/edges.sh -s ${FSLDIR}/data/standard -l 10 /MNI152_T1_1mm.nii.gz /T1/T1_brain_to_MNI.nii.gz $dirSubject  T1_registration 

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "re_under" "../../T1/T1_brain_to_MNI.nii.gz" "re_over1" "${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz" "NA12" "NA12_link" 0
		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "re_under" "${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz" "re_over1" "../../T1/T1_brain_to_MNI.nii.gz" "NA13" "NA13_link" 0


	#T2 registration edges


	if [ -e "$dirSubject/T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz" ]; then	#maybe -r if readable?
		$BB_BIN_DIR/tvb_bb_QC/edges.sh -s ${FSLDIR}/data/standard -l 10 /MNI152_T1_1mm.nii.gz /T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz $dirSubject  T2_registration
	
		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "Tre_under" "../../T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz" "Tre_over1" "${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz" "NA14" "NA14_link" 0
		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz" "uw_over1" "../../T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz" "NA15" "NA15_link" 0

	fi


### T2 FLAIR BIANCA ###
		
	if [ -e "$dirSubject/T2_FLAIR/T2_FLAIR_unbiased.nii.gz" ] && [ -e "$dirSubject/T2_FLAIR/lesions/final_mask.nii.gz" ]; then	

	#T2 FLAIR BIANCA unmasked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh /T2_FLAIR/T2_FLAIR_unbiased.nii.gz $dirSubject  T2_FLAIR_BIANCA_unmasked

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "Tbi_under" "../../T2_FLAIR/T2_FLAIR_unbiased.nii.gz" "NA16" "NA16_link" "NA17" "NA17_link" 0


	#T2 FLAIR BIANCA masked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /T2_FLAIR/lesions/final_mask.nii.gz /T2_FLAIR/T2_FLAIR_unbiased.nii.gz $dirSubject  T2_FLAIR_BIANCA_masked

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "Tbi_under" "../../T2_FLAIR/T2_FLAIR_unbiased.nii.gz" "Tbi_over1" "../../T2_FLAIR/lesions/final_mask.nii.gz" "NA18" "NA18_link" 0

	fi


### DTI ORIENTATION ###
	
	echo ""
	echo "STARTING DTI ORIENTATION -------"

	#DTI orientation

		#$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -t linevector -x 19 -y 32 -z 19 -X 950.0 -Y 850.0 -Z 800.0 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation 


	
	#DTI orientation with FA

		$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -o /dMRI/dMRI/dti_V1.nii.gz -j linevector -x 19 -y 32 -z 19 -X 950.0 -Y 850.0 -Z 800.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject DTI_orientation_with_FA 

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dorf_under" "../../dMRI/dMRI/dti_FA.nii.gz" "dorf_over1" "../../dMRI/dMRI/dti_V1.nii.gz" "NA19" "NA19_link" 0
  


	#DTI orientation-ranged FA
		
		$BB_BIN_DIR/tvb_bb_QC/ortho_appended.sh -x 19 -y 32 -z 19 -X 950.0 -Y 850.0 -Z 800.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject DTI_orientation_range_FA 

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "../../dMRI/dMRI/dti_FA.nii.gz" "NA20" "NA20_link" "NA21" "NA21_link" 0







### DTI EXTRACTION ###
	

	echo ""
	echo "STARTING DTI EXTRACTION -------"

	#DTI extraction unmasked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh /dMRI/dMRI/data_B0.nii.gz $dirSubject  DTI_extraction_unmasked

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "../../dMRI/dMRI/data_B0.nii.gz" "NA22" "NA22_link" "NA23" "NA23_link" 0


	#DTI extraction masked
		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /dMRI/dMRI/nodif_brain_mask.nii.gz /dMRI/dMRI/data_B0.nii.gz $dirSubject DTI_extraction_masked

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dex_under" "../../dMRI/dMRI/data_B0.nii.gz" "dex_over1" "../../dMRI/dMRI/nodif_brain_mask.nii.gz" "NA24" "NA24_link" 0




### DTI REGISTRATION ###
	echo ""
	echo "STARTING DTI REGISTRATION -------"

	#DTI registration

		#edges
		$BB_BIN_DIR/tvb_bb_QC/edges.sh -l 10 /dMRI/dMRI/transforms/DTI_to_T1.nii.gz /T1/T1.nii.gz $dirSubject  DTI_registration

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dre_under" "../../T1/T1.nii.gz" "dre_over1" "../../dMRI/dMRI/transforms/DTI_to_T1.nii.gz" "NA25" "NA25_link" 0
		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dre_under" "../../dMRI/dMRI/transforms/DTI_to_T1.nii.gz" "dre_over1" "../../T1/T1.nii.gz" "NA26" "NA26_link" 0



### DTI TRACTOGRAPHY ###
	echo ""
	echo "STARTING DTI TRACTOGRAPHY -------"



	#DTI tractography without excude

		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_FA

		#$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "uw_under" "../../dMRI/dMRI/dti_FA.nii.gz" "NA27" "NA27_link" "NA28" "NA28_link" 0


	#DTI tractography exclude without seed

		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /dMRI/probtrackx/exclude.nii.gz -p red-yellow -a 25.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_exclude

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dxc_under" "../../dMRI/dMRI/dti_FA.nii.gz" "dxc_over1" "../../dMRI/probtrackx/exclude.nii.gz" "NA29" "NA29_link" 0


	#DTI tractography seed only

		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /dMRI/probtrackx/labelledWM_GM.nii.gz -p blue-lightblue -a 100.0  /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_seeds

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dfs_under" "../../dMRI/dMRI/dti_FA.nii.gz" "dfs_over1" "../../fMRI/dMRI/probtrackx/labelledWM_GM.nii.gz" "NA30" "NA30_link" 0

	#DTI tractography seed only random big

		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /dMRI/probtrackx/labelledWM_GM.nii.gz -a 100.0 -p random_big -j label /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_seeds_rb

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dfsrb_under" "../../dMRI/dMRI/dti_FA.nii.gz" "dfsrb_over1" "../../dMRI/probtrackx/labelledWM_GM.nii.gz" "NA31" "NA31_link" 0



	#exclude with seed masks

		$BB_BIN_DIR/tvb_bb_QC/lightbox.sh -o /dMRI/probtrackx/exclude.nii.gz -p red-yellow -a 25.0 -s /dMRI/probtrackx/labelledWM_GM.nii.gz -h blue-lightblue -i 100.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_exclude_seeds

		$BB_BIN_DIR/tvb_bb_QC/image_gen_link.sh $dirSubject "dxs_under" "../../dMRI/dMRI/dti_FA.nii.gz" "dxs_over1" "../../dMRI/probtrackx/exclude.nii.gz" "NA32" "dMRI/probtrackx/labelledWM_GM.nii.gz" 1


export FSLDIR=/opt/HCPpipelines-4.1.3/fsl

### EDDY QUAD ###
	echo ""
	echo "STARTING EDDY QUAD -------"
	
	#EDDY QUAD

		eddy_quad_list=$origDir/eddy_quad_list.txt

		if [ ! -e "$eddy_quad_list" ]; then
			> $eddy_quad_list
		fi



		EDDY_QUAD_output_folder=$dirSubject/QC/eddyQUAD/data.qc
		
		


		rm -rf $EDDY_QUAD_output_folder
		

		${FSLDIR}/bin/eddy_quad $dirSubject/dMRI/dMRI/data -idx $dirSubject/dMRI/dMRI/eddy_index.txt -par $dirSubject/dMRI/dMRI/acqparams.txt -m $dirSubject/dMRI/dMRI/nodif_brain_mask.nii.gz -b $dirSubject/dMRI/dMRI/bvals -o $EDDY_QUAD_output_folder

		if [ $? -eq 0 ]; then
			if ![ grep -Fxq "$EDDY_QUAD_output_folder" $eddy_quad_list ]; then
				echo $EDDY_QUAD_output_folder >> $eddy_quad_list
			fi
		fi



### FC SC ###
	
	echo ""
	echo "STARTING FC SC -------"

	#FC SC PDF

		python $BB_BIN_DIR/tvb_bb_QC/SC_FC.py $dirSubject


### HTML REPORT GEN ###

	$BB_BIN_DIR/tvb_bb_QC/html_gen.sh  $dirSubject $1


. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer