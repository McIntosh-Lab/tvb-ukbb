#!/usr/bin/bash

#set -x

mkdir -p zips
mkdir -p logs_FS_zips

for elem in `cat subj.txt ` ; do
    if [ -d $elem/FreeSurfer ] ; then
        if [ ! -d $elem/FreeSurfer/unusable ] ; then 
            visit=`echo $elem | awk -F "" '{print $1}'`;
            newName=`echo $elem | awk -F "" '{print $2$3$4$5$6$7$8}'`;
	        echo "cd $elem ; \
                      zip -r ../zips/${newName}_20263_${visit}_0.zip FreeSurfer -x `column_to_row $BB_BIN_DIR/bb_data/FS_files_to_exclude.txt` ; \
                      md5sum ../zips/${newName}_20263_${visit}_0.zip > ../zips/${newName}_20263_${visit}_0.md5 ; \
                      cd .. "; 
        fi
    fi
done > jobs_zips.txt

#fsl_sub -l logs_FS_zips -t jobs_zips.txt
