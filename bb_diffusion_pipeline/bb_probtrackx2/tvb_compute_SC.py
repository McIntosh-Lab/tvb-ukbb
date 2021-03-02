'''
Function to compute SC matrix after probtrackx2 computes the
fdt_network_matrix and waytotal

@Author: Noah Frazier-Logue
'''

import numpy as np
import sys

def compute_SC(subj_name_dmri):
    SC_abs = np.load(subj_name_dmri + "/probtrackx/fdt_network_matrix")
    waytotal = np.load(subj_name_dmri + "/probtrackx/waytotal")
    SC = np.divide(SC_abs, waytotal)
    np.savetxt(subj_name_dmri + "/sc.txt", SC)


if __name__ == "__main__":

    # will be of form '<path>/<subj_name>/dMRI'
    subj_name_dmri = sys.argv[1]
    compute_SC(subj_name_dmri)
