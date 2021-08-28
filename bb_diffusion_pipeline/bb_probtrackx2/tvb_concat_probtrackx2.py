#!/bin/env python
#
# Script name: tvb_concat_probtrackx2.py
#
# Description: Script to generate dMRI/probtrackx data matrices. 
#
## Author: Justin Wang

import numpy as np
import sys


def tvb_concat_probtrackx2(subj):
    """Function that generates distance, fdt_network_matrix.txt,
    SC, waytotal, fdt_network_matrix for a subject.


    Parameters
    ----------
    subj : 
        Full path to subject's directory.

    """
   


    #calculating and saving SC, fdt_network_matrix, waytotal from all 10 batches 
    m = 1
    fdt = ""
    way = ""

    for m in range(1, 11):
        batch_dir = subj + "/dMRI/probtrackx/batch_" + str(m)

        if m == 1:
            fdt = np.loadtxt(batch_dir + "/fdt_network_matrix")
            way = np.loadtxt(batch_dir + "/waytotal")
        else:
            fdt = np.add(fdt, np.loadtxt(batch_dir + "/fdt_network_matrix"))
            way = np.add(way, np.loadtxt(batch_dir + "/waytotal"))

    ones=np.ones(fdt.shape)
    way_matrix = np.multiply(way,ones)
    way_matrix = way_matrix.T
    
    SC = np.divide(fdt, way_matrix)

    #symmetrizing matrix
    SC = (SC + SC.T) / 2

    np.savetxt(subj + "/dMRI/probtrackx/fdt_network_matrix", fdt)
    np.savetxt(subj + "/dMRI/probtrackx/waytotal", way)
    np.savetxt(subj + "/dMRI/sc.txt", SC)



    #calculating and saving distance, fdt_network_matrix_lengths from all 10 batches
    m = 1
    mat_lengths = ""
    fdt1 = ""
    mtx = ""
    mat_sum = ""
    for m in range(1, 11):
        batch_dir = subj + "/dMRI/probtrackx/batch_" + str(m)

        if m == 1:
            mat_lengths = np.loadtxt(batch_dir + "/fdt_network_matrix_lengths")
            fdt1 = np.loadtxt(batch_dir + "/fdt_network_matrix")
            mtx = np.multiply(fdt1, mat_lengths)
            mat_sum = fdt1
        else:
            mat_lengths = np.loadtxt(batch_dir + "/fdt_network_matrix_lengths")
            fdt1 = np.loadtxt(batch_dir + "/fdt_network_matrix")
            mtx = np.add(mtx, np.multiply(fdt1, mat_lengths))
            mat_sum = np.add(mat_sum, fdt1)

    tract_lengths = np.divide(mtx, mat_sum)
    np.savetxt(subj + "/dMRI/probtrackx/fdt_network_matrix_lengths", tract_lengths)

    #symmetrizing matrix
    tract_lengths = (tract_lengths + tract_lengths.T) / 2
    np.savetxt(subj + "/dMRI/distance.txt", tract_lengths)


if __name__ == "__main__":
    """Function that generates distance, fdt_network_matrix.txt,
    SC, waytotal, fdt_network_matrix for a subject.

    
    Usage
    ----------
    python  tvb_concat_probtrackx2.py  subj
    

    Arguments
    ----------
    subj : 
        Full path to subject's directory.

    """
    # try:
    tvb_concat_probtrackx2(sys.argv[1])

