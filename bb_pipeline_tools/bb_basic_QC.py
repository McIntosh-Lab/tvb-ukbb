#!/bin/env python
#
# Script name: bb_basic_QC.py
#
# Description: Script to run a basic QC test checking the dims of the image.
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
import glob
import json
import nibabel as nib
import bb_logging_tool as LT
import sys,argparse,os.path
import numpy as np
import bb_general_tools.bb_path as bb_path
from bb_file_manager import bb_file_manager

logger=None
idealConfig={}
fileConfig={}

class MyParser(argparse.ArgumentParser):
    def error(self, message):
        sys.stderr.write('error: %s\n' % message)
        self.print_help()
        sys.exit(2)

class Usage(Exception):
    def __init__(self, msg):
        self.msg = msg

def make_unusable(fileName, list_dependent_dirs):

    if fileName.startswith("rfMRI"):
        direc='fMRI'
        os.chdir(direc)
        files_in_dir=glob.glob('./rfMRI*')

        if not 'unusable' in files_in_dir:
            os.mkdir('unusable')
            for file_to_move in files_in_dir:
                os.rename(file_to_move, 'unusable/'+file_to_move)
            f = open('info_rfMRI.txt', 'a')
            f.write('4 0 Missing needed file/modality')
            f.close()

    elif fileName.startswith("tfMRI"):
        direc='fMRI'
        os.chdir(direc)
        files_in_dir=glob.glob('./tfMRI*')

        if not 'unusable' in files_in_dir:
            os.mkdir('unusable')
            for file_to_move in files_in_dir:
                os.rename(file_to_move, 'unusable/'+file_to_move)
            f = open('info_tfMRI.txt', 'a')
            f.write('4 0 Missing needed file/modality')
            f.close()
        

    else:
        for direc in list_dependent_dirs:

            os.chdir(direc)
            files_in_dir=glob.glob('./*')

            if not 'unusable' in files_in_dir:
                os.mkdir('unusable')
                for file_to_move in files_in_dir:
                    os.rename(file_to_move, 'unusable/'+file_to_move)

                f = open('info.txt', 'w')

                if direc=='T1':
                    f.write('2 0 Missing T1')
                else:
                    f.write('4 0 Missing needed modality')
                f.close()
 
            os.chdir('..')
                

def bb_basic_QC(subject, fileConfig):

    keysToPop=[]
    global logger

    logger = LT.initLogging(__file__, subject) 

    idealConfigFile=os.environ['BB_BIN_DIR'] + '/bb_data/ideal_config_sizes.json'
    with open(idealConfigFile, 'r') as f:
        idealConfig=json.load(f)

    os.chdir(subject)
    fd_fileName="logs/file_descriptor.json"

    for fileN in fileConfig:
        if not isinstance(fileConfig[fileN], list):

            if bb_path.isImage(fileConfig[fileN]):
                fils=bb_path.removeImageExt(fileConfig[fileN])   
      
                if os.path.isfile(fils+"_orig.nii.gz"):
                    fileList=[fils+"_orig.nii.gz"]
                else:
                    fileList=[fileConfig[fileN]]

            else:
                fileList=[fileConfig[fileN]]
        else:
            fileList=fileConfig[fileN]
 
        for fileName in fileList:
            if os.path.isfile(fileName):
                if fileN in idealConfig:
                    img = nib.load(fileName)
                    dims = img.header['dim'][1:5]
                    if not np.all(dims == idealConfig[fileN]['dims']):
                        keysToPop.append(fileN)
                        #make_unusable(fileName, idealConfig[fileName]['dep_dirs'])
                        f = open('info_basic_QC.txt', 'a')
                        f.write('Problem in file ' + fileName+'\n')
                        f.close()

    for keyToPop in keysToPop:
        fileConfig.pop(keyToPop,None)

    fd=open(fd_fileName, "w")
    json.dump(fileConfig,fd,sort_keys=True,indent=4)        
    fd.close()

    os.chdir("..")

    return fileConfig


def main(): 
    parser = MyParser(description='BioBank basic QC tool')
    parser.add_argument("subjectFolder", help='Subject Folder')

    argsa = parser.parse_args()
    subject = argsa.subjectFolder
    subject = subject.strip()

    if subject[-1] =='/':
        subject = subject[0:len(subject)-1]
    logger = LT.initLogging(__file__, subject)
    logger.info('Running file manager') 

    idealConfigFile=os.environ['BB_BIN_DIR'] + '/bb_data/ideal_config.json'
    with open(idealConfigFile, 'r') as f:
        fileConfig=json.load(f)

    fileConfig = bb_basic_QC(subject, fileConfig)

if __name__ == "__main__":
    main()
 
