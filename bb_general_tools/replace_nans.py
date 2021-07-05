#!/bin/env python
#

import numpy as np

def replace_nans(matrix_file):
	mat = np.loadtxt(matrix_file)
	mat = np.nan_to_num(mat, nan=0.0, neginf=0.0)
	np.savetxt(matrix_file, mat)

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
    replace_nans(sys.argv[1])