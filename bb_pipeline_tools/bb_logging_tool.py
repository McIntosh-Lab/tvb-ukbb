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
import textwrap

def init_logging(subject):
    """
    init_logging initializes the logging system for the given python file and subject. The function creates and returns
    a formatted python logger object.

    Args:
        subject:    The name of the subject file being run.

    Returns:
        A python logger object
    """
    
    # Set logger defaults
    formatter = "%(asctime)s - %(module)s - %(filename)s - -%(levelname)s - %(message)s"

    logging.basicConfig(level=logging.INFO, format=formatter)
    logger = logging.getLogger(module_name)
    logger.propagate = True

    # Make the requisite logging directory
    log_dir = os.getcwd() + "/" + subject + "/logs/"
    if not os.path.isdir(log_dir):
        os.mkdir(log_dir)

    info_handler = logging.FileHandler(log_dir + "/log_info.txt")
    info_handler.setLevel(logging.INFO)

    error_handler = logging.FileHandler(log_dir + "/log_error.txt")
    error_handler.setLevel(logging.ERROR)

    debug_handler = logging.FileHandler(log_dir + '/log_debug.txt')
    debug_handler.setLevel(logging.DEBUG)

    logger.info("Starting the subject processing: " + str(time.ctime(int(time.time()))))
    logger.info("Subject received as input: " + subject)

    logger.debug("Starting the subject processing: " + str(time.ctime(int(time.time()))))
    logger.debug("Subject received as input: " + subject)

    logger.log_dir = log_dir

    return logger


def run_command(logger, command, job_name):
    """
    Performs the specified command and logs the resulting output.

    Args:
        logger:     The python logging object.
        command:    The command to be run.
        job_name:   The name of the current job.

    Returns:    None: Writes to corresponding log files specified by the logger object.
    """

    # Standard out/error printing indentation level
    indent_level = 4

    try:

        # resolve environment var filepaths and parse
        command_list = shlex.split(os.path.expandvars(command))

        logger.info("RUNNING: \t" + command.strip())

        # perform the designated commands and capture output
        job_output = run(command_list, capture_output=True, text=True)

        logger.info("STANDARD OUT:")
        logger.info(textwrap.indent("\n" + job_output.stdout, ' ' * indent_level))

        logger.info("STANDARD ERROR:")
        logger.info(textwrap.indent("\n" + job_output.stderr, ' ' * indent_level))

    except Exception as e:
        logger.error("Exception raised during execution of: \n\t" + command.strip())
        logger.error("Exception type: \n\t" + str(type(e)))
        logger.error("Exception args: \n\t" + str(e.args))
        logger.error("Exception message: \n\t" + str(e))
