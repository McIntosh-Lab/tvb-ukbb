#!/bin/bash




overlay=""
overlay_args=""
flag=0

alpha=25.0
cmap=red-yellow

label_or_volume="volume"
underlay_type="volume"
xlimit=10
ylimit=10
zlimit=10
xzoom=1588.280978144212 #subcort zoom
yzoom=1588.280978144212
zzoom=1588.280978144212
xcentre="0.05045 -0.11195"
ycentre="-0.00206 -0.12445"
zcentre="0.08578  0.03278"
orientation=0
single_orientation=0

while getopts ":o:a:p:j:t:x:y:z:X:Y:Z:u:v:w:O:" opt; do
  case $opt in
    o)		#overlay file
      overlay=$OPTARG
      flag=1
      ;;
    
    a)		#overlay alpha value
      alpha=$OPTARG
      flag=1
      ;;
    p)		#overlay cmap value
      cmap=$OPTARG
      
      flag=1
      ;;
    
    j)
    label_or_volume=$OPTARG
      flag=1
      ;;
    t)
	underlay_type=$OPTARG
	;;
	x)
	xlimit=$OPTARG
	;;
	y)
	ylimit=$OPTARG
	;;
	z)
	zlimit=$OPTARG
	;;
	X)
	xzoom=$OPTARG
	;;
	Y)
	yzoom=$OPTARG
	;;
	Z)
	zzoom=$OPTARG
	;;
	u)
	xcentre=$OPTARG
	;;
	v)
	ycentre=$OPTARG
	;;
	w)
	zcentre=$OPTARG
	;;
	O)
	orientation=$OPTARG
	single_orientation=1
	;;


    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac


done
shift "$((OPTIND-1))"

if [ "$flag" -eq "1" ]; then
	if [ "$overlay" = "" ]; then
		echo "ERROR: Overlay display options require overlay option and overlay argument (-o)." >&2
     	exit 1
	fi
fi

underlay=$1


declare -a axisNames 
axisNames[0]=saggital
axisNames[1]=coronal
axisNames[2]=axial


declare -a hide_combo
hide_combo[0]="--hidey --hidez"
hide_combo[1]="--hidex --hidez"
hide_combo[2]="--hidex --hidey"


overlay_template=""
if [ "$label_or_volume" = "volume" ]; then
	overlay_template="--overlayType volume --alpha $alpha --brightness 49.75000000000001 --contrast 49.90029860765409 --cmap $cmap --negativeCmap greyscale --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 100 --blendFactor 0.1 --smoothing 0 --resolution 100 --numInnerSteps 10 --clipMode intersection --volume 0"
elif [ "$label_or_volume" = "label" ]; then 
	overlay_template="--overlayType label --alpha $alpha --brightness 49.75000000000001 --contrast 49.90029860765409 --lut $cmap --outlineWidth 1 --volume 0"
else
	overlay_template="--overlayType linevector --alpha 100.0 --brightness 50.0 --contrast 50.0 --cmap greyscale --lineWidth 1.0 --lengthScale 100.0 --xColour 1.0 0.0 0.0 --yColour 0.0 1.0 0.0 --zColour 0.0 0.0 1.0 --suppressMode white"
fi



