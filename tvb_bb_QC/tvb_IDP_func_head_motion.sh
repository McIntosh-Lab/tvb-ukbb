#!/bin/sh
#
# Script name: bb_IDP_func_head_motion
#
# Description: Script to generate the IDPs related to head motion in fMRI.
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
subjname=`basename $1`
func_file=$2
#relative^

result=""




cd $subjname


# basefMRI="fMRI/"
#if [ -d $basefMRI/unusable ] ; then
#    basefMRI="$basefMRI/unusable"
#fi

# baserfMRI="$basefMRI/rfMRI.ica/"
# basetfMRI="$basefMRI/tfMRI.feat/"

result=""

# for i in $baserfMRI/mc/prefiltered_func_data_mcf_rel_mean.rms $basetfMRImc/prefiltered_func_data_mcf_rel_mean.rms ; do
if [ -f ${func_file} ] ; then
	result=`cat ${func_file}`
else
	result="NaN"
fi
# done

# mkdir -p IDP_files

# echo $result > IDP_files/$scriptName.txt
echo $result

cd $origDir


