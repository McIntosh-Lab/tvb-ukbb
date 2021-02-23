#!/bin/sh
#
# Script name: tvb_bb_QC_images.sh
#
# Description: Script to generate QC images 
#
## Author: Justin Wang


set -x

origDir=`pwd`

dirScript=`dirname $0`

dirSubject=`pwd`/$1

if [[ "$dirSubject" == "" ]] ; then
    echo "Error: The selected subject does not exist"
    exit 0
fi






### T1 EXTRACTION ###
	echo ""
	echo "STARTING T1 EXTRACTION -------"
	#T1 extraction unmasked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh /T1/T1.nii.gz $dirSubject  T1_extraction_unmasked


	#T1 extraction masked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /T1/T1_brain_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_extraction_masked




### T1 SEGMENTATION ###
	echo ""
	echo "STARTING T1 SEGMENTATION -------"
	#T1 segmentation unlabelled WM
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /T1/T1_fast/T1_brain_WM_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_WM


	#T1 segmentation unlabelled GM
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /T1/T1_fast/T1_brain_GM_mask.nii.gz /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_GM


	#T1 segmentation unlabelled subcort GM
		$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -o /T1/T1_first/subcort_GM.nii.gz  -x 28 -y 28 -z 28 /T1/T1.nii.gz $dirSubject  T1_segmentation_unlabelled_subcort_GM


	#T1 segmentation labelled cortex 3D/4D volume cort

		#label random big 
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /T1/labelled_GM.nii.gz -a 75.0 -p random_big -j label /T1/T1.nii.gz $dirSubject  T1_segmentation_labelled_cortex


	#T1 segmentation labelled subcort GM volume subcort

		#label random big
		$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -o /T1/T1_first/T1_first_all_fast_firstseg.nii.gz -p random_big -a 40.0 -x 28 -y 28 -z 28 -j label /T1/T1.nii.gz $dirSubject  T1_segmentation_labelled_subcort_GM

		#might need more opaque subcort than 25

	#T1 subcort unmasked
		$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -x 28 -y 28 -z 28 /T1/T1.nii.gz $dirSubject  T1_segmentation_unmasked_subcort


### T1 REGISTRATION ###

	

	echo ""
	echo "STARTING T1 REGISTRATION -------"

	#T1 registration edges
		$BB_BIN_DIR/tvb_bb_QC_images/edges.sh -s /usr/local/fsl/data/standard -l 10 /MNI152_T1_1mm.nii.gz /T1/T1_brain_to_MNI.nii.gz $dirSubject  T1_registration 


	#T2 registration edges


	if [ -e "$dirSubject/T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz" ]; then	#maybe -r if readable?
		$BB_BIN_DIR/tvb_bb_QC_images/edges.sh -s /usr/local/fsl/data/standard -l 10 /MNI152_T1_1mm.nii.gz /T2_FLAIR/T2_FLAIR_brain_to_MNI.nii.gz $dirSubject  T2_registration
	fi


### T2 FLAIR BIANCA ###
		
	if [ -e "$dirSubject/T2_FLAIR/T2_FLAIR_unbiased.nii.gz" ] && [ -e "$dirSubject/T2_FLAIR/lesions/final_mask.nii.gz" ]; then	

	#T2 FLAIR BIANCA unmasked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh /T2_FLAIR/T2_FLAIR_unbiased.nii.gz $dirSubject  T2_FLAIR_BIANCA_unmasked


	#T2 FLAIR BIANCA masked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /T2_FLAIR/lesions/final_mask.nii.gz /T2_FLAIR/T2_FLAIR_unbiased.nii.gz $dirSubject  T2_FLAIR_BIANCA_masked

	fi


