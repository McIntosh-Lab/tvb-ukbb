#!/bin/env python
#
# Script name: bb_pipeline_diff.py
#
# Description: Script with the dMRI pipeline.
# 			   This script will call the rest of dMRI functions.
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

import os.path
import sys
import json

sys.path.insert(1, os.path.dirname(__file__) + "/..")
import bb_pipeline_tools.bb_logging_tool as LT


def bb_pipeline_diff(subject, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]

    subname = subject.replace("/", "_")

    print("Beginning diffusion pipeline")

    print("Running pre_eddy...")
    jobPREPARE = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_pre_eddy "
        + subject,
        "bb_pre_eddy_"
        + subname
    )
    print("pre_eddy completed.")

    if os.environ["SynB0"] == "y":
        print("Running SynB0 unwarping...")
        LT.runCommand(
            logger,
            "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_SynB0/tvb_SynB0_pipeline.sh "
            + subject,
            "tvb_bb_SynB0_pipeline_"
            + subname
        )
        print("SynB0 unwarping done.")

    print("Running eddy..")
    jobEDDY = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_eddy_wrap "
        + baseDir,
        "bb_eddy_"
        + subname
    )
    print("eddy completed.")

    print("Running post_eddy...")
    jobPOSTEDDY = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_post_eddy "
        + baseDir,
        "bb_post_eddy_"
        + subname
    )

    print("post_eddy completed.")

    print("Running DTIFIT...")
    jobDTIFIT = LT.runCommand(
        logger,
        "${FSLDIR}/bin/dtifit -k "
        + baseDir
        + "/dMRI/dMRI/data_1_shell -m "
        + baseDir
        + "/dMRI/dMRI/nodif_brain_mask -r "
        + baseDir
        + "/dMRI/dMRI/data_1_shell.bvec -b "
        + baseDir
        + "/dMRI/dMRI/data_1_shell.bval -o "
        + baseDir
        + "/dMRI/dMRI/dti",
        "bb_dtifit_"
        + subname
    )
    print("DTIFIT completed.")

    print("Running TBSS...")
    jobTBSS = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_tbss/bb_tbss_general "
        + subject,
        "bb_tbss_"
        + subname
    )
    print("TBSS completed.")
    # jobNODDI = LT.runCommand(
    # logger,
    ##'${FSLDIR}/bin/fsl_sub -T 100 -N "bb_NODDI_'
    #'${FSLDIR}/bin/fsl_sub -q ${QUEUE_MORE_MEM} -N "bb_NODDI_'
    # + subname
    # + '" -j '
    # + jobTBSS
    # + "  -l "
    # + logDir
    # + "$BB_BIN_DIR/bb_diffusion_pipeline/bb_NODDI "
    # + subject,
    # )

    print("Running pre_bedpostx...")
    jobPREBEDPOSTX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_pre_bedpostx_gpu "
        + baseDir
        + "/dMRI",
        "bb_pre_bedpostx_gpu_"
        + subname
    )
    print("pre_bedpostx completed.")

    print("Running bedpostx...")
    jobBEDPOSTX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_bedpostx_gpu "
        + baseDir
        + "/dMRI",
        "bb_bedpostx_gpu_"
        + subname
    )
    print("bedpostx completed.")
    ##### bb_post_bedpostx_gpu not necessary if using bedpostx package rather than xfibres (gpu) #####
    # jobPOSTBEDPOSTX = LT.runCommand(
    # logger,
    ##'${FSLDIR}/bin/fsl_sub -T 15  -N "bb_post_bedpostx_gpu_'
    #'${FSLDIR}/bin/fsl_sub -q ${QUEUE_MORE_MEM}  -N "bb_post_bedpostx_gpu_'
    # + subname
    # + '" -j '
    # + jobBEDPOSTX
    # + "  -l "
    # + logDir
    # + "$BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_post_bedpostx_gpu "
    # + baseDir
    # + "/dMRI/dMRI",
    # )
    #### running our own tractography algorithms so turning AutoPtx option off
    # jobAUTOPTX = LT.runCommand(
    # logger,
    # "$BB_BIN_DIR/bb_diffusion_pipeline/bb_autoPtx/bb_autoPtx "
    # + subname
    # + " "
    # + jobPOSTBEDPOSTX
    # + ","
    # + jobTBSS,
    # )

    print("Running tvb_probtrackx...")
    jobPREPROBTRACKX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_probtrackx2 "
        + baseDir,
        "tvb_probtrackx_"
        + subname
    )
    print("tvb_probtrackx completed.")

    # commenting out CPU version of probtrackx for now
    # jobPROBTRACKX = LT.runCommand(
    #     logger,
    #     baseDir
    #     + "/dMRI/probtrackx/probtrackx_commands_$SGE_TASK_ID.txt'",
    #     "bb_probtrackx_"
    #     + subname
    # )
    # jobPROBTRACKX = jobPROBTRACKX.split(".")[0]

    print("Running tvb_post_probtrackx...")
    jobPOSTPROBTRACKX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_post_probtrackx2 "
        + subject,
        "tvb_post_probtrackx_"
        + subname
    )
    print("post_probrackx completed.")

    print("Diffusion pipeline complete.")
    return jobPOSTPROBTRACKX


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
    bb_pipeline_diff(subject, fileConfig)
