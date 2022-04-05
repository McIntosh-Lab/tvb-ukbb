#!/bin/sh
#
# Script name: bb_IDP_func_tSNR
#
# Description: Script to generate the IDPs related to tSNR for fMRI.
#
# Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Copyright 2017 University of Oxford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

subjname=`basename $1`
#basename shouldn't be necessary here

fMRI_ver=$2

func_file=$3
#currently the only var that takes full file path

result=""


if [ -f ${func_file}.nii.gz ] ; then
  fslmaths $func_file -Tstd /tmp/${fMRI_ver}_SNR_$subjname
  fslmaths $func_file -Tmean -div /tmp/${fMRI_ver}_SNR_$subjname /tmp/${fMRI_ver}_SNR_$subjname
  TheSNR=`fslstats /tmp/${fMRI_ver}_SNR_$subjname -l 0.1 -p 50`
  #TheSNRrecip=`echo "10 k 1 $TheSNR / p" | dc -`
  result="$TheSNR"
  imrm /tmp/${fMRI_ver}_SNR_$subjname
else
  result="NaN"
fi

echo $result

