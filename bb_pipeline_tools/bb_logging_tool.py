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


def initLogging(fileName, subject, batching=False):

    scriptName = os.path.basename(fileName)
    scriptNameIndex = scriptName.rfind(".")
    if scriptNameIndex != -1:
        scriptName = scriptName[0:scriptNameIndex]

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(scriptName)
    logger.propagate = False
    if batching:
        logDir = os.path.abspath(
            os.path.join(os.getcwd() + "/../" + subject + "/logs/")
        )
    else:
        logDir = os.getcwd() + "/" + subject + "/logs/"
    # logDir = "../../logs/"
    if not os.path.isdir(logDir):
        os.mkdir(logDir)

    subj = subject.split("/")[-1]
    logFileName = (
        logDir + "/" + scriptName + "__" + subject + "__" + str(os.getpid()) + ".log"
    )
    # logFileName = (
    #    logDir + "/" + scriptName + "__" + subj + "__" + str(os.getpid()) + ".log"
    # )
    logFile = logging.FileHandler(logFileName)
    logFile.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s ")
    )
    logger.addHandler(logFile)
    logger.info("Starting the subject processing: " + str(time.ctime(int(time.time()))))
    logger.info("Subject received as input: " + subject)

    logger.logDir = logDir

    return logger


def finishLogging(logger):

    logger.info(
        "Main processing file finished at: " + str(time.ctime(int(time.time())))
    )


def runCommand(logger, command, jobname):

    try:
        logger.info("COMMAND TO RUN: \t" + command.strip())
        jobOUTPUT=run(command, stdout=PIPE, stderr=STDOUT, shell=True)
        #jobOUTPUT=popen(command, stdout=PIPE, stderr=STDOUT, shell=True)
        logfile=jobname+".txt"
        logfile=os.path.join(logger.logDir,logfile)
        f= open( logfile ,"a+")
        f.write(jobOUTPUT.stdout)
        f.close()

        jobOUTPUT=jobOUTPUT.decode("UTF-8")
        logger.info("COMMAND OUTPUT: \t" + jobOUTPUT.strip())

    except Exception as e:
        logger.error("Exception raised during execution of: \t" + command.strip())
        logger.error("Exception type: \t" + str(type(e)))
        logger.error("Exception args: \t" + str(e.args))
        logger.error("Exception message: \t" + str(e))

        jobOUTPUT = ""
    return jobOUTPUT.strip()
