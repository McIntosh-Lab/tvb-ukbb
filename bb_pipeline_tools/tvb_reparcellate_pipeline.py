#!/bin/env python
#
# Script name: tvb_reparcellate_pipeline.py
#
# Description: This script will call all the parcellation-specific subpipes required to reparcellate a processed subject.
# 
# Author: Justin Wang, Patrick Mahon (pmahon@sfu.ca)
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
# EXPORT PARC stuff

def tvb_reparcellate_pipeline(subject_, file_configuration, PARC_NAME_):
    """
    Performs a reparcellation of the subject provided an existing run on a given parcellation has been completed.

    Args:
        subject_:   The subject name.
        file_configuration: ?
        PARC_NAME_: The name of the parcellation type to perform. E.g:
                        - TVBSchaeferTian420
                        - TVBSchaeferTian220
                        - etc...

    Returns:


    """

    logger = LT.init_logging(__file__, subject_)
    log_dir = logger.logDir

    # import fileconfig from json if none given
    if file_configuration == "none":
        try:
            fd_file_name = "logs/file_descriptor.json"
            json_path_ = os.path.abspath(f"./{subject_}/{fd_file_name}")
            with open(json_path_, "r") as f:
                file_configuration = json.load(f)
        except:
            print(f"{json_path_} could not be loaded. Exiting")
            sys.exit(1)

    subject_ = subject_.strip()

    if subject_[-1] == "/":
        subject_ = subject_[0: len(subject_) - 1]

    base_dir = log_dir[0: log_dir.rfind("/logs/")]

    subject_name = subject_.replace("/", "_")

    ######
    # STRUCTURAL
    ######
    print("Running structural reparcellation pipeline...")
    LT.run_command(
        logger,
        "${BB_BIN_DIR}/bb_structural_pipeline/tvb_struct_parcellation.sh "
        + subject_,
        "tvb_struct_parcellation_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    print("Structural reparcellation pipeline completed.")

    ######
    # FUNCTIONAL
    ######
    print("Beginning functional reparcellation pipeline")

    if ("rfMRI" in file_configuration) and (file_configuration["rfMRI"] != ""):
        print("rfMRI files found. Running rfMRI subpipe reparcellation")
        print("Running FC reparcellation...")

        ### compute FC using parcellation
        jobFC = LT.run_command(
            logger,
            "$BB_BIN_DIR/bb_functional_pipeline/tvb_FC "
            + subject_,
            "tvb_FC_"
            + subject_name
            + "_"
            + PARC_NAME_
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
    jobPREPROBTRACKX = LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_probtrackx2 "
        + base_dir,
        "tvb_probtrackx_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    print("tvb_probtrackx reparcellation completed.")

    print("Running tvb_post_probtrackx reparcellation...")
    jobPOSTPROBTRACKX = LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_post_probtrackx2 "
        + subject_,
        "tvb_post_probtrackx_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    print("post_probrackx reparcellation completed.")

    print("Diffusion reparcellation pipeline complete.")

    ######
    # IDP
    ######

    print("Running IDP reparcellation pipeline...")
    jobIDP = LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_IDP/bb_IDP "
        + subject_,
        "bb_IDP_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    print("IDP reparcellation pipeline complete.")

    ######
    # QC
    ######

    print("Beginning QC reparcellation pipeline...")
    jobQC = LT.run_command(
        logger,
        " xvfb-run -a $BB_BIN_DIR/tvb_bb_QC/tvb_bb_QC.sh "  # -s '-screen 0 640x480x24'
        + subject_,
        "tvb_bb_QC_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    print("QC reparcellation pipeline complete.")

    print("Beginning QC html reparcellation dropdown...")
    job_html_reparc = LT.run_command(
        logger,
        " python $BB_BIN_DIR/tvb_bb_QC/html_reparcellation.py "  # -s '-screen 0 640x480x24'
        + subject_
        + " "
        + PARC_NAME_,
        "html_reparcellation_"
        + subject_name
        + "_"
        + PARC_NAME_
        + "_"
        + "reparcellation"
    )
    # html_reparcellation(subject,PARC_NAME)
    print("QC html reparcellation dropdown complete.")

    LT.finish_logging(logger)

    return job_html_reparc


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
