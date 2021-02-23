#!/bin/env python
#
# Script name: tvb_ukbb_QC.py
#
# Description: Script to run the QC generation in a queueing system. Adapted by Justin Wang from UKBB pipeline.
#
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

import bb_pipeline_tools.bb_logging_tool as LT   #HOW DOES THIS PACKAGING WORK... 
import os.path


def tvb_bb_QC_images(subject, jobHold, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]

    subname = subject.replace("/", "_")

    jobIDP = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 30 -N "bb_IDP_'
        '${FSLDIR}/bin/fsl_sub -q ${QUEUE_STANDARD} -N "tvb_bb_QC_images_'
        + subname
        + '" -j '
        + jobHold
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/tvb_bb_QC_images/tvb_bb_QC_images.sh "
        + subject,
    )
    print("SUBMITTED QC_IMAGES")
    return jobIDP
