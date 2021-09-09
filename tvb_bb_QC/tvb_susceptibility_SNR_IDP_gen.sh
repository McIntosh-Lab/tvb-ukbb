#!/bin/sh
#
# Script name: bb_IDP_func_TSNR
#
# Description: Script to generate the IDPs related to TSNR for susceptible vs non-susceptible ROIs




origDir=`pwd`
scriptName=`basename "$0"`
direc=$1

cd $direc



bin_suscept_parc_img=`basename $SUSCEPT_PARC_IMG`
bin_suscept_parc_img="IDP_files/binmask_$bin_suscept_parc_img"
fslmaths $SUSCEPT_PARC_IMG -bin $bin_suscept_parc_img

bin_suscept_rois=`basename $SUSCEPT_ROIS`
bin_suscept_rois="IDP_files/binmask_$bin_suscept_rois"
fslmaths $SUSCEPT_ROIS -bin $bin_suscept_rois

inv_bin_suscept_rois=`basename $SUSCEPT_ROIS`
inv_bin_suscept_rois="IDP_files/inv_binmask_$bin_suscept_rois"
fslmaths $bin_suscept_parc_img -sub $bin_suscept_rois $inv_bin_suscept_rois

#TODO: register parcellations to T1 
#${FSLDIR}/bin/applywarp --rel --interp=nn --in=$PARC_IMG --ref=T1 -w T1_to_MNI_warp_coef_inv -o parcel_to_T1

#TODO: mask out fMRI files for r and t, using the below code to generate SNR values
#TODO: call this script from tvb_bb_QC.sh
#TODO: ensure this is IDP added to the tvb_ukbb IDPs as well as CAm-CAN IDPs and the scripts that generate IDP reports. 


basefMRI="fMRI/"
#if [ -d $basefMRI/unusable ] ; then
#    basefMRI="$basefMRI/unusable"
#fi

#baserfMRI="$basefMRI/rfMRI.ica/"
#basetfMRI="$basefMRI/tfMRI.feat/"


result=""

#find .ica folders
array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find $basefMRI -maxdepth 1 -type d -name "*.ica" -print0)

#for each .ica folder
for t in ${array[@]}; do
  rfMRI_ver=`basename $t`
  rfMRI_dir="$basefMRI$rfMRI_ver"
  for i in $rfMRI_dir/filtered_func_data $rfMRI_dir/filtered_func_data_clean ; do
    if [ -f ${i}.nii.gz ] ; then
      nameFil=$rfMRI_ver
      fslmaths $i -Tstd /tmp/${nameFil}_SNR_$1
      fslmaths $i -Tmean -div /tmp/${nameFil}_SNR_$1 /tmp/${nameFil}_SNR_$1
      TheSNR=`fslstats /tmp/${nameFil}_SNR_$1 -l 0.1 -p 50`
      TheSNRrecip=`echo "10 k 1 $TheSNR / p" | dc -`
      result="$result $TheSNRrecip"
      imrm /tmp/${nameFil}_SNR_$1
    else
      result="$result NaN"
    fi
  done
  #we only want to get fmriNumVol once for each rfmri version
  if [ -f ${i}.nii.gz ] ; then
    fmriNumVol=`${FSLDIR}/bin/fslval fMRI/$rfMRI_ver.nii.gz dim4`
    result="$result $fmriNumVol" 
    
  else
    result="$result NaN"

  fi
done


#find .feat folders
array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find $basefMRI -maxdepth 1 -type d -name "*.feat" -print0)


#for each .feat folder
for t in ${array[@]}; do
  tfMRI_ver=`basename $t`
  tfMRI_dir="$basefMRI$tfMRI_ver"
  i=$tfMRI_dir/filtered_func_data
  if [ -f ${i}.nii.gz ] ; then
    nameFil=$tfMRI_ver
    fslmaths $i -Tstd /tmp/${nameFil}_SNR_$1
    fslmaths $i -Tmean -div /tmp/${nameFil}_SNR_$1 /tmp/${nameFil}_SNR_$1
    TheSNR=`fslstats /tmp/${nameFil}_SNR_$1 -l 0.1 -p 50`
    TheSNRrecip=`echo "10 k 1 $TheSNR / p" | dc -`
    result="$result $TheSNRrecip"
    fmriNumVol=`${FSLDIR}/bin/fslval fMRI/$tfMRI_ver.nii.gz dim4`
    result="$result $fmriNumVol" 
    imrm /tmp/${nameFil}_SNR_$1
  else
    result="$result NaN NaN"
  fi
done



mkdir -p IDP_files

echo $result > IDP_files/$scriptName.txt
echo $result

cd $origDir


