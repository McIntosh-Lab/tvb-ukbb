#!/bin/bash
# 
# This script checks processed subjects for completion - missing expected
# output files will be printed if not found.
#
# Usage while in directory containing subjects: 
#       check_pipeline_completion.sh  list_of_subjects.tsv
#
#   list_of_subjects.tsv should be a file containing list of subjects to be checked, one per line
# 
# Author: Justin Wang


#iterate through subjlist
while IFS= read -r subjname; do
    if [ -d $subjname ]
    then
        cd $subjname
        #array of ica dirs
        array=()
        while IFS=  read -r -d $'\0'; do
            array+=("$REPLY")
        done < <(find fMRI -maxdepth 1 -type d -name "*.ica" -print0)



        #for each .ica file, check ts and fc
        for t in ${array[@]}; do
            rfMRI_ver=`basename $t`
            if [ -f "fMRI/$rfMRI_ver/ts.txt" ]; then
                :
            else
                echo "$subjname is missing ts.txt" |& tee -a ../feb10_raw_complete_check.txt
            fi

            if [ -f "fMRI/$rfMRI_ver/fc.txt" ]; then
                :
            else
                echo "$subjname is missing fc.txt" |& tee -a ../feb10_raw_complete_check.txt
            fi
        done

        #check sc.txt
        if [ -f "dMRI/sc.txt" ]; then
                :
        else
                echo "$subjname is missing sc.txt" |& tee -a ../feb10_raw_complete_check.txt
        fi

        #check QC HTML generation
        if [ -f "QC/html/IDP.html" ]; then
                :
        else
                echo "$subjname has incomplete QC report" |& tee -a ../feb10_raw_complete_check.txt
        fi

        #check IDP generation
        if [ -f "IDP_files/significant_IDPs.tsv" ]; then
                :
        else
                echo "$subjname has incomplete IDP processing" |& tee -a ../feb10_raw_complete_check.txt
        fi

        cd ..
    fi
done < "$1"