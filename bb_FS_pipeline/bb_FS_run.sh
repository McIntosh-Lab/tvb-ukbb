#!/usr/bin/env bash

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

    # https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all#UsingT2orFLAIRdatatoimprovepialsurfaces
    if [ -f $1/T2_FLAIR/T2_FLAIR_unbiased.nii.gz ] ; then
        optFLAIR=" -FLAIR $1/T2_FLAIR/T2_FLAIR_unbiased.nii.gz -FLAIRpial"    
    # disable for now
    # elif [ -f $1/T2/T2_brain_to_MNI.nii.gz ] ; then
    #     optFLAIR=" -T2 $1/T2/T2_brain_to_MNI.nii.gz -T2pial"    
    fi 

    echo "RUNNING"
    # recon-all -all -s FS_$1 -i $1/T1/T1_unbiased.nii.gz $optFLAIR -log $1/logs
    mkdir -p ${1}/fs
    recon-all -all -s FS_${1} -sd ${PWD}/${1}/fs -i ${1}/T1/T1_unbiased.nii.gz ${optFLAIR}
    echo "recon-all done."
fi

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer 

set +x

