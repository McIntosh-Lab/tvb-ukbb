#!/bin/sh
#
# Script name: tvb_susceptibility_SNR_IDP_gen
#
# Description: Script to generate the IDPs related to TSNR for susceptible vs non-susceptible ROIs




origDir=`pwd`
scriptName=`basename "$0"`
subjname=$1
func_file=$2
#relative
parc=$3
#relative path from subj^
fMRI_ver=
feat_or_ica=

cd $subjname

if [ feat_or_ica = "ica" ] ; then
${FSLDIR}/bin/applywarp --rel --interp=nn --in=$bin_suscept_rois --ref=fMRI/rfMRI_0.ica/filtered_func_data -w fMRI/$fMRI_ver/reg/standard2example_func_warp -o "IDP_files/suscept_parc_to_func"
else
${FSLDIR}/bin/applywarp --rel --interp=nn --in=$inv_bin_suscept_rois --ref=fMRI/rfMRI_0.ica/filtered_func_data -w fMRI/$fMRI_ver/reg/standard2example_func_warp -o "IDP_files/non_suscept_parc_to_func"
fi


func_file_name=`basename $func_file`
parc_file_name=`basename $parc`
outputfile="IDP_files/${func_file_name}_${parc_file_name}"
echo $func_file
echo $parc
echo $outputfile
fslmaths $func_file -mas $parc $outputfile


if [ -f ${outputfile} ] ; then
  tempfile_name="${func_file_name}_${parc_file_name}"
  fslmaths $outputfile -Tstd /tmp/${tempfile_name}_SNR_$subjname
  fslmaths $outputfile -Tmean -div /tmp/${tempfile_name}_SNR_$subjname /tmp/${tempfile_name}_SNR_$subjname
  TheSNR=`fslstats /tmp/${tempfile_name}_SNR_$subjname -l 0.1 -p 50`
  #TheSNRrecip=`echo "10 k 1 $TheSNR / p" | dc -`
  result="$TheSNR"
  imrm /tmp/${tempfile_name}_SNR_$subjname
else
  result="$NaN"
fi


echo $result

cd $origDir


