#!/bin/env python

import nibabel as nib
import numpy as np
import sys
import csv
import os
np.set_printoptions(threshold=sys.maxsize)


def generate_susceptiblity_mask(image):
	
	
	img = nib.load(image)
	data = img.get_fdata()
	print(data)
	print("\n")
	result = np.where(data==1)
	print(result)


if __name__ == "__main__":
    """Function that generates SC, FC, TL, TS plots for QC html report
    for a subject.
    
    Usage
    ----------
    python  SC_FC.py  subj
    
    Arguments
    ----------
    subj : 
        Full path to subject's directory.
    """
    # try:
    generate_susceptiblity_mask(sys.argv[1])


