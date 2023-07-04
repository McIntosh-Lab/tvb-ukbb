#!/bin/sh
#
# Script name: bb_IDP_func_task_activation
#
# Description: Script to generate the IDPs related to task fMRI activation.
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
subjname=`basename $1`
fMRI_ver=$2

result=""

cd $subjname


basefMRI="fMRI/"
#if [ -d $basefMRI/unusable ] ; then
#    basefMRI="$basefMRI/unusable"
#fi

basetfMRI="$basefMRI/$fMRI_ver/"

#Setting the string of NaN in case there is a problem.
numVars="16"
result="";
for i in $(seq 1 $numVars) ; do 
    result="NaN $result" ; 
done 

if [ -f $basetfMRI/filtered_func_data.nii.gz ] ; then
  cd $basetfMRI
  if [ ! -f featquery_5a/report.txt ] ; then
    if [ ! -f reg/highres2standard_warp.nii.gz ] ; then
      cd reg
      imln ../../../T1/transforms/T1_to_MNI_warp highres2standard_warp
      cd ..
    fi
    if [ ! -f reg/highres2standard_warp_inv.nii.gz ] ; then
      cd reg
      imln ../../../T1/transforms/T1_to_MNI_warp_coef_inv highres2standard_warp_inv
      cd ..
    fi
    featquery 1 . 2 stats/cope1 stats/zstat1 featquery_1  $templ/group/groupMask1
    featquery 1 . 2 stats/cope2 stats/zstat2 featquery_2  $templ/group/groupMask2
    featquery 1 . 2 stats/cope5 stats/zstat5 featquery_5  $templ/group/groupMask5
    featquery 1 . 2 stats/cope5 stats/zstat5 featquery_5a $templ/group/groupMask5a
  fi
  result=""
  for f in 1 2 5 5a ; do
    a=`cat featquery_${f}/report.txt  | awk '{print $7}' | head -n 1`
    b=`cat featquery_${f}/report.txt  | awk '{print $8}' | head -n 1`
    c=`cat featquery_${f}/report.txt  | awk '{print $7}' | tail -n 1`
    d=`cat featquery_${f}/report.txt  | awk '{print $8}' | tail -n 1`
    a=`echo $a | sed 's/-/_/g'` ; a=`echo "3 k $a 100.0 / p" | dc -`
    b=`echo $b | sed 's/-/_/g'` ; b=`echo "3 k $b 100.0 / p" | dc -`
    result="$result $a $b $c $d"
  done
  cd ../..
fi

# mkdir -p IDP_files

# echo $result > IDP_files/$scriptName.txt
echo $result

cd $origDir


