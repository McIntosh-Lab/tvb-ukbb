#!/bin/bash


#SUBJECT FOLDER LIST TEXT FILE MUST END IN A NEWLINE
#after debugging, use a command line argument to grab this instead of hardcoding
subject_folder_list=/Users/justinwang/Documents/McIntosh/ukbbqc/QC/scripts/subject_folder_list.txt



#MAYBE SPLIT CODE INTO MULTIPLE SCRIPTS FOR READABILITY

T1_path=/T1/T1.nii.gz
T1_subcort_GM_path=/T1/T1_first/subcort_GM.nii.gz


#GM_mask WM_mask info

GM_mask_path=/T1/T1_fast/T1_brain_GM_mask.nii.gz
WM_mask_path=/T1/T1_fast/T1_brain_WM_mask.nii.gz

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
	

	for ((i=0; i<3; i++)); do

		#WM mask
		fsleyes render --outfile $output_folder/$sub"_T1_segmentation_WM_mask_"${axisNames[$i]}.png  --crop 30 --size 6400 2400 --scene lightbox --worldLoc 83.14004836092876 133.6544021423669 13.719280534934057 --displaySpace $subject_folder$T1_path --zaxis $i --sliceSpacing ${sliceSpacing[$i]} --zrange ${zrange[2*$i]} ${zrange[2*$i+1]} --ncols 6 --nrows 2 --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $subject_folder$T1_path --name "T1" --overlayType volume --alpha 100.0 --brightness 49.152368365123955 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 9.825064077362299 840.0450640773621 --clippingRange 9.825064077362299 830.22 --modulateRange 0.0 822.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 $subject_folder$WM_mask_path --name "T1_brain_WM_mask" --overlayType volume --alpha 25.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap red-yellow --negativeCmap greyscale --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0

		#GM mask
		fsleyes render --outfile $output_folder/$sub"_T1_segmentation_GM_mask_"${axisNames[$i]}.png  --crop 30 --size 6400 2400 --scene lightbox --worldLoc 83.14004836092876 133.6544021423669 13.719280534934057 --displaySpace $subject_folder$T1_path --zaxis $i --sliceSpacing ${sliceSpacing[$i]} --zrange ${zrange[2*$i]} ${zrange[2*$i+1]} --ncols 6 --nrows 2 --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $subject_folder$T1_path --name "T1" --overlayType volume --alpha 100.0 --brightness 49.152368365123955 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 9.825064077362299 840.0450640773621 --clippingRange 9.825064077362299 830.22 --modulateRange 0.0 822.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 $subject_folder$GM_mask_path --name "T1_brain_GM_mask" --overlayType volume --alpha 25.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap red-yellow --negativeCmap greyscale --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0

		#potential bugs: not sure how crop and size works here
		#not sure if zrange index arithmetic is being evaluated properly - may need $((expr))

		echo $sub T1 WM and GM images $(($i+1)) complete

	done




	pngappend_args_1=""
	pngappend_args_2=""

	for ((i=0; i<12; i++)); do

		#subcort GM
		fsleyes render --outfile $output_folder/$sub"_T1_segmentation_subcort_GM_"$(($i+1)).png  --crop 30 --size 6400 2400 --scene ortho --voxelLoc $(($startingx+$i*($endingx-$startingx)/11)) $(($startingy+$i*($endingy-$startingy)/11)) $(($startingz+$i*($endingz-$startingz)/11)) --displaySpace $subject_folder$T1_path --xcentre  0.05164 -0.10915 --ycentre  0.08699 -0.11782 --zcentre  0.14196 -0.00177 --xzoom 1663.1613102993372 --yzoom 1663.1613102993372 --zzoom 1663.1613102993372 --hideLabels --layout vertical --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 --movieSync $subject_folder$T1_path --name "T1" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 830.22 --clippingRange 0.0 830.22 --modulateRange 0.0 822.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 $subject_folder$T1_subcort_GM_path --name "subcort_GM" --overlayType volume --alpha 25.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap red-yellow --negativeCmap greyscale --displayRange 0.0 1.01 --clippingRange 0.0 1.01 --modulateRange 0.0 1.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0
		

		if [[ i -lt 6 ]] 
		then
			pngappend_args_1="$pngappend_args_1 $output_folder/$sub"_T1_segmentation_subcort_GM_"$(($i+1)).png +"
		else
			pngappend_args_2="$pngappend_args_2 $output_folder/$sub"_T1_segmentation_subcort_GM_"$(($i+1)).png +"
		fi

		echo $sub T1 subcort GM image $(($i+1)) complete


	done
	

	pngappend ${pngappend_args_1%+} $output_folder/$sub"_T1_segmentation_subcort_GM_"first_half.png
	pngappend ${pngappend_args_2%+} $output_folder/$sub"_T1_segmentation_subcort_GM_"second_half.png
	pngappend $output_folder/$sub"_T1_segmentation_subcort_GM_"first_half.png - $output_folder/$sub"_T1_segmentation_subcort_GM_"second_half.png $output_folder/$sub"_T1_segmentation_subcort_GM_"appended.png

	rm $output_folder/$sub"_T1_segmentation_subcort_GM_"first_half.png
	rm $output_folder/$sub"_T1_segmentation_subcort_GM_"second_half.png
	for ((i=0; i<12; i++)); do
		rm $output_folder/$sub"_T1_segmentation_subcort_GM_"$(($i+1)).png
	done
done


 





 



