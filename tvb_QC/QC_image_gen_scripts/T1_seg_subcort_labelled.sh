


#!/bin/bash


#SUBJECT FOLDER LIST TEXT FILE MUST END IN A NEWLINE
#after debugging, use a command line argument to grab this instead of hardcoding
subject_folder_list=/Users/justinwang/Documents/McIntosh/ukbbqc/QC/scripts/subject_folder_list.txt



#MAYBE SPLIT CODE INTO MULTIPLE SCRIPTS FOR READABILITY

T1_path=/T1/T1.nii.gz
T1_subcort_labelled_path=/T1/labelled_GM.nii.gz
#change to a more general var name like overlay path


declare -a axisNames 
axisNames[0]=saggital
axisNames[1]=coronal
axisNames[2]=axial


declare -a sliceSpacing 
sliceSpacing[0]=11.7314522382178
sliceSpacing[1]=15.588071091677588 
sliceSpacing[2]=12.501935729781382


declare -a zrange
zrange[0]=19.475817551309607
zrange[1]=157.8622150903458

zrange[2]=13.48601656609481
zrange[3]=198.76844135621496

zrange[4]=24.27365538949095
zrange[5]=177.67850061440535 

#subcort ranges
startingx=50
endingx=130
startingy=75
endingy=160
startingz=75
endingz=135

cat $subject_folder_list | while read subject_folder; do

	output_folder=$subject_folder/QC/images/T1_segmentation
	mkdir -p $output_folder
	sub=$(basename $subject_folder)
	

	pngappend_args_1=""
	pngappend_args_2=""

	for ((i=0; i<12; i++)); do


		fsleyes render --outfile $output_folder/$sub"_T1_segmentation_subcort_labelled_"$(($i+1)).png  --crop 30 --scene ortho --voxelLoc $(($startingx+$i*($endingx-$startingx)/11)) $(($startingy+$i*($endingy-$startingy)/11)) $(($startingz+$i*($endingz-$startingz)/11)) --displaySpace $subject_folder$T1_path --xcentre  0.05045 -0.11195 --ycentre -0.00206 -0.12445 --zcentre  0.08578  0.03278 --xzoom 1788.280978144212 --yzoom 1788.280978144212 --zzoom 1788.280978144212 --hideLabels --layout vertical --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $subject_folder$T1_path --name "T1" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 830.22 --clippingRange 0.0 830.22 --modulateRange 0.0 822.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 $subject_folder$T1_subcort_labelled_path --name "labelled_GM" --overlayType volume --alpha 25.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap subcortical --negativeCmap greyscale --displayRange 0.0 699.93 --clippingRange 0.0 699.93 --modulateRange 0.0 693.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0

			#what is ycentre? 0.08699? probably just positioning of image in xyz space - doesnt affect slicing 
			#different xyz zooms for subcorts vs regular

		

		if [[ i -lt 6 ]] 
		then
			pngappend_args_1="$pngappend_args_1 $output_folder/$sub"_T1_segmentation_subcort_labelled_"$(($i+1)).png +"
		else
			pngappend_args_2="$pngappend_args_2 $output_folder/$sub"_T1_segmentation_subcort_labelled_"$(($i+1)).png +"
		fi

		echo $sub T1 subcort labelled image $(($i+1)) complete


	done

	pngappend ${pngappend_args_1%+} $output_folder/$sub"_T1_segmentation_subcort_labelled_"first_half.png
	pngappend ${pngappend_args_2%+} $output_folder/$sub"_T1_segmentation_subcort_labelled_"second_half.png
	pngappend $output_folder/$sub"_T1_segmentation_subcort_labelled_"first_half.png - $output_folder/$sub"_T1_segmentation_subcort_labelled_"second_half.png $output_folder/$sub"_T1_segmentation_subcort_labelled_"appended.png

	rm $output_folder/$sub"_T1_segmentation_subcort_labelled_"first_half.png
	rm $output_folder/$sub"_T1_segmentation_subcort_labelled_"second_half.png
	for ((i=0; i<12; i++)); do
		rm $output_folder/$sub"_T1_segmentation_subcort_labelled_"$(($i+1)).png
	done
done


 





 



