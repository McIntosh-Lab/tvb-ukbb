#!/bin/env python


import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib 
import os

#increasing font size
font = {'size'   : 100}
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

        #SC_abs=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix')
        #waytotal=np.loadtxt(subj + '/dMRI/probtrackx/waytotal')
        #SC=np.divide(SC_abs,waytotal)
        

        SC=""
        try:
            SC=np.loadtxt(subj + '/dMRI/sc.txt')
        except:
            print("ERROR: sc file not found")

        tract_lengths=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix_lengths')
        

        f, ax1, ax2, ax3, ax4, ax5, ax6 = "","","","","","",""


        if os.path.isfile(subj + '/fMRI/rfMRI.ica/fc.txt'):
            try:
                FC=np.loadtxt(subj + '/fMRI/rfMRI.ica/fc.txt')   
                norm_ts=zscore(np.loadtxt(subj + '/fMRI/rfMRI.ica/ts.txt'))
                #norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

            except:
                print("ERROR: ts file not found")

            f, ax = plt.subplots(1, 1, figsize=(50, 50))
        

        else:     
            try:
                FC_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/fc.txt')   
                norm_ts_0=zscore(np.loadtxt(subj + '/fMRI/rfMRI_0.ica/ts.txt'))
                #norm_ts_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

            except:
                print("ERROR: rFMRI_0 ts file not found")
                

            try:
                FC_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/fc.txt')   
                norm_ts_1=zscore(np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt'))
                #norm_ts_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt');

            except:
                print("ERROR: rFMRI_1 ts file not found")


            
        try:    
            #division by 0 occurs in np.log10(SC) if 0 values aren't turned into small values
            #for i in range(SC.shape[0]):
            #    for j in range(SC.shape[1]):
            #        if SC[i][j] == 0:
            #           SC[i][j] = 10**-10
           
            
    
            f, ax = plt.subplots(1, 1, figsize=(50, 50))
            ax.set_title('SC')
            ax.set_facecolor('#000000')
            SC = np.log10(SC)
            im= ax.imshow(SC)
            f.colorbar(im, ax=ax)
            
            plt.tight_layout()
            saveNm=subj + '/QC/SC_FC/' +subjName + '_SC.png'
            f.savefig(saveNm)



            plt.clf()
            SC = SC[SC > float("-inf")]
            f = plt.hist(SC.ravel(), bins=100)
            saveNm=subj + '/QC/SC_FC/' +subjName + '_SC_hist.png'
            plt.savefig(saveNm)


        except: 
            print("ERROR: Can't create SC graph")
        try:
            
            
            
            tract_lengths_log=np.log10(tract_lengths)
            f, ax = plt.subplots(1, 1, figsize=(50, 50))
            ax.set_title('tract length')
            ax.set_facecolor('#000000')
            im= ax.imshow(tract_lengths_log)
            f.colorbar(im, ax=ax)
            
            plt.tight_layout()
            saveNm=subj + '/QC/SC_FC/' +subjName + '_TL.png'
            f.savefig(saveNm)



            plt.clf()
            tract_lengths=tract_lengths[tract_lengths!=0]
            f = plt.hist(tract_lengths.ravel(), bins=100)
            saveNm=subj + '/QC/SC_FC/' +subjName + '_TL_hist.png'
            plt.savefig(saveNm)

        except:
            print("ERROR: Can't create TL graph")

        if os.path.isfile(subj + '/fMRI/rfMRI.ica/fc.txt'):
            try:
                f, ax = plt.subplots(1, 1, figsize=(50, 50))
                ax.set_title('FC')
                im= ax.imshow(FC)
                f.colorbar(im, ax=ax)
                
                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC.png'
                f.savefig(saveNm)


                f, ax = plt.subplots(1, 1, figsize=(50, 50))
                ax.set_xlabel('volume')
                ax.set_ylabel('ROI')
                ax.set_title('ROI timeseries carpet plot')
                im= ax.imshow(norm_ts.transpose(), cmap='gray', aspect = 'auto')

                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_carpet.png'
                f.savefig(saveNm)



                plt.clf()
                f = plt.hist(FC.ravel(), bins=100)
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_hist.png'
                plt.savefig(saveNm)


            except:
                print("ERROR: can't generate graph")

        else:
            try:
                f, ax = plt.subplots(1, 1, figsize=(50, 50))
                ax.set_title('FC_0')
                im= ax.imshow(FC_0)
                f.colorbar(im, ax=ax)
                
                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_0.png'
                f.savefig(saveNm)


                f, ax = plt.subplots(1, 1, figsize=(50, 30))
                ax.set_xlabel('volume')
                ax.set_ylabel('ROI')
                ax.set_title('ROI timeseries carpet plot 0')
                im= ax.imshow(norm_ts_0.transpose(), cmap='gray', aspect = 'auto')
                ax.yaxis.set_label_position("right")
                ax.yaxis.tick_right()

                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_carpet_0.png'
                f.savefig(saveNm)

                plt.clf()
                f = plt.hist(FC_0.ravel(), bins=100)
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_0_hist.png'
                plt.savefig(saveNm)

            except:
                print("ERROR: can't generate graph")


            try:
                f, ax = plt.subplots(1, 1, figsize=(50, 50))
                ax.set_title('FC_1')
                im= ax.imshow(FC_1)
                f.colorbar(im, ax=ax)

                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_1.png'
                f.savefig(saveNm)
                

                f, ax = plt.subplots(1, 1, figsize=(50, 30))
                ax.set_xlabel('volume')
                ax.set_ylabel('ROI')
                ax.set_title('ROI timeseries carpet plot 1')
                im= ax.imshow(norm_ts_1.transpose(), cmap='gray', aspect = 'auto')

                ax.yaxis.set_label_position("right")
                ax.yaxis.tick_right()

                plt.tight_layout()
                saveNm=subj + '/QC/SC_FC/' +subjName + '_carpet_1.png'
                f.savefig(saveNm)

                plt.clf()
                f = plt.hist(FC_1.ravel(), bins=100)
                saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_1_hist.png'
                plt.savefig(saveNm)
            except:
                print("ERROR: can't generate graph")
        
        



if __name__ == "__main__":
    #try:
    SC_FC_png(sys.argv[1])
    #except:
        #print("ERROR. Usage: python SC_FC_png.py subj_list \nsubj_list: a .txt file of subject directories with the full path specified\nADNI_or_CAMCAN: 0 for ADNI populations, 1 for CAMCAN populations")
        
    #TODO more error handling here and in function def to deal with invalid files and paths