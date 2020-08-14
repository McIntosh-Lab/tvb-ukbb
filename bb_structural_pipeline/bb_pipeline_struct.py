#!/bin/env python
#
# Script name: bb_pipeline_struct.py
#
# Description: Script with the structural pipeline.
# 			   This script will call the rest of structural functions.
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
import os
import numpy as np
import bb_pipeline_tools.bb_logging_tool as LT
import time


def bb_pipeline_struct(subject, runTopup, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]
    jobSTRUCTINIT = "-1"
    jobSWI = "-1"

    subname = subject.replace("/", "_")

    print("HERE")

    if (not "T1" in fileConfiguration) or (fileConfiguration["T1"] == ""):
        logger.error("There is no T1. Subject " + subject + " cannot be processed.")
        return -1

    else:
        # TODO: Adapt code to good syntax practices --> PEP 8

        # Create the B0 AP - PA file to estimate the fieldmaps
        b0_threshold = int(
            np.loadtxt(os.environ["BB_BIN_DIR"] + "/bb_data/b0_threshold.txt")
        )

        jobsB0 = []

        if runTopup:
            for encDir in ["AP", "PA"]:
                bvals = np.loadtxt(subject + "/dMRI/raw/" + encDir + ".bval")
                numVols = int(sum(bvals <= b0_threshold))

                # numVols= LT.runCommand(logger, "for f in `cat " + subject +"/dMRI/raw/" + encDir + ".bval` ; do echo $f; done | awk '{if($1==$1+0 && $1 < " + b0_threshold + " ) print $1}' |wc | awk '{print $1}'")
                jobGETB01 = LT.runCommand(
                    logger,
                    #'${FSLDIR}/bin/fsl_sub -T 5  -N "bb_get_b0s_1_'
                    '${FSLDIR}/bin/fsl_sub -q bigmem_16.q  -N "bb_get_b0s_1_'
                    + subname
                    + '" -l '
                    + logDir
                    + " $BB_BIN_DIR/bb_structural_pipeline/bb_get_b0s.py -i "
                    + subject
                    + "/dMRI/raw/"
                    + encDir
                    + ".nii.gz -o "
                    + subject
                    + "/fieldmap/total_B0_"
                    + encDir
                    + ".nii.gz -n "
                    + str(numVols)
                    + " -l "
                    + str(b0_threshold),
                )
                jobsB0.append(
                    LT.runCommand(
                        logger,
                        #'${FSLDIR}/bin/fsl_sub -T 20 -N "bb_choose_bestB0_1_'
                        '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_choose_bestB0_1_'
                        + subname
                        + '" -l '
                        + logDir
                        + " -j "
                        + jobGETB01
                        + " $BB_BIN_DIR/bb_structural_pipeline/bb_choose_bestB0 "
                        + subject
                        + "/fieldmap/total_B0_"
                        + encDir
                        + ".nii.gz "
                        + subject
                        + "/fieldmap/B0_"
                        + encDir
                        + ".nii.gz ",
                    )
                )

            jobMERGE = LT.runCommand(
                logger,
                #'${FSLDIR}/bin/fsl_sub -T 5 -N "bb_fslmerge_'
                '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_fslmerge_'
                + subname
                + '" -j '
                + ",".join(jobsB0)
                + " -l "
                + logDir
                + " ${FSLDIR}/bin/fslmerge -t "
                + subject
                + "/fieldmap/B0_AP_PA "
                + subject
                + "/fieldmap/B0_AP "
                + subject
                + "/fieldmap/B0_PA",
            )

        # Registrations - T1 to MNI - T2 to T1 - T2 to MNI (Combining the 2 previous ones)
        jobSTRUCTINIT = LT.runCommand(
            logger,
            #'${FSLDIR}/bin/fsl_sub -T 850 -N "bb_structinit_'
            '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_structinit_'
            + subname
            + '" -l '
            + logDir
            + "  $BB_BIN_DIR/bb_structural_pipeline/bb_struct_init "
            + subject,
        )

        # TODO: Do a better check here. This one looks arbitrary
        if "SWI_TOTAL_MAG_TE2" in fileConfiguration:
            jobSWI = LT.runCommand(
                logger,
                #'${FSLDIR}/bin/fsl_sub -T 90 -N "bb_swi_reg_'
                '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_swi_reg_'
                + subname
                + '" -l '
                + logDir
                + " -j "
                + jobSTRUCTINIT
                + "  $BB_BIN_DIR/bb_structural_pipeline/bb_swi_reg "
                + subject,
            )

        # Topup
        if runTopup:
            jobPREPAREFIELDMAP = LT.runCommand(
                logger,
                #'${FSLDIR}/bin/fsl_sub -T 5 -N "bb_prepare_struct_fieldmap_'
                '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_prepare_struct_fieldmap_'
                + subname
                + '" -l '
                + logDir
                + " -j "
                + jobMERGE
                + " $BB_BIN_DIR/bb_structural_pipeline/bb_prepare_struct_fieldmap "
                + subject,
            )
            jobTOPUP = LT.runCommand(
                logger,
                #'${FSLDIR}/bin/fsl_sub -T 90 -N "bb_topup_'
                '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_topup_'
                + subname
                + '" -l '
                + logDir
                + " -j "
                + jobPREPAREFIELDMAP
                + " ${FSLDIR}/bin/topup --imain="
                + subject
                + "/fieldmap/B0_AP_PA --datain="
                + subject
                + "/fieldmap/acqparams.txt --config=b02b0.cnf --out="
                + subject
                + "/fieldmap/fieldmap_out --fout="
                + subject
                + "/fieldmap/fieldmap_fout --jacout="
                + subject
                + "/fieldmap/fieldmap_jacout -v",
            )

        else:
            logger.error(
                "There is not enough/correct DWI data. Topup cannot be run. fMRI and DWI cannot be run"
            )

        # HCP Structural pipeline
        # jobHCPSTRUCT = LT.runCommand(logger, 'bb_HCP_structural ' + subject + ' ' + jobSTRUCTINIT + ' ' + str(boolT2))

        print("FINISH STRUCTURAL")
        if not runTopup:
            return ",".join([jobSTRUCTINIT, jobSWI])
        else:
            jobPOSTTOPUP = LT.runCommand(
                logger,
                #'${FSLDIR}/bin/fsl_sub -T 60 -N "bb_post_topup_'
                '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_post_topup_'
                + subname
                + '" -l '
                + logDir
                + " -j "
                + jobTOPUP
                + ","
                + jobSTRUCTINIT
                + ","
                + jobSWI
                + " $BB_BIN_DIR/bb_structural_pipeline/bb_post_topup "
                + subject,
            )
            return jobPOSTTOPUP
