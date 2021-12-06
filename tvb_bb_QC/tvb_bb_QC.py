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


import os.path
import sys
import json

sys.path.insert(1, os.path.dirname(__file__) + "/..")
import bb_pipeline_tools.bb_logging_tool as LT


def tvb_bb_QC(subject, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]

    subname = subject.replace("/", "_")

    print("Beginning QC pipeline...")
    jobQC = LT.runCommand(
        logger,
        " xvfb-run -a $BB_BIN_DIR/tvb_bb_QC/tvb_bb_QC.sh "  # -s '-screen 0 640x480x24'
        + subject,
        "tvb_bb_QC_"
        + subname
    )
    print("QC pipeline complete.")
    return jobQC


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
    tvb_bb_QC(subject, fileConfig)
