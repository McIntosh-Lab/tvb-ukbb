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

#file path
fmri_img=$1
result=""

if [ -f ${fmri_img} ] ; then
  fmriNumVol=`${FSLDIR}/bin/fslval $fmri_img dim4`
  result="$fmriNumVol"
else
  result="NaN"
fi

echo $result

