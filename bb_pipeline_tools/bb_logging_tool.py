#!/bin/env python
#
# Script name: bb_logging_tool.py
#
# Description: Set of functions to do proper logging for python scripts.
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
import time
import logging
from subprocess import run
import shlex


def init_logging(file_name, subject, batching=False):
    """
    initLogging initializes the logging system for the given python file and subject.

    Args:
        file_name:   The name of the current python file, typically supplied as '__file__'
        subject:    The name of the subject file being run.
        batching:   ?

    Returns:
        A python logger object
    """
    script_name = os.path.basename(file_name)
    script_name_index = script_name.rfind(".")
    if script_name_index != -1:
        script_name = script_name[0:script_name_index]

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(script_name)
    logger.propagate = False
    if batching:
        log_dir = os.path.abspath(
            os.path.join(os.getcwd() + "/../" + subject + "/logs/")
        )
    else:
        log_dir = os.getcwd() + "/" + subject + "/logs/"
    # log_dir = "../../logs/"
    if not os.path.isdir(log_dir):
        os.mkdir(log_dir)

    subj = subject.split("/")[-1]
    log_file_name = (
            log_dir + "/" + script_name + "__" + subject + "__" + str(os.getpid()) + ".log"
    )
    # log_file_name = (
    #    log_dir + "/" + script_name + "__" + subj + "__" + str(os.getpid()) + ".log"
    # )
    log_file = logging.FileHandler(log_file_name)
    log_file.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s ")
    )
    logger.addHandler(log_file)
    logger.info("Starting the subject processing: " + str(time.ctime(int(time.time()))))
    logger.info("Subject received as input: " + subject)

    logger.logDir = log_dir

    return logger


def finish_logging(logger):
    """
    Completes the logging processes with a final message to the logger

    Args:
        logger: The python logger object
    """
    logger.info(
        "Main processing file finished at: " + str(time.ctime(int(time.time())))
    )


def run_command(logger, command, job_name):
    """
    Performs the specified command and logs the resulting output.

    Args:
        logger:     The python logging object.
        command:    The command to be run.
        job_name:   The name of the current job.

    Returns:    None: Writes to corresponding log files specified by the logger object.
    """
    try:
        logger.info("COMMAND TO RUN: \t" + command.strip())

        # resolve environment var filepaths and parse
        command_list = shlex.split(os.path.expandvars(command))

        # perform the commands
        job_output = run(command_list, capture_output=True, text=True)
        # job_output=popen(command, stdout=PIPE, stderr=STDOUT, shell=True)
        log_file = f"{job_name}.log"
        log_file = os.path.join(logger.logDir, log_file)

        f = open(log_file, "a+")
        f.write("STANDARD OUT:\n")
        f.write(job_output.stdout)

        f.write("\n\nSTANDARD ERROR:\n")
        f.write(job_output.stderr)

        f.close()

        # TODO: remove decode since there's no need to do so
        # job_output=job_output.decode("UTF-8")
        logger.info("COMMAND OUTPUT: \t" + job_output.stderr)

    except Exception as e:
        logger.error("Exception raised during execution of: \n\t" + command.strip())
        logger.error("Exception type: \n\t" + str(type(e)))
        logger.error("Exception args: \n\t" + str(e.args))
        logger.error("Exception message: \n\t" + str(e))
