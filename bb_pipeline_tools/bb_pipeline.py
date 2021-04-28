#!/bin/env python
#
# Script name: bb_pipeline.py
#
# Description: Main script. This script will call the rest of scripts.
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

import re
import os
import glob
import time
import logging
import sys, argparse, os.path
import bb_logging_tool as LT
from bb_file_manager import bb_file_manager
from bb_basic_QC import bb_basic_QC
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

    if cli_args == None:
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
        subject = subject[0 : len(subject) - 1]

    logger = LT.initLogging(__file__, subject)

    logger.info("Running file manager")
    fileConfig = bb_file_manager(subject)

    logger.info("File configuration before QC: " + str(fileConfig))

    fileConfig = bb_basic_QC(subject, fileConfig)

    logger.info("File configuration after running file manager: " + str(fileConfig))

    # runTopup ==> Having fieldmap
    if not (
        (("AP" in fileConfig) and (fileConfig["AP"] != ""))
        and (("PA" in fileConfig) and (fileConfig["PA"] != ""))
    ):
        logger.warn("There is no proper AP/PA data. Thus, TOPUP will not be run")
        runTopup = False
        print("NO TOPUP")
    else:
        runTopup = True

    # set for now
    # runTopup = True

    # Default value for job id. SGE does not wait for a job with this id.
    jobSTEP1 = "-1"
    jobSTEP2 = "-1"
    jobSTEP3 = "-1"
    jobSTEP4 = "-1"

    jobSTEP1 = bb_pipeline_struct(subject, runTopup, fileConfig)

    if isinstance(jobSTEP1, int):
        if jobSTEP1 == -1:
            print(
                "This subject could not be run. Please check the logs for more information."
            )
            return -1
    if jobSTEP1[-3:] == ",-1":
        jobSTEP1 = jobSTEP1[:-3]

    # print(f"jobSTEP1: {jobSTEP1}")
    # jobSTEP1 = int(jobSTEP1)

    # if runTopup:
    jobSTEP2 = bb_pipeline_func(subject, jobSTEP1, fileConfig)
    jobSTEP3 = bb_pipeline_diff(subject, jobSTEP2, fileConfig)

    jobSTEP4 = bb_IDP(
        subject, str(jobSTEP1) + "," + str(jobSTEP2) + "," + str(jobSTEP3), fileConfig
    )

    jobSTEP5 = tvb_bb_QC(
        subject,
        str(jobSTEP1) + "," + str(jobSTEP2) + "," + str(jobSTEP3) + "," + str(jobSTEP4),
        fileConfig,
    )

    LT.finishLogging(logger)
    return jobSTEP5


if __name__ == "__main__":
    main()
