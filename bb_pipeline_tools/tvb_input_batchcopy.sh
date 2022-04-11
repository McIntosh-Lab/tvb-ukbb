#!/bin/bash
# this script should be run while in an ADNI3 directory (ls should show AD, CN, LMCI, etc directories)
# this script will copy all tvb_inputs from your processed subjects into tvb_inputs dir
#
# usage: tvb_input_batchcopy.sh Cam-CAN_subject_list.tsv

mkdir -p tvb_inputs
while IFS=$' \t\r\n' read -r subjname group; do
        mkdir -p tvb_inputs/${group}
        mv ${group}/${subjname}/*tvb_inputs.zip tvb_inputs/${group}/
done < "$1"


