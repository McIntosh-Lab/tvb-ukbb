#!/bin/bash

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_header 

export PATH="$FREESURFER_HOME/bin:$PATH"
source $FREESURFER_HOME/SetUpFreeSurfer.sh

if [ "$2" == "" ] ; then 
    export SUBJECTS_DIR=`pwd`/$1/
else
    export SUBJECTS_DIR=$2
fi

segmentThalamicNuclei.sh FS_$1
segmentBS.sh FS_$1

if [ -f $1/FS_$1/mri/FLAIR.mgz ] ; then 
    segmentHA_T2.sh FS_$1 $1/FS_$1/mri/FLAIR.mgz  AN 1
else
    segmentHA_T1.sh FS_$1
fi

. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer 

set +x

