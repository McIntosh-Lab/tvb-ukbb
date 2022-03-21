#!/bin/env python
#
# Script name: consistency_thresholding.py
#
#
# Description: Script to consistency threshold a group of processed subjects' structural 
# connectivity matrices.  
#
#
# Usage: python consistency_thresholding.py <zip_dir> <threshold> <subject_list> <PARC_NAME>
#
# NOTE: existing tvb_inputs.zip file names should follow the following format:
#          
#                    subjectName_parcellationName_tvb_inputs.zip
#
#
# Parameters:   zip_dir         -   path to directory containing tvb_inputs.zip files for all 
#                               subjects to be consistency thresholded
#                               
#               threshold       -   float representing rate at which each structural connection  
#                               should appear (have a non-zero probability of connection) in the 
#                               group of subjects. (e.g. threshold=0.4 will eliminate any 
#                               connections, from all subjects, that dont appear in at least 40% of 
#                               subjects)     
#               
#               subject_list    -   path to text file containing subject names, one per line, to be
#                               thresholded
#
#               PARC_NAME       -   name of parcellation. use "" if these zip files were created 
#                               with an earlier version of the pipeline that did not specify 
#                               parcellations in tvb_input.zip filenames 
#
#
# Output: new thresholded_tvb_inputs directory in zip_dir, containing all subjects' new   
# tvb_inputs.zip files with newly thresholded weights.txt (SC matrix files)
#
#
## Author: Justin Wang

import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib
import os
import copy
import zipfile
import shutil

