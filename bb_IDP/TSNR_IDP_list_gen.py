#!/bin/env python

import pandas as pd
import numpy as np
import sys
import os
import csv

def TSNR_IDP_list_gen(subj):

      i=0

      for file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".ica"):# TODO: check to make sure files get checked alphabetically - same order as bb_IDP_func_TSNR
                  line=[0]
                  line.append(file+"_TSNR") #_cleaned_TSNR #_num_vol
                  line.append("bb_IDP_func_TSNR")
                  line.append(i)
                  line.append("QC_"+file+"_inverse_tSMR")  #_cleaned_inverse_tSMR #_num_vol
                  line.append("ratio")
                  line.append("float")
                  line.append("Inverted temporal signal-to-noise ratio in the pre-processed "+file+" - reciprocal of median (across brain voxels) of voxelwise mean intensity divided by voxelwise timeseries standard deviation") #Inverted temporal signal-to-noise ratio in the artefact-cleaned pre-processed "+fmri_ver+" - reciprocal of median (across brain voxels) of voxelwise mean intensity divided by voxelwise timeseries standard deviation   #Number of volumes in "+fmri_ver+" scan
                  i=i+1

                  line1=[0]
                  line1.append(file+"_cleaned_TSNR") # #_num_vol
                  line1.append("bb_IDP_func_TSNR")
                  line1.append(i)
                  line1.append("QC_"+file+"_cleaned_inverse_tSMR")  # #_num_vol
                  line1.append("ratio")
                  line1.append("float")
                  line1.append("Inverted temporal signal-to-noise ratio in the artefact-cleaned pre-processed "+file+" - reciprocal of median (across brain voxels) of voxelwise mean intensity divided by voxelwise timeseries standard deviation") #   #Number of volumes in "+fmri_ver+" scan
                  i=i+1

                  line2=[0]
                  line2.append(file+"_num_vol") # #
                  line2.append("bb_IDP_func_TSNR")
                  line2.append(i)
                  line2.append("QC_"+file+"_num_vol")  # #
                  line2.append("volumes")
                  line2.append("int")
                  line2.append("Number of volumes in "+file+" scan") #   #
                  i=i+1

                  #TODO: insert line, line1, line2 into ukbb_IDP_list.txt

      file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".feat"):
                  line=[0]
                  line.append(file+"_TSNR") #_cleaned_TSNR #_num_vol
                  line.append("bb_IDP_func_TSNR")
                  line.append(i)
                  line.append("QC_"+file+"_inverse_tSMR")  #_cleaned_inverse_tSMR #_num_vol
                  line.append("ratio")
                  line.append("float")
                  line.append("Inverted temporal signal-to-noise ratio in the pre-processed "+file+" - reciprocal of median (across brain voxels) of voxelwise mean intensity divided by voxelwise timeseries standard deviation") #Inverted temporal signal-to-noise ratio in the artefact-cleaned pre-processed "+fmri_ver+" - reciprocal of median (across brain voxels) of voxelwise mean intensity divided by voxelwise timeseries standard deviation   #Number of volumes in "+fmri_ver+" scan
                  i=i+1

                  line2=[0]
                  line2.append(file+"_num_vol") # #
                  line2.append("bb_IDP_func_TSNR")
                  line2.append(i)
                  line2.append("QC_"+file+"_num_vol")  # #
                  line2.append("volumes")
                  line2.append("int")
                  line2.append("Number of volumes in "+file+" scan") #   #
                  i=i+1
                  

                  #TODO: insert line, line1, line2 into ukbb_IDP_list.txt

                  
if __name__ == "__main__":
    """Function that updates the ukbb_IDP_list txt file.

    
    Usage
    ----------
    python  IDP_html_gen.py  IDP_list_path
    

    Arguments
    ----------


    BB_BIN_DIR: path to tvb pipeline tvb-ukbb


    PARC_LUT: path to LUT.txt


    """
    # try:
      TSNR_IDP_list_gen(sys.argv[1])
