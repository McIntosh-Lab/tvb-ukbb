#!/bin/env python


import numpy as np
import sys



def bb_post_probtrackx2(subj):
    
# bb_post_probtrackx2 saves a set of SC, FC and timeseries plots for a sub where sub is a full file path to sub
#
# USAGE:
#   bb_post_probtrackx2(sub)
#
#   from command line:     python bb_post_probtrackx2.py <subjectdir>
#

        
        m = 1
        fdt=""
        way=""
        for m in range (1,11):
            batch_dir = (subj + '/dMRI/probtrackx/batch_'+str(m))
            
            if m == 0:
                fdt = np.loadtxt(batch_dir + '/fdt_network_matrix')
                way = np.loadtxt(batch_dir + '/waytotal')
            else:

                fdt = np.add(fdt, np.loadtxt(batch_dir + '/fdt_network_matrix'))
                way = np.add(way, np.loadtxt(batch_dir + '/waytotal'))


        SC=np.divide(fdt,way)

        np.savetxt(subj + "/dMRI/probtrackx/fdt_network_matrix",fdt)
        np.savetxt(subj + "/dMRI/probtrackx/waytotal",way)
        np.savetxt(subj + "/dMRI/sc.txt",SC)
        



        m = 1
        mat_lengths=""
        fdt1=""
        mtx=""
        mat_sum=""
        for m in range (1,11):
            batch_dir = (subj + '/dMRI/probtrackx/batch_'+str(m))
            
            if m == 0:
                mat_lengths = np.loadtxt(batch_dir + '/fdt_network_matrix_lengths')
                fdt1 = np.loadtxt(batch_dir + '/fdt_network_matrix')
                mtx = np.multiply(fdt1, mat_lengths)
                mat_sum = fdt1
            else:

                mat_lengths = np.loadtxt(batch_dir + '/fdt_network_matrix_lengths')
                fdt1 = np.loadtxt(batch_dir + '/fdt_network_matrix')
                mtx = np.add(mtx, np.multiply(fdt1, mat_lengths))
                mat_sum = np.add(mat_sum, fdt1)
                

        tract_lengths = np.divide(mtx,mat_sum)

        np.savetxt(subj + "/dMRI/probtrackx/fdt_network_matrix_lengths",tract_lengths)
    
        



if __name__ == "__main__":
    #try:
    bb_post_probtrackx2(sys.argv[1])
    #except:
        #print("ERROR. Usage: python bb_post_probtrackx2.py subj_list \nsubj_list: a .txt file of subject directories with the full path specified\nADNI_or_CAMCAN: 0 for ADNI populations, 1 for CAMCAN populations")
        
    #TODO more error handling here and in function def to deal with invalid files and paths