### DTI ORIENTATION ###
	
	echo ""
	echo "STARTING DTI ORIENTATION -------"

	#DTI orientation

		$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 19 -y 32 -z 19 -X 950.0 -Y 850.0 -Z 800.0 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed #RENAME THIS ANALYSIS





	#DTI orientation with zoom


	    	#bottom rear sag

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 31 -y 39 -z 19 -X 1488.88 -Y 1488.88 -Z 1488.88 -u "-0.16553 -0.41348" -v "-0.25495 -0.37302" -w "-0.25495 -0.23586" -O 0 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_bottom_rear_sagg



			#mid sag

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 45 -y 50 -z 29 -X 1572.0626630056795 -Y 1572.0626630056795 -Z 1572.0626630056795 -u "0.04444 -0.08390" -v "0.01729 -0.16652" -w "0.01729 -0.03434" -O 0 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_mid_sagg




			#axial lower bowl

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 48 -y 26 -z 22 -X 1537.0700670492533 -Y 1537.0700670492533 -Z 1537.0700670492533 -u "-0.22464 -0.02845" -v "0.07287 -0.34033" -w "0.00811 -0.43436" -O 2 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_lower_bowl_axial


			#axial higher v

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 49 -y 64 -z 32 -X 1993.8299292218476 -Y 1993.8299292218476 -Z 1993.8299292218476 -u "-0.03024 -0.03087" -v "0.04906 -0.21300" -w "0.02904  0.35601" -O 2 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_higher_v_axial



			#axial lower v

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 47 -y 33 -z 30 -X 1990.8519592114844 -Y 1990.8519592114844 -Z 1990.8519592114844 -u "-0.02703 -0.03071" -v "0.05115 -0.21348" -w "-0.00571 -0.30119" -O 2 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_lower_v_axial


			#axial centre x

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 48 -y 47 -z 34 -X 1394.8067258798533 -Y 1394.8067258798533 -Z 1394.8067258798533 -u "-0.14188 -0.04676" -v "0.07141 -0.41301" -w "0.01221 -0.01137" -O 2 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_centre_x_axial



			#coronal top branch

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 48 -y 45 -z 39 -X 1370.4184176098597 -Y 1370.4184176098597 -Z 1370.4184176098597 -u "-0.05695  0.01253" -v "0.02023  0.18980" -w "-0.03895 -0.09370" -O 1 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_top_branch_coronal



			#coronal horizontal log

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 49 -y 59 -z 33 -X 1955.9903225991852 -Y 1955.9903225991852 -Z 1955.9903225991852 -u "0.08949  0.01840" -v "0.03583  0.02059" -w "0.02844  0.07088" -O 1 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_horizontal_log_coronal



			#coronal lower brances

			$BB_BIN_DIR/tvb_bb_QC_images/ortho_appended.sh -t linevector -x 48 -y 45 -z 20 -X 1257.1720420981692 -Y 1257.1720420981692 -Z 1257.1720420981692 -u "-0.19215  0.07666" -v "0.00079 -0.34720" -w "-0.15298 -0.23356" -O 1 /dMRI/dMRI/dti_V1.nii.gz $dirSubject DTI_orientation_zoomed_lower_branches_coronal






### DTI EXTRACTION ###
	

	echo ""
	echo "STARTING DTI EXTRACTION -------"

	#DTI extraction unmasked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh /dMRI/dMRI/data_B0.nii.gz $dirSubject  DT1_extraction_unmasked



	#DTI extraction masked
		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /dMRI/dMRI/nodif_brain_mask.nii.gz /dMRI/dMRI/data_B0.nii.gz $dirSubject DT1_extraction_masked




### DTI REGISTRATION ###
	echo ""
	echo "STARTING DTI REGISTRATION -------"

	#DTI registration

		#edges
		$BB_BIN_DIR/tvb_bb_QC_images/edges.sh -l 10 /dMRI/dMRI/transforms/DTI_to_T1.nii.gz /T1/T1.nii.gz $dirSubject  DTI_registration



### DTI TRACTOGRAPHY ###
	echo ""
	echo "STARTING DTI TRACTOGRAPHY -------"



	#DTI tractography without excude

		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_FA


	#DTI tractography without seed

		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /dMRI/probtrackx/exclude.nii.gz -p red-yellow -a 25.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_exclude



	#with seed masks

		$BB_BIN_DIR/tvb_bb_QC_images/lightbox.sh -o /dMRI/probtrackx/exclude.nii.gz -p red-yellow -a 25.0 -s /dMRI/probtrackx/labelledWM_GM.nii.gz -h blue-lightblue -i 100.0 /dMRI/dMRI/dti_FA.nii.gz $dirSubject  DTI_tractography_exclude_seeds


### EDDY QUAD ###
	echo ""
	echo "STARTING EDDY QUAD -------"
	
	#EDDY QUAD

		eddy_quad_list=$origDir/eddy_quad_list.txt

		if ! [ -e "$eddy_quad_list" ]; then
			> $eddy_quad_list
		fi



			EDDY_QUAD_output_folder=$dirSubject/QC/eddyQUAD/data.qc
			
			echo $EDDY_QUAD_output_folder >> $eddy_quad_list



			rm -r $EDDY_QUAD_output_folder
			

			eddy_quad $dirSubject/dMRI/dMRI/data -idx $dirSubject/dMRI/dMRI/eddy_index.txt -par $dirSubject/dMRI/dMRI/acqparams.txt -m $dirSubject/dMRI/dMRI/nodif_brain_mask.nii.gz -b $dirSubject/dMRI/dMRI/bvals -o $EDDY_QUAD_output_folder

  



### FC SC ###
	
	echo ""
	echo "STARTING FC SC -------"

	#FC SC PDF

		python $BB_BIN_DIR/tvb_bb_QC_images/SC_FC.py $dirSubject