subject_folder=$2

	dim1=`${FSLDIR}/bin/fslval $subject_folder$underlay dim1`
	dim2=`${FSLDIR}/bin/fslval $subject_folder$underlay dim2`
	dim3=`${FSLDIR}/bin/fslval $subject_folder$underlay dim3`

	#use if voxel loc depends on pixdim
	#pixdim1=`${FSLDIR}/bin/fslval $subject_folder$underlay pixdim1`
	#pixdim2=`${FSLDIR}/bin/fslval $subject_folder$underlay pixdim2`
	#pixdim3=`${FSLDIR}/bin/fslval $subject_folder$underlay pixdim3`
	#dim1=$(echo "scale=4;$dim1 * $pixdim1" | bc)
	#dim2=$(echo "scale=4;$dim2 * $pixdim2" | bc)
	#dim3=$(echo "scale=4;$dim3 * $pixdim3" | bc)



	startingx=$(echo "scale=4;$dim1 * $xlimit/100" | bc) #`$(($dim1*$xlimit/100)) | bc` #10 #50
	endingx=$(echo "scale=4;$dim1 * (100-$xlimit)/100" | bc)  #$(($dim1*$((100-$xlimit))/100)) #95 #130
	startingy=$(echo "scale=4;$dim2 * $ylimit/100" | bc) #$(($dim2*$ylimit/100)) #10 #75
	endingy=$(echo "scale=4;$dim2 * (100-$ylimit)/100" | bc) #$(($dim2*$((100-$ylimit))/100)) #95 #160
	startingz=$(echo "scale=4;$dim3 * $zlimit/100" | bc) #$(($dim3*$zlimit/100)) #10 #75
	endingz=$(echo "scale=4;$dim3 * (100-$zlimit)/100" | bc) #$(($dim3*$((100-$zlimit))/100)) #65 #135



	output_folder=$subject_folder/QC/images/$3
	mkdir -p $output_folder
	sub=$(basename $subject_folder)
	
	if [ "$flag" -eq "1" ]; then
		
		overlay_args="$subject_folder$overlay --name "overlay" $overlay_template"
	fi


	pngappend_args_1=""
	pngappend_args_2=""
	pngappend_args_3=""


	declare -a pngappend_args_1
	pngappend_args_1[0]=""
	pngappend_args_1[1]=""
	pngappend_args_1[2]=""

	declare -a pngappend_args_2
	pngappend_args_2[0]=""
	pngappend_args_2[1]=""
	pngappend_args_2[2]=""

	declare -a pngappend_args_3
	pngappend_args_3[0]=""
	pngappend_args_3[1]=""
	pngappend_args_3[2]=""


	for ((i=0; i<18; i++)); do
		for ((j=0; j<3; j++)); do
			if { [ "$single_orientation" -eq "1" ] && [ "$j" -eq "$orientation" ]; } || [ "$single_orientation" -eq "0" ]; then
				
				xVoxelLoc=$(echo "scale=4;$startingx+$i*($endingx-$startingx)/17" | bc)
				yVoxelLoc=$(echo "scale=4;$startingy+$i*($endingy-$startingy)/17" | bc)
				zVoxelLoc=$(echo "scale=4;$startingz+$i*($endingz-$startingz)/17" | bc)

				xVoxelLoc=${xVoxelLoc%.*}
				yVoxelLoc=${yVoxelLoc%.*}
				zVoxelLoc=${zVoxelLoc%.*}

				${FSLDIR}/bin/fsleyes render --outfile $output_folder/$sub"_$3_""${axisNames[$j]}"_$(($i+1)).png  --scene ortho --voxelLoc $xVoxelLoc $yVoxelLoc $zVoxelLoc --displaySpace $subject_folder$underlay --xcentre  $xcentre --ycentre $ycentre --zcentre $zcentre --xzoom $xzoom --yzoom $yzoom --zzoom $zzoom --hideLabels --layout vertical ${hide_combo[$j]} --hideCursor --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 $subject_folder$underlay --name "underlay" --overlayType $underlay_type --alpha 100.0 --brightness 49.74999999999999 --contrast 49.90029860765409 --cmap greyscale  $overlay_args 



				if [[ i -lt 6 ]] 
				then
					pngappend_args_1[$j]="${pngappend_args_1[$j]} $output_folder/$sub"_$3_""${axisNames[$j]}"_$(($i+1)).png + 10"
				elif [[ i -lt 12 ]]
				then
					pngappend_args_2[$j]="${pngappend_args_2[$j]} $output_folder/$sub"_$3_""${axisNames[$j]}"_$(($i+1)).png + 10"
				else
					pngappend_args_3[$j]="${pngappend_args_3[$j]} $output_folder/$sub"_$3_""${axisNames[$j]}"_$(($i+1)).png + 10"
				fi

			fi
		done
	done
	

	for ((j=0; j<3; j++)); do
		if { [ "$single_orientation" -eq "1" ] && [ "$j" -eq "$orientation" ]; } || [ "$single_orientation" -eq "0" ]; then
			firsthalf=${pngappend_args_1[$j]}
			secondhalf=${pngappend_args_2[$j]}
			thirdpart=${pngappend_args_3[$j]}

			${FSLDIR}/bin/pngappend ${firsthalf%+*} $output_folder/$sub"_$3_"${axisNames[$j]}"_first_half.png"
			
			${FSLDIR}/bin/pngappend ${secondhalf%+*} $output_folder/$sub"_$3_"${axisNames[$j]}"_second_half.png"

			${FSLDIR}/bin/pngappend ${thirdpart%+*} $output_folder/$sub"_$3_"${axisNames[$j]}"_third_part.png"

			${FSLDIR}/bin/pngappend $output_folder/$sub"_$3_"${axisNames[$j]}"_first_half.png" - 10 $output_folder/$sub"_$3_"${axisNames[$j]}"_second_half.png" - 10 $output_folder/$sub"_$3_"${axisNames[$j]}"_third_part.png" $output_folder/$sub"_$3_"${axisNames[$j]}"_appended.png"
		fi
	done

	
	for ((j=0; j<3; j++)); do
		if { [ "$single_orientation" -eq "1" ] && [ "$j" -eq "$orientation" ]; } || [ "$single_orientation" -eq "0" ]; then
			rm $output_folder/$sub"_$3_"${axisNames[$j]}"_first_half.png"
			rm $output_folder/$sub"_$3_"${axisNames[$j]}"_second_half.png"
			rm $output_folder/$sub"_$3_"${axisNames[$j]}"_third_part.png"
		fi
	done
	

	for ((i=0; i<18; i++)); do
		for ((j=0; j<3; j++)); do
			if { [ "$single_orientation" -eq "1" ] && [ "$j" -eq "$orientation" ]; } || [ "$single_orientation" -eq "0" ]; then
				rm $output_folder/$sub"_$3_"${axisNames[$j]}_$(($i+1)).png
			fi
		done
	done


 





 



