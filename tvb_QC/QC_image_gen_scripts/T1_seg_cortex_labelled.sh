

#!/bin/bash


#SUBJECT FOLDER LIST TEXT FILE MUST END IN A NEWLINE
#after debugging, use a command line argument to grab this instead of hardcoding
subject_folder_list=/Users/justinwang/Documents/McIntosh/ukbbqc/QC/scripts/subject_folder_list.txt



#MAYBE SPLIT CODE INTO MULTIPLE SCRIPTS FOR READABILITY

T1_path=/T1/T1.nii.gz

cortex_labelled_mask_path=/T1/labelled_GM.nii.gz

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


cat $subject_folder_list | while read subject_folder; do

	output_folder=$subject_folder/QC/images/T1_segmentation
	mkdir -p $output_folder
	sub=$(basename $subject_folder)
	

	for ((i=0; i<3; i++)); do

		fsleyes render --outfile $output_folder/$sub"_T1_segmentation_cortex_labelled_"${axisNames[$i]}.png --crop 30 --scene lightbox --worldLoc 83.14004836092876 133.6544021423669 13.719280534934057 --displaySpace $subject_folder$T1_path --zaxis $i --sliceSpacing ${sliceSpacing[$i]} --zrange ${zrange[2*$i]} ${zrange[2*$i+1]} --ncols 6 --nrows 2 --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $subject_folder$T1_path --name "T1" --overlayType volume --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale --negativeCmap greyscale --displayRange 9.825064077362299 840.0450640773621 --clippingRange 9.825064077362299 830.22 --modulateRange 0.0 822.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0 $subject_folder$cortex_labelled_mask_path --name "labelled_GM" --overlayType volume --alpha 75.0 --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap cortical --negativeCmap greyscale --displayRange 0.0 699.93 --clippingRange 0.0 699.93 --modulateRange 0.0 693.0 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0

		#need crop
		#maybe clipping range and display range need to be standardized or left unchanged from default
		#replace analysis type with variable

		#potential bugs: not sure how crop and size works here
		#not sure if zrange index arithmetic is being evaluated properly - may need $((expr))

		echo $sub T1 cortex labelled images $(($i+1)) complete

	done



done


 





 



