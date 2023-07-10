#!/bin/env python
#
# Script name: tvb_reparcellate_pipeline.py
#
# Description: This script will call all the parcellation-specific subpipes required to reparcellate a processed
# subject.
# 
# Author: Justin Wang, Patrick Mahon (pmahon@sfu.ca)
#
# Adapted from scripts by: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Usage while in the directory containing subjects:

import os.path
import sys
import json
import bb_pipeline_tools.bb_logging_tool as LT

sys.path.insert(1, os.path.dirname(__file__) + "/..")


# from tvb_bb_QC.html_reparcellation import html_reparcellation
# EXPORT PARC stuff

def tvb_reparcellate_pipeline(subject_, file_configuration, PARC_NAME):
    """
    Performs a reparcellation of the subject provided an existing run on a given parcellation has been completed.

    Args:
        subject_:   The subject name.
        file_configuration: ?
        PARC_NAME: The name of the parcellation type to perform. E.g:
                        - TVBSchaeferTian420
                        - TVBSchaeferTian220
                        - etc...

    Returns:


    """

    logger = LT.init_logging(__file__, subject_)
    log_dir = logger.logDir

    # import fileconfig from json if none given
    if file_configuration == "none":
        json_relative_path = f"./{subject_}/logs/file_descriptor.json"
        try:
            json_absolute_path = os.path.abspath(json_relative_path)
            with open(json_absolute_path, "r") as f:
                file_configuration = json.load(f)
        except Exception:
            logger.error(f"{json_relative_path} could not be loaded. Exiting")
            sys.exit(1)

    subject_ = subject_.strip()

    if subject_[-1] == "/":
        subject_ = subject_[0: len(subject_) - 1]

    base_dir = log_dir[0: log_dir.rfind("/logs/")]

    subject_name = subject_.replace("/", "_")

    ######
    # STRUCTURAL
    ######
    print(LT.format_to_info(logger, "Running structural reparcellation pipeline..."))

    LT.run_command(
        logger,
        "${BB_BIN_DIR}/bb_structural_pipeline/tvb_struct_parcellation.sh "
        + subject_,
        "tvb_struct_parcellation_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )

    print(LT.format_to_info(logger, "Structural reparcellation pipeline completed."))

    ######
    # FUNCTIONAL
    ######
    print(LT.format_to_info(logger, "Beginning functional reparcellation pipeline"))

    if ("rfMRI" in file_configuration) and (file_configuration["rfMRI"] != ""):
        print(LT.format_to_info(logger, "rfMRI files found. Running rfMRI subpipe reparcellation"))
        print(LT.format_to_info(logger, "Running FC reparcellation..."))

        # compute FC using parcellation
        LT.run_command(
            logger,
            "$BB_BIN_DIR/bb_functional_pipeline/tvb_FC "
            + subject_,
            "tvb_FC_"
            + subject_name
            + "_"
            + PARC_NAME
            + "_"
            + "reparcellation"
        )

        print(LT.format_to_info(logger, "FC reparcellation completed."))
        print(LT.format_to_info(logger, "rfMRI subpipe reparcellation complete."))
    else:
        logger.error(
            "There is no rFMRI info. Thus, the Resting State part will not be run"
        )
    print(LT.format_to_info(logger, "Functional reparcellation pipeline complete."))

    ######
    # DIFFUSION
    ######

    print(LT.format_to_info(logger, "Beginning diffusion reparcellation pipeline"))

    print(LT.format_to_info(logger, "Running tvb_probtrackx reparcellation..."))
    LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_probtrackx2 "
        + base_dir,
        "tvb_probtrackx_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print(LT.format_to_info(logger, "tvb_probtrackx reparcellation completed."))

    print(LT.format_to_info(logger, "Running tvb_post_probtrackx reparcellation..."))
    LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_diffusion_pipeline/tvb_probtrackx2/tvb_post_probtrackx2 "
        + subject_,
        "tvb_post_probtrackx_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print(LT.format_to_info(logger, "post_probrackx reparcellation completed."))

    print(LT.format_to_info(logger, "Diffusion reparcellation pipeline complete."))

    ######
    # IDP
    ######

    print(LT.format_to_info(logger, "Running IDP reparcellation pipeline..."))
    LT.run_command(
        logger,
        "$BB_BIN_DIR/bb_IDP/bb_IDP "
        + subject_,
        "bb_IDP_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print(LT.format_to_info(logger, "IDP reparcellation pipeline complete."))

    ######
    # QC
    ######

    print(LT.format_to_info(logger, "Beginning QC reparcellation pipeline..."))
    LT.run_command(
        logger,
        " xvfb-run -a $BB_BIN_DIR/tvb_bb_QC/tvb_bb_QC.sh "  # -s '-screen 0 640x480x24'
        + subject_,
        "tvb_bb_QC_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )
    print(LT.format_to_info(logger, "QC reparcellation pipeline complete."))

    print(LT.format_to_info(logger, "Beginning QC html reparcellation dropdown..."))
    job_html_reparc = LT.run_command(
        logger,
        " python $BB_BIN_DIR/tvb_bb_QC/html_reparcellation.py "  # -s '-screen 0 640x480x24'
        + subject_
        + " "
        + PARC_NAME,
        "html_reparcellation_"
        + subject_name
        + "_"
        + PARC_NAME
        + "_"
        + "reparcellation"
    )

    print(LT.format_to_info(logger, "QC html reparcellation dropdown complete."))

    LT.finish_logging(logger)

    return job_html_reparc


if __name__ == "__main__":
    # grab subject name from command
    subject = sys.argv[1]
    PARC_NAME = sys.argv[2]

    fd_fileName = "logs/file_descriptor.json"

    outer_logger = LT.init_logging(__file__, subject)

    # check if subject directory exists
    if not os.path.isdir(subject):
        print(outer_logger.format_to_error(f"{subject} is not a valid directory. Exiting"))
        sys.exit(1)

    # attempt to open the JSON file

    json_relative_path = f"./{subject}/{fd_fileName}"
    try:
        json_absolute_path = os.path.abspath(json_relative_path)
        with open(json_absolute_path, "r") as f:
            fileConfig = json.load(f)
    except Exception:
        print(outer_logger.format_to_error(f"{json_relative_path} could not be loaded. Exiting"))
        sys.exit(1)
    # call pipeline
    tvb_reparcellate_pipeline(subject, fileConfig, PARC_NAME)
