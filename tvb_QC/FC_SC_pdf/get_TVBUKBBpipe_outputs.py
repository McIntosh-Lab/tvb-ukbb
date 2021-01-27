import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib 

#increasing font size
font = {'size'   : 30}
matplotlib.rc('font', **font)


def get_TVBUKBBpipe_outputs(subj_list, out_dir):
    
# get_TVBUKBBpipe_outputs saves a set of SC, FC and timeseries plots for
# each subject in subj_list
#
# USAGE:
#   get_TVBUKBBpipe_outputs(subj_list, out_dir)
#
# where subj_list is a .txt file of subject directories with the full path
# specified, and out_dir is where each subject's plots will be saved


    with open(subj_list) as my_file:
        subjDirs = my_file.read().splitlines() 
    
    for subj in subjDirs:

        subjName=subj[subj.find('sub'):]

        SC_abs=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix')
        waytotal=np.loadtxt(subj + '/dMRI/probtrackx/waytotal')
        SC=np.divide(SC_abs,waytotal)

        tract_lengths=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix_lengths')
        FC=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/fc.txt')   #rfMRI.ica does not exist in the sample data... replaced with rfMRI_1.ica for now
        norm_ts=zscore(np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt'));   #rfMRI.ica does not exist in the sample data... replaced with rfMRI_1.ica for now

        f, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(50, 50))
        
        #division by 0 occurs in np.log10(SC) if 0 values aren't turned into small values
        for i in range(SC.shape[0]):
            for j in range(SC.shape[1]):
                if SC[i][j] == 0:
                   SC[i][j] = 10**-10
                
                
        ax1.set_title('SC')
        im1= ax1.imshow(np.log10(SC))
        f.colorbar(im1, ax=ax1)
        
        ax2.set_title('tract length')
        im2= ax2.imshow(tract_lengths)
        f.colorbar(im2, ax=ax2)
        
        ax3.set_title('FC')
        im3= ax3.imshow(FC)
        f.colorbar(im3, ax=ax3)
        
        ax4.set_xlabel('volume')
        ax4.set_ylabel('ROI')
        ax4.set_title('ROI timeseries carpet plot')
        im4= ax4.imshow(norm_ts.transpose(), cmap='gray', aspect = 'auto')
       
        saveNm=out_dir + '/' +subjName + '_SCFC.pdf'
        f.savefig(saveNm)


#get_TVBUKBBpipe_outputs('', '')


if __name__ == "__main__":
    try:
        get_TVBUKBBpipe_outputs(sys.argv[1],sys.argv[2])
    except:
        print("ERROR. Usage: python get_TVBUKBBpipe_outputs.py subj_list out_dir\nsubj_list: a .txt file of subject directories with the full path specified\nout_dir: directory where each subject's plots will be saved")
        
    #TODO more error handling here and in function def to deal with invalid files and paths