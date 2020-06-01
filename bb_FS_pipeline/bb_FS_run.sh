#!/bin/bash

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_header 

if [ ! -f $1/T1/T1_unbiased.nii.gz ] ; then 

    echo "There is no T1/T1_unbiased.nii.gz -- FreeSurfer cannot run"
    exit -1

else

    if [ "$2" == "" ] ; then 
        export SUBJECTS_DIR=`pwd`/$1/
    else
        export SUBJECTS_DIR=$2
    fi

    optFLAIR=""

    if [ -f $1/T2_FLAIR/T2_FLAIR_unbiased.nii.gz ] ; then
        optFLAIR=" -FLAIR $1/T2_FLAIR/T2_FLAIR_unbiased.nii.gz -FLAIRpial"    
    fi 

    recon-all -all -s FS_$1 -i $1/T1/T1_unbiased.nii.gz $optFLAIR

fi

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer 

set +x

