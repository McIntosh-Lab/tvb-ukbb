#!/bin/env python
#
# Script name: rename_pve.py
#
# Description: Script to reorganize pve files according to mean intensity on brain image.
#
## Author: Justin Wang
import nibabel as nib
import numpy as np
import sys

import os

def rename_pve(brain,pve0,pve1,pve2):

	proper_pve_order = [pve0, pve1, pve2] #darkest to lightest. lowest intensity should be pve0, then pve1, then pve2

	#create temp files
	pve0temp=pve0[:-7]+"temp"+".nii.gz"
	pve1temp=pve1[:-7]+"temp"+".nii.gz"
	pve2temp=pve2[:-7]+"temp"+".nii.gz"
	os.rename(pve0,pve0temp)
	os.rename(pve1,pve1temp)
	os.rename(pve2,pve2temp)



	brain_img = nib.load(brain)
	brain_data = brain_img.get_fdata()

	pve0_img = nib.load(pve0temp)
	pve0_data = pve0_img.get_fdata()
	pve0_thresh = np.where(pve0_data >= 0.75)
	pve0_mean = np.mean(brain_data[pve0_thresh])

	pve1_img = nib.load(pve1temp)
	pve1_data = pve1_img.get_fdata()
	pve1_thresh = np.where(pve1_data >= 0.75)
	pve1_mean = np.mean(brain_data[pve1_thresh])

	pve2_img = nib.load(pve2temp)
	pve2_data = pve2_img.get_fdata()
	pve2_thresh = np.where(pve2_data >= 0.75)
	pve2_mean = np.mean(brain_data[pve2_thresh])

	print(pve0_mean)
	print(pve1_mean)
	print(pve2_mean)

	
	pve_value_list = [pve0_mean,pve1_mean,pve2_mean]
	idx=np.argsort(pve_value_list)
	pve_filename_list = [pve0temp,pve1temp,pve2temp]


	for i in range(3):
		os.rename(pve_filename_list[idx[i]], proper_pve_order[i])


if __name__ == "__main__":
    """Function that reorganizes pve files that have been mislabelled.

    
    Usage
    ----------
    python  rename_pve.py  brain pve0 pve1 pve2
    

    Arguments
    ----------
	brain: full file path to T1.nii.gz brain image
	
	pve0: full file path to pve0 nii gz
	
	pve1: full file path to pve1 nii gz

	pve2: full file path to pve2 nii gz



    """
    # try:
    rename_pve(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4])

