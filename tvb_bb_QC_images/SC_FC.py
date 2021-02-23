import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib 
import os

#increasing font size
font = {'size'   : 30}
matplotlib.rc('font', **font)


def SC_FC_png(subj):
    
# SC_FC_png saves a set of SC, FC and timeseries plots for a sub where sub is a full file path to sub
#
# USAGE:
#   SC_FC_png(sub)
#




  


        if not os.path.exists(subj + '/QC/SC_FC/'):
            os.makedirs(subj + '/QC/SC_FC/')
        



        subjName=subj[subj.rfind('sub'):]

        SC_abs=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix')
        waytotal=np.loadtxt(subj + '/dMRI/probtrackx/waytotal')
        SC=np.divide(SC_abs,waytotal)

        tract_lengths=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix_lengths')
        

        f, ax1, ax2, ax3, ax4, ax5, ax6 = "","","","","","",""


        if os.path.isfile(subj + '/fMRI/rfMRI.ica/fc.txt'):
            try:
                FC=np.loadtxt(subj + '/fMRI/rfMRI.ica/fc.txt')   
                norm_ts=zscore(np.loadtxt(subj + '/fMRI/rfMRI.ica/ts.txt'))
                #norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

            except:
                print("ERROR: file not found")

            f, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(50, 50))
        

        else:     
            try:
                FC_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/fc.txt')   
                norm_ts_0=zscore(np.loadtxt(subj + '/fMRI/rfMRI_0.ica/ts.txt'))
                #norm_ts_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

            except:
                print("ERROR: file not found")
                

            try:
                FC_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/fc.txt')   
                norm_ts_1=zscore(np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt'))
                #norm_ts_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt');

            except:
                print("ERROR: file not found")


            f, ((ax1, ax2), (ax3, ax4), (ax5, ax6)) = plt.subplots(3, 2, figsize=(50, 50))
            
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
        

        if os.path.isfile(subj + '/fMRI/rfMRI.ica/fc.txt'):
            try:
                ax3.set_title('FC')
                im3= ax3.imshow(FC)
                f.colorbar(im3, ax=ax3)
                
                ax4.set_xlabel('volume')
                ax4.set_ylabel('ROI')
                ax4.set_title('ROI timeseries carpet plot')
                im4= ax4.imshow(norm_ts.transpose(), cmap='gray', aspect = 'auto')
            except:
                print("ERROR: can't generate graph")

        else:
            try:
                ax3.set_title('FC_0')
                im3= ax3.imshow(FC_0)
                f.colorbar(im3, ax=ax3)
                
                ax4.set_xlabel('volume')
                ax4.set_ylabel('ROI')
                ax4.set_title('ROI timeseries carpet plot')
                im4= ax4.imshow(norm_ts_0.transpose(), cmap='gray', aspect = 'auto')
            except:
                print("ERROR: can't generate graph")


            try:
                ax5.set_title('FC_1')
                im5= ax5.imshow(FC_1)
                f.colorbar(im5, ax=ax5)
                
                ax6.set_xlabel('volume')
                ax6.set_ylabel('ROI')
                ax6.set_title('ROI timeseries carpet plot')
                im6= ax6.imshow(norm_ts_1.transpose(), cmap='gray', aspect = 'auto')
            except:
                print("ERROR: can't generate graph")
 
        saveNm=subj + '/QC/SC_FC/' +subjName + '_SCFC.png'
        f.savefig(saveNm)





if __name__ == "__main__":
    #try:
    SC_FC_png(sys.argv[1])
    #except:
        #print("ERROR. Usage: python SC_FC_png.py subj_list \nsubj_list: a .txt file of subject directories with the full path specified\nADNI_or_CAMCAN: 0 for ADNI populations, 1 for CAMCAN populations")
        
    #TODO more error handling here and in function def to deal with invalid files and paths