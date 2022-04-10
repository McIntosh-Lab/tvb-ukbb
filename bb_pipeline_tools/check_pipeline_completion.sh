#!/bin/bash
# 
# this script should be run while in an ADNI3 directory (ls should show AD, CN, LMCI, etc directories)
# This script checks processed subjects for completion - missing expected
# output files will be printed if not found.
#
# Usage while in directory containing subjects: 
#       check_pipeline_completion.sh  list_of_subjects.tsv
#
#   list_of_subjects.tsv should be a file containing list of subjects to be checked, one per line. subj name and group (AD, CN, etc) should be on each line, separated by a tab
# 
# Author: Justin Wang


#iterate through subjlist
PARC_NAME=${2}

while IFS=$' \t\r\n' read -r subjname group; do
    if [ -d ${group}/${subjname} ]
    then
        cd ${group}/${subjname}

        #array of ica dirs
        array=()
        while IFS=  read -r -d $'\0'; do
            array+=("$REPLY")
        done < <(find fMRI -maxdepth 1 -type d -name "*.ica" -print0)

        #check missing ica
        if (( ${#array[@]} == 0 )); then
            echo "${group}/${subjname} is missing ica"
        fi

        #for each .ica file, check ts and fc
        for t in ${array[@]}; do
            rfMRI_ver=`basename $t`
            if [ -f "fMRI/$rfMRI_ver/ts_${PARC_NAME}.txt" ]; then
                :
            else
                echo "${group}/${subjname} is missing ts_${PARC_NAME}.txt"
            fi

            if [ -f "fMRI/$rfMRI_ver/fc_${PARC_NAME}.txt" ]; then
                :
            else
                echo "${group}/${subjname} is missing fc_${PARC_NAME}.txt"
            fi
        done

        #check sc.txt
        if [ -f "dMRI/sc_${PARC_NAME}.txt" ]; then
                :
        else
                echo "${group}/${subjname} is missing sc_${PARC_NAME}.txt"
        fi

        #check QC HTML generation
        if [ -f "QC_${PARC_NAME}/html/IDP.html" ]; then
                :
        else
                echo "${group}/${subjname} has incomplete QC report"
        fi

        #check IDP generation
        if [ -f "IDP_files_${PARC_NAME}/significant_IDPs.tsv" ]; then
                :
        else
                echo "${group}/${subjname} has incomplete IDP processing"
        fi

        cd ../..
    fi
done < "$1"