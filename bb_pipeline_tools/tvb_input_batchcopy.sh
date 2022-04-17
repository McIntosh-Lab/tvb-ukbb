#!/bin/bash
# this script should be run while in an CC directory (ls should show subj directories)
# this script will copy all tvb_inputs from your processed subjects into tvb_inputs dir
#
# usage: tvb_input_batchcopy.sh Cam-CAN_subject_list.tsv

mkdir -p tvb_inputs
while IFS=$' \t\r\n' read -r subjname; do
        mkdir -p tvb_inputs
        mv ${subjname}/*tvb_inputs.zip tvb_inputs/
done < "$1"


