#!/bin/sh

###################################################
# Script from https://neuroimaging-core-docs.readthedocs.io/en/latest/pages/image_processing_tips.html#dilate
# https://bitbucket.org/dpat/tools/raw/master/LIBRARY/dilate.sh
# Tools used within script are copyrighted by:    #   
# FSL (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL) #
###################################################
if [ $# -lt 2 ]
then
    echo "Usage: $0 <input file> <# of reps> [dimensions]"
    echo "Example of default 2D form: $0 flair_mask 3"
    echo "Example with dimensions specified: $0 flair_mask 3 3D"
    echo "2D dilates a mask using 2D and 3x3x1 for the specified # of reps"
    echo "3D dilates a mask using 3D and 3x3x3 for the specified # of reps"
    echo ""
    exit 1
fi

input=$1
reps=$2

if [ $# -eq 2 ]
then
  dimensions="2D"
  else
  dimensions=$3
fi

i=1
while [ $i -le $reps ]
do
	echo "dilating "$i
	fslmaths $input -kernel ${dimensions} -dilM $input -odt char
	let i+=1
done
