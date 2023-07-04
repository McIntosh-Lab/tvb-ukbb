#!/bin/sh
#
# Script name: bb_IDP_all_align_to_T1
#
# Description: Script to generate the IDPs related to the alignment to T1.
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

origDir=`pwd`
scriptName=`basename "$0"`
direc=$1
filename=$2
MC="-schedule $FSLDIR/etc/flirtsch/measurecost1.sch"

cd $direc

baseT1="T1"
#if [ -d $baseT1/unusable ] ; then
#    baseT1="$baseT1/unusable"
#fi

# baseT2_FLAIR="T2_FLAIR"
# #if [ -d $baseT2_FLAIR/unusable ] ; then
# #    baseT2_FLAIR="$baseT2_FLAIR/unusable"
# #elif [ -d $baseT2_FLAIR/incompatible ] ; then
# #    baseT2_FLAIR="$baseT2_FLAIR/incompatible"
# #fi

# baseFieldmap="fieldmap"
# #if [ -d $baseFieldmap/unusable ] ; then
# #    baseFieldmap="$baseFieldmap/unusable"
# #elif [ -d $baseFieldmap/incompatible ] ; then
# #    baseFieldmap="$baseFieldmap/incompatible"
# #fi

# baseSWI="SWI"
# #if [ -d $baseSWI/unusable ] ; then
# #    baseSWI="$baseSWI/unusable"
# #fi

# basedMRI="dMRI"

# basefMRI="fMRI"
# #if [ -d $basefMRI/unusable ] ; then
# #    basefMRI="$basefMRI/unusable"
# #fi

# baserfMRI="$basefMRI/rfMRI.ica/"
# basetfMRI="$basefMRI/tfMRI.feat/"


# for i in $baseT2_FLAIR/T2_FLAIR_brain $baseFieldmap/fieldmap_iout_to_T1 $baseSWI/SWI_TOTAL_MAG_to_T1 $basedMRI/dMRI/data_B0 $baserfMRI/reg/example_func2highres $basetfMRI/reg/example_func2highres ; do

	
  if [ -f ${filename}.nii.gz ] ; then
    result="`flirt -ref $baseT1/T1_brain -in $filename $MC -refweight $baseT1/T1_brain_mask | head -1 | cut -f1 -d' ' `"
  else
    result="NaN"
  fi


echo $result

cd $origDir


