#!/bin/env python
#
# Script name: bb_pipeline.py
#
# Description: Main script. This script will call the rest of scripts.
#
# Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Contributers: Patrick Mahon (pmahon@sfu.ca)
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
import sys
import argparse
import os.path
import bb_logging_tool as logging_tool

from bb_file_manager import bb_file_manager
from bb_basic_QC import bb_basic_QC
from tvb_reparcellate_pipeline import tvb_reparcellate_pipeline
from bb_structural_pipeline.bb_pipeline_struct import bb_pipeline_struct
from bb_functional_pipeline.bb_pipeline_func import bb_pipeline_func
from bb_diffusion_pipeline.bb_pipeline_diff import bb_pipeline_diff
from bb_IDP.bb_IDP import bb_IDP
from tvb_bb_QC.tvb_bb_QC import tvb_bb_QC


class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write("error: %s\n" % message)
        self.print_help()
        sys.exit(2)


class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg


def main(cli_args=None):
    if cli_args is None:
        parser = MyParser(description="BioBank Pipeline Manager")
        parser.add_argument("subjectFolder", help="Subject Folder")

        argsa = parser.parse_args()
    else:
        parser = MyParser(description="BioBank Pipeline Manager")
        parser.add_argument("subjectFolder", help="Subject Folder")
        argsa = parser.parse_args(cli_args)

    subject = argsa.subjectFolder
    subject = subject.strip()

    if subject[-1] == "/":
        subject = subject[0: len(subject) - 1]

    REPARCELLATE = os.environ['REPARCELLATE']
    PARC_NAME = os.environ['PARC_NAME']

    if REPARCELLATE == "true":
        # Logging initialization
        logger = logging_tool.init_logging(__file__, subject)
        logger.info("Running subject " + subject + " reparcellation.")

        # Perform reparcellation
        tvb_reparcellate_pipeline(subject, "none", PARC_NAME)

        # Clean up 
        logging_tool.finish_logging(logger)

    if REPARCELLATE == "false":

        # Remove old intermediate data from previous runs
        retain = ["rawdata"]

        # loop through all files/folders in subject directory
        for item in os.listdir(os.getcwd()):
            # if file/folder not in retain list, remove
            if item not in retain:
                os.remove(item)

        # Logging initialization
        logger = logging_tool.init_logging(__file__, subject)
        logger.info("Running file manager")

        # Run pipeline
        file_config = bb_file_manager(subject)

        logger.info("File configuration before QC: " + str(file_config))

        file_config = bb_basic_QC(subject, file_config)

        logger.info("File configuration after running file manager: " + str(file_config))

        # run_top_up ==> Having fieldmap
        if not (
                (("AP" in file_config) and (file_config["AP"] != ""))
                and (("PA" in file_config) and (file_config["PA"] != ""))
        ):
            logger.warn("There is no proper AP/PA data. Thus, TOPUP will not be run")
            run_top_up = False
            print("NO TOPUP")
        else:
            run_top_up = True

        # set for now
        # run_top_up = True

        # Structural pipeline
        bb_pipeline_struct(subject, run_top_up, file_config)

        # Functional pipeline
        bb_pipeline_func(subject, file_config)

        # Diffusion pipeline
        bb_pipeline_diff(subject, file_config)

        # Image dependent phenotype
        bb_IDP(
            subject, file_config
        )

        # Quality control
        tvb_bb_QC(
            subject,
            file_config
        )

        # Clean up
        logging_tool.finish_logging(logger)


if __name__ == "__main__":
    main()
