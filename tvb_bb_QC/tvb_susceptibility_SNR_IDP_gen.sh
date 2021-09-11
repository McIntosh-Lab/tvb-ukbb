#!/bin/sh
#
# Script name: tvb_susceptibility_SNR_IDP_gen
#
# Description: Script to generate the IDPs related to TSNR for susceptible vs non-susceptible ROIs




origDir=`pwd`
scriptName=`basename "$0"`
subjname=$1
func_file=$2
#relative^

standard_bin_susc_parc=$3
#relative path from subj^

fMRI_ver=`basename "$4"`
#basename unneeded ^

feat_or_ica=$5
susc_or_nonsusc=$6
result=""


func_file_name=`basename $func_file`

fMRI_ver_no_ext=${fMRI_ver%.*} 

cd $subjname

if [ feat_or_ica == "ica" ] ; then

	${FSLDIR}/bin/applywarp --rel --interp=nn --in=$standard_bin_susc_parc --ref=$func_file -w fMRI/$fMRI_ver/reg/standard2example_func_warp -o IDP_files/susc_parc_to_func_space_${func_file_name}_${susc_or_nonsusc}_$fMRI_ver_no_ext
else
	${FSLDIR}/bin/invwarp --ref=$func_file -w fMRI/$fMRI_ver/reg/example_func2highres_warp -o fMRI/$fMRI_ver/reg/highres2example_func_warp
	#use --rel?
	#what is the example_func2highres (withou the warp suffix)?

	${FSLDIR}/bin/applywarp --rel --interp=nn --in=$standard_bin_susc_parc --ref=T1/T1 -w T1/transforms/T1_to_MNI_warp_coef_inv -o IDP_files/susc_parc_to_T1_space


	${FSLDIR}/bin/applywarp --rel --interp=nn --in=IDP_files/susc_parc_to_T1_space --ref=$func_file -w fMRI/$fMRI_ver/reg/highres2example_func_warp -o IDP_files/susc_parc_to_func_space_${func_file_name}_${susc_or_nonsusc}_$fMRI_ver_no_ext
fi


rm fMRI/$fMRI_ver/reg/highres2example_func_warp.nii.gz
rm IDP_files/susc_parc_to_T1_space.nii.gz

outputfile="IDP_files/${func_file_name}_${susc_or_nonsusc}_${fMRI_ver_no_ext}"

fslmaths $func_file -mas IDP_files/susc_parc_to_func_space_${func_file_name}_${susc_or_nonsusc}_$fMRI_ver_no_ext $outputfile


if [ -f ${outputfile}.nii.gz ] ; then
  tempfile_name="${func_file_name}_${susc_or_nonsusc}"
  fslmaths $outputfile -Tstd /tmp/${tempfile_name}_SNR_$subjname
  fslmaths $outputfile -Tmean -div /tmp/${tempfile_name}_SNR_$subjname /tmp/${tempfile_name}_SNR_$subjname
  TheSNR=`fslstats /tmp/${tempfile_name}_SNR_$subjname -l 0.1 -p 50`
  #TheSNRrecip=`echo "10 k 1 $TheSNR / p" | dc -`
  result="$TheSNR"
  imrm /tmp/${tempfile_name}_SNR_$subjname
else
  result="NaN"
fi


echo $result

cd $origDir


