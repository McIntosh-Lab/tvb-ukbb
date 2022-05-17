#!/bin/env python
#
# Script name: tvb_reparcellate_pipeline.py
#
# Description: This script will call all the parcellation-specific subpipes required to reparcellate a processed subject.
# 
# Author: Justin Wang
#
# Adapted from scripts by: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Usage while in the directory containing subjects:

import os.path
import sys
import json

sys.path.insert(1, os.path.dirname(__file__) + "/..")
import bb_pipeline_tools.bb_logging_tool as LT
# from tvb_bb_QC.html_reparcellation import html_reparcellation
#EXPORT PARC stuff

def tvb_reparcellate_pipeline(subject, fileConfiguration, PARC_NAME):

    #import fileconfig from json if none given
    if fileConfiguration=="none":
        try:
            fd_fileName = "logs/file_descriptor.json"
            json_path = os.path.abspath(f"./{subject}/{fd_fileName}")
            with open(json_path, "r") as f:
                fileConfiguration = json.load(f)
        except:
            print(f"{json_path} could not be loaded. Exiting")
            sys.exit(1)





    subject = subject.strip()

    if subject[-1] == "/":
        subject = subject[0 : len(subject) - 1]
        
    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]

    subname = subject.replace("/", "_")


    ######
    # STRUCTURAL
    ######
    print("Running structural reparcellation pipeline...")
    jobSTRUCTPARC = LT.runCommand(
        logger,
        "${BB_BIN_DIR}/bb_structural_pipeline/tvb_struct_parcellation.sh "
        + subject,
        "tvb_struct_parcellation_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print("Structural reparcellation pipeline completed.")




    ######
    # FUNCTIONAL
    ######
    print("Beginning functional reparcellation pipeline")

    if ("rfMRI" in fileConfiguration) and (fileConfiguration["rfMRI"] != ""):
        print("rfMRI files found. Running rfMRI subpipe reparcellation")
        print("Running FC reparcellation...")

        ### compute FC using parcellation
        jobFC = LT.runCommand(
            logger,
            "$BB_BIN_DIR/bb_functional_pipeline/tvb_FC "
            + subject,
            "tvb_FC_"
            + subname
            + "_"
            + PARC_NAME
            + "_"
            + "reparcellation"
        )
        print("FC reparcellation completed.")
        print("rfMRI subpipe reparcellation complete.")
    else:
        logger.error(
            "There is no rFMRI info. Thus, the Resting State part will not be run"
        )
    print("Functional reparcellation pipeline complete.")




    ######
    # DIFFUSION
    ######

    print("Beginning diffusion reparcellation pipeline")

    print("Running tvb_probtrackx reparcellation...")
    jobPREPROBTRACKX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_probtrackx2 "
        + baseDir,
        "tvb_probtrackx_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print("tvb_probtrackx reparcellation completed.")

    print("Running tvb_post_probtrackx reparcellation...")
    jobPOSTPROBTRACKX = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_post_probtrackx2 "
        + subject,
        "tvb_post_probtrackx_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print("post_probrackx reparcellation completed.")

    print("Diffusion reparcellation pipeline complete.")




    ######
    # IDP
    ######

    print("Running IDP reparcellation pipeline...")
    jobIDP = LT.runCommand(
        logger,
        "$BB_BIN_DIR/bb_IDP/bb_IDP "
        + subject,
        "bb_IDP_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print("IDP reparcellation pipeline complete.")




    ######
    # QC
    ######


    print("Beginning QC reparcellation pipeline...")
    jobQC = LT.runCommand(
        logger,
        " xvfb-run -a $BB_BIN_DIR/tvb_bb_QC/tvb_bb_QC.sh "  # -s '-screen 0 640x480x24'
        + subject,
        "tvb_bb_QC_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print("QC reparcellation pipeline complete.")



    print("Beginning QC html reparcellation dropdown...")
    jobHTML_reparc = LT.runCommand(
        logger,
        " python $BB_BIN_DIR/tvb_bb_QC/html_reparcellation.py "  # -s '-screen 0 640x480x24'
        + subject
        + " "
        + PARC_NAME,
        "html_reparcellation_"
        + subname
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    # html_reparcellation(subject,PARC_NAME)
    print("QC html reparcellation dropdown complete.")

    LT.finishLogging(logger)

    return jobHTML_reparc


if __name__ == "__main__":
    # grab subject name from command
    subject = sys.argv[1]
    PARC_NAME = sys.argv[2]

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
    tvb_reparcellate_pipeline(subject, fileConfig, PARC_NAME)