def consistency_thresholding(zip_dir, threshold, subject_list, PARC_NAME):
    """Script to consistency threshold a group of processed subjects' structural 
     connectivity matrices.


    Arguments
    ----------
    zip_dir : 
        path to directory containing tvb_inputs.zip files for all 
        subjects to be consistency thresholded

    threshold : 
        float representing rate at which each structural connection  
        should appear (have a non-zero probability of connection) in the 
        group of subjects. (e.g. threshold=0.4 will eliminate any 
        connections, from all subjects, that dont appear in at least 40% of 
        subjects) 

    subject_list : 
        path to text file containing subject names, one per line, to be
        thresholded

    PARC_NAME :
        name of parcellation. use "" if these zip files were created 
        with an earlier version of the pipeline that did not specify 
        parcellations in tvb_input.zip filenames

    """


    #make output dir
    outputdir=os.path.join(zip_dir,"thresholded_tvb_inputs")
    if not os.path.exists(outputdir):
        os.makedirs(outputdir)

    #import subject names into an array
    subjects = []
    with open(subject_list) as subject_list_file:
        for line in subject_list_file:
            subjects.append(line)

    consistency_mask=""
    subcounter=0

    #unzip each subject into output dir
    for subject in subjects:

        #source zip name
        subject_file_name = ""
        #path to source zip
        subject_zip = ""

        #different source zip name and path if PARC_NAME present
        if PARC_NAME=="":
            subject_file_name = subject+"_tvb_inputs.zip"
            subject_zip = os.path.join(zip_dir,subject_file_name)
        else:
            subject_file_name = subject+"_"+PARC_NAME+"_tvb_inputs.zip"
            subject_zip = os.path.join(zip_dir,subject_file_name)

        #unzip subject
        if os.path.exists(subject_zip):
            with zipfile.ZipFile(subject_zip, 'r') as zip_ref:
                zip_ref.extractall(outputdir)

            #past version of pipeline generates SUBJECTNAME_tvb_inputs.zip, but once uncompressed, the resulting tvb_inputs dir not have SUBJECTNAME in the filename.
            #if name of uncompressed dir from this subj zip is ambiguous, give it a better name 
            ambiguous_dir=os.path.join(outputdir,"tvb_inputs")
            specific_dir=os.path.join(outputdir,subject_file_name[:-4])
            end_dir=""
            # dont rename uncompressed zip because user is not expecting it
            # if os.path.exists(ambiguous_dir):
                # os.rename(ambiguous_dir,specific_dir)

            if os.path.exists(specific_dir):
                end_dir=specific_dir
            if os.path.exists(ambiguous_dir):
                end_dir=ambiguous_dir

            #past version of pipeline generates SUBJECTNAME_tvb_structural_inputs.zip within the tvb_inputs directory.
            #new version generates structural_inputs.zip instead
            specific_struct_zip=os.path.join(end_dir,subject+"_tvb_structural_inputs.zip")
            ambiguous_struct_zip=os.path.join(end_dir,"structural_inputs.zip")

            #unzip struct inputs
            struct_zip=""
            if os.path.exists(specific_struct_zip):
                struct_zip=specific_struct_zip
            if os.path.exists(ambiguous_struct_zip):
                struct_zip=ambiguous_struct_zip

            with zipfile.ZipFile(struct_zip, 'r') as zip_ref:
                zip_ref.extractall(end_dir)

            #path to SC
            SC_path=os.path.join(end_dir,"structural_inputs","weights.txt")
            
            SC=""
            if os.path.exist(SC_path):
                SC=np.loadtxt(SC_path)

                #binarize SC and add to consistency mask to track how many subs have a connnection for each connection 
                SC=np.where(SC>0, 1, 0)
                if consistency_mask=="":
                    consistency_mask=SC
                else:
                    consistency_mask=consistency_mask+SC
                subcounter = subcounter+1
            
            #delete dir if ambiguous
            if os.path.exists(ambiguous_dir):
                shutil.rmtree(ambiguous_dir)

    #binarize consistency mask, thresholded by (#subs * threshold %)
    min_sub_count = threshold*subcounter
    consistency_mask=np.where(consistency_mask>=min_sub_count, 1, 0)

    #go into each subject and edit their weights.txt
    for subject in subjects:
        
        #source zip name
        subject_file_name = ""
        #path to source zip
        subject_zip = ""
        output_zip = ""

        #different source zip name and path if PARC_NAME present
        if PARC_NAME=="":
            subject_file_name = subject+"_tvb_inputs.zip"
            subject_zip = os.path.join(zip_dir,subject_file_name)
            output_zip = os.path.join(outputdir,subject_file_name)
        else:
            subject_file_name = subject+"_"+PARC_NAME+"_tvb_inputs.zip"
            subject_zip = os.path.join(zip_dir,subject_file_name)
            output_zip = os.path.join(outputdir,subject_file_name)
        
        if os.path.exists(subject_zip):

            #if specific dir exists then skip unzipping
            specific_dir=os.path.join(outputdir,subject_file_name[:-4])
            end_dir=""
            if os.path.exists(specific_dir):
                end_dir=specific_dir
            else:
                with zipfile.ZipFile(subject_zip, 'r') as zip_ref:
                    zip_ref.extractall(outputdir)
                
                end_dir=os.path.join(outputdir,"tvb_inputs")
                
                specific_struct_zip=os.path.join(end_dir,subject+"_tvb_structural_inputs.zip")
                ambiguous_struct_zip=os.path.join(end_dir,"structural_inputs.zip")

                struct_zip=""
                if os.path.exists(specific_struct_zip):
                    struct_zip=specific_struct_zip
                if os.path.exists(ambiguous_struct_zip):
                    struct_zip=ambiguous_struct_zip

                with zipfile.ZipFile(struct_zip, 'r') as zip_ref:
                    zip_ref.extractall(end_dir)

            SC_path=os.path.join(end_dir,"structural_inputs","weights.txt")
            
            #load SCs again and apply consistency mask
            SC=""
            if os.path.exist(SC_path):
                SC=np.loadtxt(SC_path)
                SC=consistency_mask*SC
                np.savetxt(SC_path, SC)

            


            #zip and clean up
            if os.path.exists(os.path.join(end_dir,"structural_inputs")):
                

                #find struct zip to overwrite
                specific_struct_zip=os.path.join(end_dir,subject+"_tvb_structural_inputs.zip")
                ambiguous_struct_zip=os.path.join(end_dir,"structural_inputs.zip")

                struct_zip=""
                if os.path.exists(specific_struct_zip):
                    struct_zip=specific_struct_zip
                if os.path.exists(ambiguous_struct_zip):
                    struct_zip=ambiguous_struct_zip

                #remove existing zip and save new for structural inputs
                shutil.rmtree(struct_zip)
                shutil.make_archive(struct_zip, 'zip', os.path.join(end_dir,"structural_inputs"))

                #remove uncompressed structural inputs dir
                shutil.rmtree(os.path.join(end_dir,"structural_inputs"))

                #make zip for this sub
                shutil.make_archive(output_zip, 'zip', end_dir)

                shutil.rmtree(end_dir)



if __name__ == "__main__":
    """Script to consistency threshold a group of processed subjects' structural 
     connectivity matrices.

    
    Usage
    ----------
    python consistency_thresholding.py <zip_dir> <threshold> <subject_list> <PARC_NAME>
    

    Arguments
    ----------
    zip_dir : 
        path to directory containing tvb_inputs.zip files for all 
        subjects to be consistency thresholded

    threshold : 
        float representing rate at which each structural connection  
        should appear (have a non-zero probability of connection) in the 
        group of subjects. (e.g. threshold=0.4 will eliminate any 
        connections, from all subjects, that dont appear in at least 40 percent of 
        subjects) 

    subject_list : 
        path to text file containing subject names, one per line, to be
        thresholded

    PARC_NAME :
        name of parcellation. use "" if these zip files were created 
        with an earlier version of the pipeline that did not specify 
        parcellations in tvb_input.zip filenames

    """
    # try:
    consistency_thresholding(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])

    