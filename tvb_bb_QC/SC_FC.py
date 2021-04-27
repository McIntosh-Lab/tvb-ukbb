#!/bin/env python


import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib 
import os
import copy

#increasing font size
font = {'size'   : 100}
matplotlib.rc('font', **font)


def SC_FC_png(subj):
    
# SC_FC_png saves a set of SC, FC and timeseries plots for a sub where sub is a full file path to sub
#
# USAGE:
#   SC_FC_png(sub)
#



        if subj.endswith('/'):
            subj = subj[:-1]
  


        if not os.path.exists(subj + '/QC/SC_FC/'):
            os.makedirs(subj + '/QC/SC_FC/')
        




        subjName=subj[subj.rfind('/')+1:]

        

        #SC_abs=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix')
        #waytotal=np.loadtxt(subj + '/dMRI/probtrackx/waytotal')
        #SC=np.divide(SC_abs,waytotal)
        

        SC=""
        try:
            SC=np.loadtxt(subj + '/dMRI/sc.txt')
        except:
            print("ERROR: sc file not found")

        #tract_lengths=np.loadtxt(subj + '/dMRI/probtrackx/fdt_network_matrix_lengths')
        tract_lengths=""
        try:
            tract_lengths=np.loadtxt(subj + '/dMRI/distance.txt')
        except:
            print("ERROR: distance file not found")

        f, ax1, ax2, ax3, ax4, ax5, ax6 = "","","","","","",""




        for file in os.listdir(subj + '/fMRI/'):
            if file.endswith(".ica"):
                fc_path=(os.path.join(subj + '/fMRI/', file, 'fc.txt'))
                ts_path=(os.path.join(subj + '/fMRI/', file, 'ts.txt'))
                
                FC=""
                norm_ts=""
                
                try:
                    FC=np.loadtxt(fc_path)   
                    norm_ts=zscore(np.loadtxt(ts_path))
                    #norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

                except:
                    print("ERROR: fc, ts file not found")


                try:
                    file_name_no_period=file.replace(".", "_")

                    FC_matrix=copy.deepcopy(FC)
                    for i in range(FC.shape[0]):
                        for j in range(FC.shape[1]):
                            if FC[i][j] < -0.5:
                               FC_matrix[i][j] = -0.5
                            if FC[i][j] > 1:
                               FC_matrix[i][j] = 1

                    f, ax = plt.subplots(1, 1, figsize=(50, 50))
                    ax.set_title(file_name_no_period+' FC (linear scale)')
                    im= ax.imshow(FC_matrix, cmap="jet")
                    f.colorbar(im, ax=ax)
                    
                    plt.tight_layout()
                    saveNm=subj + '/QC/SC_FC/' +subjName + '_' + file_name_no_period + '_FC.png'
                    f.savefig(saveNm)


                    f, ax = plt.subplots(1, 1, figsize=(50, 30))
                    ax.set_xlabel('volume')
                    ax.set_ylabel('ROI')
                    ax.set_title(file_name_no_period+' ROI timeseries carpet plot')
                    im= ax.imshow(norm_ts.transpose(), cmap='gray', aspect = 'auto')

                    plt.tight_layout()
                    saveNm=subj + '/QC/SC_FC/' +subjName + '_' + file_name_no_period + '_carpet.png'
                    f.savefig(saveNm)



                    f, ax = plt.subplots(1, 1, figsize=(50, 30))
                    ax.set_title(file_name_no_period+' FC histogram (linear scale)')
                    
                    f = plt.hist(FC.ravel(), bins=100)
                    saveNm=subj + '/QC/SC_FC/' +subjName + '_' + file_name_no_period + '_FC_hist.png'
                    plt.savefig(saveNm)


                except:
                    print("ERROR: can't generate graph for "+file)

        # else:
        #     try:

        #         FC_0_matrix=copy.deepcopy(FC_0)
        #         for i in range(FC_0.shape[0]):
        #             for j in range(FC_0.shape[1]):
        #                 if FC_0[i][j] < -0.5:
        #                    FC_0_matrix[i][j] = -0.5
        #                 if FC_0[i][j] > 1:
        #                    FC_0_matrix[i][j] = 1


        #         f, ax = plt.subplots(1, 1, figsize=(50, 50))
        #         ax.set_title('FC_0 (linear scale)')
        #         im= ax.imshow(FC_0_matrix, cmap="jet")
        #         f.colorbar(im, ax=ax)
                
        #         plt.tight_layout()
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_0.png'
        #         f.savefig(saveNm)


        #         f, ax = plt.subplots(1, 1, figsize=(50, 30))
        #         ax.set_xlabel('volume')
        #         ax.set_ylabel('ROI')
        #         ax.set_title('ROI timeseries carpet plot 0')
        #         im= ax.imshow(norm_ts_0.transpose(), cmap='gray', aspect = 'auto')
        #         ax.yaxis.set_label_position("right")
        #         ax.yaxis.tick_right()

        #         plt.tight_layout()
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_carpet_0.png'
        #         f.savefig(saveNm)

        #         f, ax = plt.subplots(1, 1, figsize=(50, 30))
        #         ax.set_title('FC_0 histogram (linear scale)')
                
        #         f = plt.hist(FC_0.ravel(), bins=100)
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_0_hist.png'
        #         plt.savefig(saveNm)

        #     except:
        #         print("ERROR: can't generate graph")


        #     try:
        #         FC_1_matrix=copy.deepcopy(FC_1)
        #         for i in range(FC_1.shape[0]):
        #             for j in range(FC_1.shape[1]):
        #                 if FC_1[i][j] < -0.5:
        #                    FC_1_matrix[i][j] = -0.5
        #                 if FC_1[i][j] > 1:
        #                    FC_1_matrix[i][j] = 1


        #         f, ax = plt.subplots(1, 1, figsize=(50, 50))
        #         ax.set_title('FC_1 (linear scale)')
        #         im= ax.imshow(FC_1_matrix, cmap="jet")
        #         f.colorbar(im, ax=ax)

        #         plt.tight_layout()
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_1.png'
        #         f.savefig(saveNm)
                

        #         f, ax = plt.subplots(1, 1, figsize=(50, 30))
        #         ax.set_xlabel('volume')
        #         ax.set_ylabel('ROI')
        #         ax.set_title('ROI timeseries carpet plot 1')
        #         im= ax.imshow(norm_ts_1.transpose(), cmap='gray', aspect = 'auto')

        #         ax.yaxis.set_label_position("right")
        #         ax.yaxis.tick_right()

        #         plt.tight_layout()
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_carpet_1.png'
        #         f.savefig(saveNm)

        #         f, ax = plt.subplots(1, 1, figsize=(50, 30))
        #         ax.set_title('FC_1 histogram (linear scale)')
                
        #         f = plt.hist(FC_1.ravel(), bins=100)
        #         saveNm=subj + '/QC/SC_FC/' +subjName + '_FC_1_hist.png'
        #         plt.savefig(saveNm)
        #     except:
        #         print("ERROR: can't generate graph")


        #if os.path.isfile(subj + '/fMRI/rfMRI.ica/fc.txt'):
        #    try:
        #        FC=np.loadtxt(subj + '/fMRI/rfMRI.ica/fc.txt')   
        #        norm_ts=zscore(np.loadtxt(subj + '/fMRI/rfMRI.ica/ts.txt'))
        #        #norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

        #    except:
        #        print("ERROR: ts file not found")

        #    f, ax = plt.subplots(1, 1, figsize=(50, 50))
        

        # else:     
        #     try:
        #         FC_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/fc.txt')   
        #         norm_ts_0=zscore(np.loadtxt(subj + '/fMRI/rfMRI_0.ica/ts.txt'))
        #         #norm_ts_0=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

        #     except:
        #         print("ERROR: rFMRI_0 ts file not found")
                

        #     try:
        #         FC_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/fc.txt')   
        #         norm_ts_1=zscore(np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt'))
        #         #norm_ts_1=np.loadtxt(subj + '/fMRI/rfMRI_1.ica/ts.txt');

        #     except:
        #         print("ERROR: rFMRI_1 ts file not found")


            
        try:    
            #division by 0 occurs in np.log10(SC) if 0 values aren't turned into small values
            #for i in range(SC.shape[0]):
            #    for j in range(SC.shape[1]):
            #        if SC[i][j] == 0:
            #           SC[i][j] = 10**-10
           
            
    
            f, ax = plt.subplots(1, 1, figsize=(50, 50))
            ax.set_title('SC (log scale)')
            ax.set_facecolor('#000000')
            SC_log = np.log10(SC)
            SC_log_matrix=copy.deepcopy(SC_log)
            for i in range(SC_log.shape[0]):
                for j in range(SC_log.shape[1]):
                    if SC_log[i][j] < -6:
                       SC_log_matrix[i][j] = -6
                    if SC_log[i][j] > 0:
                       SC_log_matrix[i][j] = 0

            im= ax.imshow(SC_log_matrix, cmap="CMRmap")
            f.colorbar(im, ax=ax)
            
            plt.tight_layout()
            saveNm=subj + '/QC/SC_FC/' +subjName + '_SC.png'
            f.savefig(saveNm)



            f, ax = plt.subplots(1, 1, figsize=(50, 30))
            ax.set_title('SC histogram (log scale, -inf removed)')
            SC_log = SC_log[SC_log > float("-inf")]
            f = plt.hist(SC_log.ravel(), bins=100)

            saveNm=subj + '/QC/SC_FC/' +subjName + '_SC_hist.png'
            plt.savefig(saveNm)


        except: 
            print("ERROR: Can't create SC graph")
        try:
            
            
            
            tract_lengths_log=np.log10(tract_lengths)
            tract_lengths_log_matrix=copy.deepcopy(tract_lengths_log)
            for i in range(tract_lengths_log.shape[0]):
                for j in range(tract_lengths_log.shape[1]):
                    if tract_lengths_log[i][j] < 0:
                       tract_lengths_log_matrix[i][j] = 0
                    if tract_lengths_log[i][j] > 2.5:
                       tract_lengths_log_matrix[i][j] = 2.5


            f, ax = plt.subplots(1, 1, figsize=(50, 50))
            ax.set_title('tract length (log scale)')
            ax.set_facecolor('#000000')
            im= ax.imshow(tract_lengths_log_matrix, cmap="CMRmap")
            f.colorbar(im, ax=ax)
            
            plt.tight_layout()
            saveNm=subj + '/QC/SC_FC/' +subjName + '_TL.png'
            f.savefig(saveNm)



            f, ax = plt.subplots(1, 1, figsize=(50, 30))
            ax.set_title('tract length histogram (linear scale, zeroes removed)')
            
            tract_lengths=tract_lengths[tract_lengths!=0]
            f = plt.hist(tract_lengths.ravel(), bins=100)
            saveNm=subj + '/QC/SC_FC/' +subjName + '_TL_hist.png'
            plt.savefig(saveNm)

        except:
            print("ERROR: Can't create TL graph")

        
        
        



if __name__ == "__main__":
    #try:
    SC_FC_png(sys.argv[1])
    #except:
        #print("ERROR. Usage: python SC_FC_png.py subj_list \nsubj_list: a .txt file of subject directories with the full path specified\nADNI_or_CAMCAN: 0 for ADNI populations, 1 for CAMCAN populations")
        
    #TODO more error handling here and in function def to deal with invalid files and paths