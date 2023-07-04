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
import time
import sys
import json

sys.path.insert(1, os.path.dirname(__file__) + "/..")
import bb_pipeline_tools.bb_logging_tool as LT


def bb_pipeline_struct(subject, runTopup, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]
    jobSTRUCTINIT = "-1"
    jobSWI = "-1"

    subname = subject.replace("/", "_")

    print("Beginning structural pipeline")

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
            # if encDir in ["dwi"]:
            # pass
            print("Running topup setup...")
            for encDir in ["AP", "PA"]:
                bvals = np.loadtxt(subject + "/dMRI/raw/" + encDir + ".bval")
                numVols = int(sum(bvals <= b0_threshold))

                # numVols= LT.runCommand(logger, "for f in `cat " + subject +"/dMRI/raw/" + encDir + ".bval` ; do echo $f; done | awk '{if($1==$1+0 && $1 < " + b0_threshold + " ) print $1}' |wc | awk '{print $1}'")
                jobGETB01 = LT.runCommand(
                    logger,
                    "$BB_BIN_DIR/bb_structural_pipeline/bb_get_b0s.py -i "
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
                    "bb_get_b0s_1_"
                    + subname
                )
                jobsB0.append(
                    LT.runCommand(
                        logger,
                        "$BB_BIN_DIR/bb_structural_pipeline/bb_choose_bestB0 "
                        + subject
                        + "/fieldmap/total_B0_"
                        + encDir
                        + ".nii.gz "
                        + subject
                        + "/fieldmap/B0_"
                        + encDir
                        + ".nii.gz ",
                        "bb_choose_bestB0_1_"
                        + subname
                    )
                )

            jobMERGE = LT.runCommand(
                logger,
                "${FSLDIR}/bin/fslmerge -t "
                + subject
                + "/fieldmap/B0_AP_PA "
                + subject
                + "/fieldmap/B0_AP "
                + subject
                + "/fieldmap/B0_PA",
                "bb_fslmerge_"
                + subname
            )
            print("Topup setup completed.")
        # Registrations - T1 to MNI - T2 to T1 - T2 to MNI (Combining the 2 previous ones)
        print("Running bb_struct_init...")
        jobSTRUCTINIT = LT.runCommand(
            logger,
            "${BB_BIN_DIR}/bb_structural_pipeline/bb_struct_init "
            + subject,
            "bb_structinit_"
            + subname
        )
        print("bb_struct_init completed.")
        # TODO: Do a better check here. This one looks arbitrary
        if "SWI_TOTAL_MAG_TE2" in fileConfiguration:
            print("Running SWI registration...")
            jobSWI = LT.runCommand(
                logger,
                "$BB_BIN_DIR/bb_structural_pipeline/bb_swi_reg "
                + subject,
                "bb_swi_reg_"
                + subname
            )
            print("SWI registration complete.")
        # Topup
        if runTopup:
            print("Topup enabled. Running topup...")
            jobPREPAREFIELDMAP = LT.runCommand(
                logger,
                "$BB_BIN_DIR/bb_structural_pipeline/bb_prepare_struct_fieldmap "
                + subject,
                "bb_prepare_struct_fieldmap_"
                + subname
            )
            jobTOPUP = LT.runCommand(
                logger,
                "${FSLDIR}/bin/topup --imain="
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
                "bb_topup_"
                + subname
            )
            print("Topup complete.")
        else:
            logger.error(
                "There is not enough/correct DWI data. TOPUP cannot be run. Continuing to run DWI and fMRI processing without TOPUP."
            )

        # HCP Structural pipeline
        # jobHCPSTRUCT = LT.runCommand(logger, 'bb_HCP_structural ' + subject + ' ' + jobSTRUCTINIT + ' ' + str(boolT2))

        if not runTopup:
            print("Structural pipeline complete. Logfiles located in subject's logs directory.")
            return ",".join([jobSTRUCTINIT, jobSWI])
        else:
            print("Running post-topup...")
            jobPOSTTOPUP = LT.runCommand(
                logger,
                "$BB_BIN_DIR/bb_structural_pipeline/bb_post_topup "
                + subject,
                "bb_post_topup_"
                + subname
            )

            print("Post-topup complete.")
            print("Structural pipeline complete. Logfiles located in subject's logs directory.")
            return jobPOSTTOPUP


if __name__ == "__main__":
    # grab subject name from command
    subject = sys.argv[1]
    fd_fileName = "logs/file_descriptor.json"

    # check if subject directory exists
    if not os.path.isdir(subject):
        print(f"{subject} is not a valid directory. Exiting")
        sys.exit(1)
    # attempt to open the JSON file
    try:
        json_path = os.path.abspath(f"./{subject}/{fd_fileName}")
        with open(json_path, "r") as f:
            fileConfig = json.load(f)
    except:
        print(f"{json_path} could not be loaded. Exiting")
        sys.exit(1)
    # call pipeline
    bb_pipeline_struct(subject, False, fileConfig)
