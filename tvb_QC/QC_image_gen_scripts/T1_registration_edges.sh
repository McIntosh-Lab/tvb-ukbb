#!/bin/bash



#SUBJECT FOLDER LIST TEXT FILE MUST END IN A NEWLINE
#after debugging, use a command line argument to grab this instead of hardcoding
subject_folder_list=/Users/justinwang/Documents/McIntosh/ukbbqc/QC/scripts/subject_folder_list.txt




#MAYBE SPLIT CODE INTO MULTIPLE SCRIPTS FOR READABILITY


T1_brain_to_MNI_path=/T1/T1_brain_to_MNI.nii.gz
MNI152_T1_1mm_path=/MNI152_T1_1mm.nii.gz
standard_folder=/usr/local/fsl/data/standard

declare -a axes
axes[0]=x
axes[1]=y
axes[2]=z

declare -a axisNames 
axisNames[0]=saggital
axisNames[1]=coronal
axisNames[2]=axial


declare -a sliceSpacing 
sliceSpacing[0]=12
sliceSpacing[1]=16
sliceSpacing[2]=13


declare -a zrange
zrange[0]=22
#zrange[1]=157.8622150903458

zrange[1]=16
#zrange[3]=198.76844135621496

zrange[2]=24
#zrange[5]=177.67850061440535 



cat $subject_folder_list | while read subject_folder; do

	output_folder=$subject_folder/QC/images/T1_preprocess_registration/edges
	mkdir -p $output_folder
	sub=$(basename $subject_folder)
	
	arguments1=""
	arguments2=""
	#in case scope doesnt reset for each while loop iteration


	pngappend_args_1_1=""
	pngappend_args_1_2=""
	pngappend_args_2_1=""
	pngappend_args_2_2=""
	

	declare -a pngappend_args_1_1
	pngappend_args_1_1[0]=""
	pngappend_args_1_1[1]=""
	pngappend_args_1_1[2]=""

	declare -a pngappend_args_2_1
	pngappend_args_2_1[0]=""
	pngappend_args_2_1[1]=""
	pngappend_args_2_1[2]=""

	declare -a pngappend_args_1_2
	pngappend_args_1_2[0]=""
	pngappend_args_1_2[1]=""
	pngappend_args_1_2[2]=""

	declare -a pngappend_args_2_2
	pngappend_args_2_2[0]=""
	pngappend_args_2_2[1]=""
	pngappend_args_2_2[2]=""


	for ((i=0; i<12; i++)); do 
		for ((j=0; j<3; j++)); do
			
			#maybe arugments order1
			arguments1="$arguments1 -${axes[$j]} -$((${zrange[$j]}+${sliceSpacing[$j]}*$i)) $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png"
			arguments2="$arguments2 -${axes[$j]} -$((${zrange[$j]}+${sliceSpacing[$j]}*$i)) $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png"
			#echo "created args for $sub axis ${axisNames[$j]} slice $(($i+1))"

			if [[ i -lt 6 ]] 
			then
				pngappend_args_1_1[$j]="${pngappend_args_1_1[$j]} $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png +"
				pngappend_args_2_1[$j]="${pngappend_args_2_1[$j]} $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png +"
			else
				pngappend_args_1_2[$j]="${pngappend_args_1_2[$j]} $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png +"
				pngappend_args_2_2[$j]="${pngappend_args_2_2[$j]} $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png +"
			fi

		done
	done

	slicer $standard_folder$MNI152_T1_1mm_path $subject_folder$T1_brain_to_MNI_path $arguments1
	#echo "done 1"
	slicer $subject_folder$T1_brain_to_MNI_path $standard_folder$MNI152_T1_1mm_path $arguments2
	#echo "done 2"
	echo "done $sub"

	for ((j=0; j<3; j++)); do
		
		order1_firsthalf=${pngappend_args_1_1[$j]}
		order1_secondhalf=${pngappend_args_1_2[$j]}

		pngappend ${order1_firsthalf%+} $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_first_half.png"
		
		pngappend ${order1_secondhalf%+} $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_second_half.png"

		pngappend $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_first_half.png" - $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_second_half.png" $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_appended.png"
	

		order2_firsthalf=${pngappend_args_2_1[$j]}
		order2_secondhalf=${pngappend_args_2_2[$j]}

		pngappend ${order2_firsthalf%+} $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_first_half.png"
		
		pngappend ${order2_secondhalf%+} $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_second_half.png"

		pngappend $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_first_half.png" - $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_second_half.png" $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}"_appended.png"

	done

	for ((i=1; i<3; i++)); do
		for ((j=0; j<3; j++)); do

			rm $output_folder/order$i"_"$sub"_T1_preprocess_registration_"${axisNames[$j]}"_first_half.png"
			rm $output_folder/order$i"_"$sub"_T1_preprocess_registration_"${axisNames[$j]}"_second_half.png"

		done
	done


	for ((i=0; i<12; i++)); do
		for ((j=0; j<3; j++)); do
			rm $output_folder/order1_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png
			rm $output_folder/order2_$sub"_T1_preprocess_registration_"${axisNames[$j]}_$(($i+1)).png
		done
	done

done	




