#!/bin/bash
#
# Script name: QC_tar.sh
#
# Description: Script to generate QC tars for portability 
#
# Usage: 
#         While in subjects folder:  QC_tar.sh subject_name group
#
## Author: Justin Wang


set -x
echo "$-"
set +e



if [[ -d "$2" ]]; then
    origDir="`pwd`/$2"
else
    origDir=`pwd`
fi


sub=$1

if [[ "$sub" =~ '/'$ ]]; then 
  sub=${sub%?}
fi


if [[ "$origDir" =~ '/'$ ]]; then 
  origDir=${origDir%?}
fi


#sub_original=${sub}
#sub=${sub}_QC
#mv ${origDir}/${sub_original} ${origDir}/${sub}



if [[ "$1" == "" ]] ; then
    echo "Error: The selected subject does not exist"
    exit 0
fi

if [[ -d "$2" ]]; then
    cd ${2}
fi

if [[ -d "$1" ]]; then

qc_dir="${sub}_QC"
mkdir -p "${qc_dir}"

# Copy main QC files (preserves structure)
rsync -aR "${sub}/QC"* "${qc_dir}/"
rsync -aR "${sub}/logs" "${qc_dir}/"
rsync -aR "${sub}/IDP_files"*/*.{txt,tsv} "${qc_dir}/"

# Handle fMRI files with one rsync command per pattern
rsync -aR "${sub}/fMRI"/*.ica/{.files,mc/*.png,filtered_func_data.ica/report,*.html} "${qc_dir}/"
rsync -aR "${sub}/fMRI"/*.ica/reg/*.png "${qc_dir}/"
rsync -aR "${sub}/fMRI"/*.ica/reg/unwarp/{*.gif,*.png} "${qc_dir}/"

# Same for .feat files
rsync -aR "${sub}/fMRI"/*.feat/{.files,mc/*.png,*.html} "${qc_dir}/"
rsync -aR "${sub}/fMRI"/*.feat/reg/*.png "${qc_dir}/"
rsync -aR "${sub}/fMRI"/*.feat/reg/unwarp/{*.png,*.gif} "${qc_dir}/"


# Create tar from the copied structure
tar -cf ${qc_dir}.tar "${qc_dir}"

# Cleanup
rm -rf "${qc_dir}"

fi

if [[ -d "$2" ]]; then
    cd ..
fi

set -e
 


