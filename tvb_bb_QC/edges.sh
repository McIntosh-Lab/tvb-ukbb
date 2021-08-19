#!/bin/bash


limit=10

flag=0
standard_folder=""

while getopts ":s:l:" opt; do
  case $opt in
    s)		#overlay file
      standard_folder=$OPTARG
      flag=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    l)
    limit=$OPTARG
    ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac


done
shift "$((OPTIND-1))"


declare -a axes
axes[0]=x
axes[1]=y
axes[2]=z

declare -a axisNames 
axisNames[0]=saggital
axisNames[1]=coronal
axisNames[2]=axial



subject_folder=$3

	output_folder=$subject_folder/QC/images/$4
	mkdir -p $output_folder
	sub=$(basename $subject_folder)
	
	arguments1=""	#order 1
	arguments2=""


	pngappend_args_1_1=""	#order 1, 1st row
	pngappend_args_1_2=""
	pngappend_args_1_3=""
	pngappend_args_2_1=""
	pngappend_args_2_2=""
	pngappend_args_2_3=""
	

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

	declare -a pngappend_args_1_3
	pngappend_args_2_2[0]=""
	pngappend_args_2_2[1]=""
	pngappend_args_2_2[2]=""

	declare -a pngappend_args_2_3
	pngappend_args_2_2[0]=""
	pngappend_args_2_2[1]=""
	pngappend_args_2_2[2]=""


	for ((i=0; i<18; i++)); do 
		for ((j=0; j<3; j++)); do
			
			arguments1="$arguments1 -${axes[$j]} $(echo "scale=9;$limit/100+(((100-2*$limit)/100)/17)*$i" | bc)
 $output_folder/order1_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png"
			arguments2="$arguments2 -${axes[$j]} $(echo "scale=9;$limit/100+(((100-2*$limit)/100)/17)*$i" | bc)
 $output_folder/order2_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png"

			if [[ i -lt 6 ]] 
			then
				pngappend_args_1_1[$j]="${pngappend_args_1_1[$j]} $output_folder/order1_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
				pngappend_args_2_1[$j]="${pngappend_args_2_1[$j]} $output_folder/order2_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
			elif [[ i -lt 12 ]]
			then
				pngappend_args_1_2[$j]="${pngappend_args_1_2[$j]} $output_folder/order1_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
				pngappend_args_2_2[$j]="${pngappend_args_2_2[$j]} $output_folder/order2_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
			else
				pngappend_args_1_3[$j]="${pngappend_args_1_3[$j]} $output_folder/order1_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
				pngappend_args_2_3[$j]="${pngappend_args_2_3[$j]} $output_folder/order2_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png +"
			fi

		done
	done


	if [ "$flag" -eq "1" ]; then
	${FSLDIR}/bin/slicer $standard_folder$1 $subject_folder$2 $arguments1
	${FSLDIR}/bin/slicer $subject_folder$2 $standard_folder$1 $arguments2
			
	else
	${FSLDIR}/bin/slicer $subject_folder$1 $subject_folder$2 $arguments1
	${FSLDIR}/bin/slicer $subject_folder$2 $subject_folder$1 $arguments2

	fi




	for ((j=0; j<3; j++)); do
		
		order1_firsthalf=${pngappend_args_1_1[$j]}
		order1_secondhalf=${pngappend_args_1_2[$j]}
		order1_thirdpart=${pngappend_args_1_3[$j]}

		${FSLDIR}/bin/pngappend ${order1_firsthalf%+} $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_first_half.png"
		
		${FSLDIR}/bin/pngappend ${order1_secondhalf%+} $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_second_half.png"

		${FSLDIR}/bin/pngappend ${order1_thirdpart%+} $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_third_part.png"

		${FSLDIR}/bin/pngappend $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_first_half.png" - $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_second_half.png" - $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_third_part.png" $output_folder/order1_$sub"_$4_"${axisNames[$j]}"_appended.png"
	

		order2_firsthalf=${pngappend_args_2_1[$j]}
		order2_secondhalf=${pngappend_args_2_2[$j]}
		order2_thirdpart=${pngappend_args_2_3[$j]}

		${FSLDIR}/bin/pngappend ${order2_firsthalf%+} $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_first_half.png"
		
		${FSLDIR}/bin/pngappend ${order2_secondhalf%+} $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_second_half.png"

		${FSLDIR}/bin/pngappend ${order2_thirdpart%+} $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_third_part.png"

		${FSLDIR}/bin/pngappend $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_first_half.png" - $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_second_half.png" - $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_third_part.png" $output_folder/order2_$sub"_$4_"${axisNames[$j]}"_appended.png"

	done

	for ((i=1; i<3; i++)); do
		for ((j=0; j<3; j++)); do

			rm -f $output_folder/order$i"_"$sub"_$4_"${axisNames[$j]}"_first_half.png"
			rm -f $output_folder/order$i"_"$sub"_$4_"${axisNames[$j]}"_second_half.png"
			rm -f $output_folder/order$i"_"$sub"_$4_"${axisNames[$j]}"_third_part.png"

		done
	done


	for ((i=0; i<18; i++)); do
		for ((j=0; j<3; j++)); do
			rm -f $output_folder/order1_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png
			rm -f $output_folder/order2_$sub"_$4_"${axisNames[$j]}_$(($i+1)).png
		done
	done





