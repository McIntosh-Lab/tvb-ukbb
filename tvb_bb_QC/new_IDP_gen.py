#!/bin/env python
#
# Script name: new_IDP_gen.py
#
# Description: Script to generate new IDPs for a subject.
#
## Author: Justin Wang

import numpy as np
import sys
from scipy.stats import zscore
import matplotlib.pyplot as plt
import matplotlib
import os
import copy
import glob
import scipy
from numpy import inf
import scipy.stats
# increasing font size for plots
font = {"size": 100}
matplotlib.rc("font", **font)

IDP_num_counter = 1

def FC_distribution(subj):

    #import data and generate graphs for fMRI
    #for each ica folder in fMRI
    try:
        num_in_cat=1
        for file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".ica"):

                #import FC and TS data
                fc_path = os.path.join(subj + "/fMRI/", file, "fc.txt")
                ts_path = os.path.join(subj + "/fMRI/", file, "ts.txt")

                FC = ""
                norm_ts = ""

                try:
                    FC = np.loadtxt(fc_path)
                    norm_ts = zscore(np.loadtxt(ts_path))
                    # norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

                except:
                    print("ERROR: fc, ts file not found")


                #get this in the for loop
                FC_min=np.amin(FC)
                FC_max=np.amax(FC)
                FC_median=np.median(FC)
                FC_mean=np.mean(FC)
                FC_mean_to_max=FC_max-FC_mean
                FC_median_to_max=FC_max-FC_median
                FC_range=np.ptp(FC)
                FC_proportion_neg=np.count_nonzero(FC<0)/(FC.shape[0] * FC.shape[1])

                #https://stackoverflow.com/questions/6620471/fitting-empirical-distribution-to-theoretical-ones-with-scipy-python

                print("---------")
                print("FC")
                print(file)
                print("---------")
                print(FC_min)
                print(FC_max)
                print(FC_median)
                print(FC_mean)
                print(FC_mean_to_max)
                print(FC_median_to_max)
                print(FC_range)
                print(FC_proportion_neg)

                write_to_IDP_file(subj, "FC_distribution_min_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_min_"+file, "pearson correlation coefficient", "float", "Functional connectivity minimum for "+file, str(FC_min))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_max_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_max_"+file, "pearson correlation coefficient", "float", "Functional connectivity maximum for "+file, str(FC_max))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_median_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_median_"+file, "pearson correlation coefficient", "float", "Functional connectivity median for "+file, str(FC_median))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_mean_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_mean_"+file, "pearson correlation coefficient", "float", "Functional connectivity mean for "+file, str(FC_mean))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_mean_to_max_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_mean_to_max_"+file, "pearson correlation coefficient", "float", "Functional connectivity distance from mean to max for "+file, str(FC_mean_to_max))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_median_to_max_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_median_to_max_"+file, "pearson correlation coefficient", "float", "Functional connectivity distance from median to max for "+file, str(FC_median_to_max))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_range_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_range_"+file, "pearson correlation coefficient", "float", "Functional connectivity range for "+file, str(FC_range))
                num_in_cat+=1
                write_to_IDP_file(subj, "FC_distribution_proportion_neg_"+file, "tvb_IDP_FC_distribution", str(num_in_cat), "FC_distribution_proportion_neg_"+file, "proportion out of 1", "float", "Functional connectivity proportion negative for "+file, str(FC_proportion_neg))
                num_in_cat+=1



                FC = FC.flatten()

                y, x = np.histogram(FC[~np.isnan(FC)], bins=100)
                for index, value in enumerate(x[0:-1]):
                    x[index] = (value + x[index + 1]) / 2 
                x=x[0:-1]
                
                total=np.sum(y)

                dist_names = [
            "norm"
            ]
                print(y)
                print(x)
                #h = plt.hist(y, bins=range(100))
                for dist_name in dist_names:
                    dist = getattr(scipy.stats, dist_name)
                    params = dist.fit(FC[~np.isnan(FC)])
                    pdf_fitted = dist.pdf(x, *params) #* total

                    
                    y=y - np.min(y)

                    y=y / np.max(y)

                    
                    pdf_fitted=pdf_fitted - np.min(pdf_fitted)
                    pdf_fitted=pdf_fitted / np.max(pdf_fitted)
                    print(pdf_fitted)

                    squared_error = mean_squared_error(pdf_fitted,y)
                    print("------")
                    print("SC_dist")

                    print("dist: "+dist_name)
                    print("squared error: "+str(squared_error))
                    #plt.plot(pdf_fitted, label=dist_name)    
                #plt.show()
                    write_to_IDP_file(subj, "FC_"+dist_name+"_MSE", "tvb_IDP_FC_distribution", str(num_in_cat), "FC_"+dist_name+"_Mean_Squared_Error", "pearon correlation coefficient 2", "float", "Functional connectivity - mean squared error for "+dist_name+" distribution fit", str(squared_error))
                    num_in_cat+=1

    except:
        print("ERROR: no fMRI folder in subject directory")




def SC_distribution(subj):

    
    #import SC data
    SC = ""
    SC_path=subj + "/dMRI/sc.txt"
    try:
        SC = np.loadtxt(SC_path)
    except:
        print("ERROR: sc file not found")

    
    nanlines=""
    with open(SC_path) as f:
        lines = f.read().splitlines()
        counter1=1
        counter=0
        for x in lines:

            x = x.split()

            nan_row=True
            for y in x:
                if y != "nan":
                    nan_row=False
            if nan_row == True:
                counter +=1
                nanlines = nanlines + str(counter1) + ", "
            counter1 +=1

    #SC is log scale now
    SC = np.log10(SC)


    SC_num_nan=counter
    SC_nan_lines=nanlines[:-2]


    SC[SC == -inf] = "nan"
    SC[SC == inf] = "nan"


    SC_min=np.nanmin(SC) 
    SC_max=np.nanmax(SC) 
    SC_median=np.nanmedian(SC) 
    SC_mean=np.nanmean(SC) 
    SC_mean_to_max=SC_max-SC_mean 
    SC_median_to_max=SC_max-SC_median 
    SC_range=SC_max-SC_min 
    SC_proportion_neg=np.count_nonzero(SC<0)/(SC.shape[0] * SC.shape[1]) 


    #https://stackoverflow.com/questions/6620471/fitting-empirical-distribution-to-theoretical-ones-with-scipy-python
    #https://github.com/cokelaer/fitter/blob/master/src/fitter/fitter.py#L264

    #TO DO: distribution analysis WITH TL AND TS^^^ 

    print("---------")
    print("SC")
    print("---------")
    print(SC_min)
    print(SC_max)
    print(SC_median)
    print(SC_mean)
    print(SC_mean_to_max)
    print(SC_median_to_max)
    print(SC_range)
    print(SC_proportion_neg)
    print(SC_num_nan)
    print(SC_nan_lines)

    num_in_cat=1
    write_to_IDP_file(subj, "SC_distribution_min", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_min", "pearson correlation coefficient (log 10)", "float", "Structural connectivity minimum", str(SC_min))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_max", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_max", "pearson correlation coefficient (log 10)", "float", "Structural connectivity maximum", str(SC_max))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_median", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_median", "pearson correlation coefficient (log 10)", "float", "Structural connectivity median", str(SC_median))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_mean", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_mean", "pearson correlation coefficient (log 10)", "float", "Structural connectivity mean", str(SC_mean))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_mean_to_max", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_mean_to_max", "pearson correlation coefficient (log 10)", "float", "Structural connectivity distance from mean to max", str(SC_mean_to_max))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_median_to_max", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_median_to_max", "pearson correlation coefficient (log 10)", "float", "Structural connectivity distance from median to max", str(SC_median_to_max))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_range", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_range", "pearson correlation coefficient (log 10)", "float", "Structural connectivity range", str(SC_range))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_distribution_proportion_neg", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_distribution_proportion_neg", "proportion out of 1", "float", "Structural connectivity proportion negative", str(SC_proportion_neg))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_nan_lines", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_nan_lines", "proportion out of 1", "float", "Structural connectivity - line numbers of rows with all NaNs", str(SC_nan_lines))
    num_in_cat+=1
    write_to_IDP_file(subj, "SC_num_nan", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_number_of_nan_lines", "proportion out of 1", "float", "Structural connectivity - number of all NaN rows", str(SC_num_nan))
    num_in_cat+=1


    SC = SC.flatten()

    y, x = np.histogram(SC[~np.isnan(SC)], bins=100)
    for index, value in enumerate(x[0:-1]):
        x[index] = (value + x[index + 1]) / 2 
    x=x[0:-1]
    
    total=np.sum(y)

    dist_names = [
"lognorm"
]
    print(y)
    print(x)
    #h = plt.hist(y, bins=range(100))
    for dist_name in dist_names:
        dist = getattr(scipy.stats, dist_name)
        params = dist.fit(SC[~np.isnan(SC)])
        pdf_fitted = dist.pdf(x, *params) #* total

        
        y=y - np.min(y)

        y=y / np.max(y)

        
        pdf_fitted=pdf_fitted - np.min(pdf_fitted)
        pdf_fitted=pdf_fitted / np.max(pdf_fitted)
        print(pdf_fitted)

        squared_error = mean_squared_error(pdf_fitted,y)
        print("------")
        print("SC_dist")

        print("dist: "+dist_name)
        print("squared error: "+str(squared_error))
        #plt.plot(pdf_fitted, label=dist_name)    
    #plt.show()
        write_to_IDP_file(subj, "SC_"+dist_name+"_MSE", "tvb_IDP_SC_distribution", str(num_in_cat), "SC_"+dist_name+"_Mean_Squared_Error", "pearon correlation coefficient 2 (log 10)", "float", "Structural connectivity - mean squared error for "+dist_name+" distribution fit", str(squared_error))
        num_in_cat+=1


def mean_squared_error(y,y_fit):
     squared_error = np.sum(np.square(np.subtract(y,y_fit)))
     mean_squared_error = squared_error/y.size
     return mean_squared_error

def MELODIC_SNR(subj,fix4melviewtxt):

    #import data and generate graphs for fMRI
    #for each ica folder in fMRI
    try:
        num_in_cat=1
        for file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".ica"):

                #TODO: might have to replace this with string + concat if the asterisk doesnt work properly in os path join
                fixmelview_path = os.path.join(subj + "/fMRI/", file, "fix4melview_*.txt")
                
                
                #TODO: allow entry of fix4melview file

                if fix4melviewtxt == "":
                    fix4melview_list = glob.glob(fixmelview_path)
                else:
                    fix4melview_list = fix4melviewtxt
                    counter=0

                    while counter < len(fix4melview_list):
                        fix4melview_list[counter] = os.path.join(subj + "/fMRI/", file, fix4melview_list[counter])
                        counter+=1


                try:

                    for name in fix4melview_list:
                        with open(name) as f:
                            lines = f.read().splitlines()
                            num_noise=len(str(lines[-1]).split(','))
                            num_IC=lines[-2].split(',')[0]
                            
                            num_unknown=0

                            IC_lines=lines[1:-1]
                            for IC in IC_lines:
                                if IC.split(',')[1].strip() == "Unknown":
                                    num_unknown= num_unknown+1

                            num_IC=int(num_IC)
                            num_noise=int(num_noise)
                            num_unknown=int(num_unknown)

                            num_signal=num_IC-num_noise-num_unknown

                            

                            p_unknown=num_unknown/num_IC
                            p_signal=num_signal/num_IC
                            p_noise=num_noise/num_IC


                            print("---------")
                            print("MELODIC SNR")
                            print(file)
                            print(name)
                            print("---------")
                            print (p_unknown)
                            print (p_signal)
                            print (p_noise)

                            write_to_IDP_file(subj, "MELODIC_SNR_prop_IC_unknown_"+str(os.path.basename(name))+"_"+file, "tvb_IDP_MELODIC_SNR", str(num_in_cat), "MELODIC_SNR_proportion_IC_unknown_"+str(os.path.basename(name))+"_"+file, "proportion out of 1", "float", "MELODIC signal to noise ratio - proportion of ICs that are unknown in "+str(os.path.basename(name))+" for "+file, str(p_unknown))
                            num_in_cat+=1
                            write_to_IDP_file(subj, "MELODIC_SNR_prop_IC_signal_"+str(os.path.basename(name))+"_"+file, "tvb_IDP_MELODIC_SNR", str(num_in_cat), "MELODIC_SNR_proportion_IC_signal_"+str(os.path.basename(name))+"_"+file, "proportion out of 1", "float", "MELODIC signal to noise ratio - proportion of ICs that are signal in "+str(os.path.basename(name))+" for "+file, str(p_signal))
                            num_in_cat+=1
                            write_to_IDP_file(subj, "MELODIC_SNR_prop_IC_noise_"+str(os.path.basename(name))+"_"+file, "tvb_IDP_MELODIC_SNR", str(num_in_cat), "MELODIC_SNR_proportion_IC_noise_"+str(os.path.basename(name))+"_"+file, "proportion out of 1", "float", "MELODIC signal to noise ratio - proportion of ICs that are noise in "+str(os.path.basename(name))+" for "+file, str(p_noise))
                            num_in_cat+=1


                except:
                    print("ERROR: fixmel4view_path file not found")

    except:
        print("ERROR: no fMRI folder in subject directory")


def MCFLIRT_displacement(subj):
    try:
        num_in_cat=1
        for file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".ica") or file.endswith(".feat"):
                rel_displacement_file = os.path.join(subj + "/fMRI/", file, "mc", "prefiltered_func_data_mcf_rel.rms")
                abs_displacement_file = os.path.join(subj + "/fMRI/", file, "mc", "prefiltered_func_data_mcf_abs.rms")

                #TODO: deal with nans

                try:
                    rel_displacement = np.loadtxt(rel_displacement_file)
                    abs_displacement = np.loadtxt(abs_displacement_file)

                    rel_displacement_min=np.amin(rel_displacement)
                    rel_displacement_max=np.amax(rel_displacement)
                    rel_displacement_median=np.median(rel_displacement)
                    rel_displacement_mean=np.mean(rel_displacement)
                    rel_displacement_range=np.ptp(rel_displacement)
                    rel_displacement_proportion_gt_one=np.count_nonzero(rel_displacement>1)/(rel_displacement.shape[0])
                    rel_displacement_num_gt_one=np.count_nonzero(rel_displacement>1)


                    abs_displacement_min=np.amin(abs_displacement)
                    abs_displacement_max=np.amax(abs_displacement)
                    abs_displacement_median=np.median(abs_displacement)
                    abs_displacement_mean=np.mean(abs_displacement)
                    abs_displacement_range=np.ptp(abs_displacement)
                    abs_displacement_proportion_gt_one=np.count_nonzero(abs_displacement>1)/(abs_displacement.shape[0])
                    abs_displacement_num_gt_one=np.count_nonzero(abs_displacement>1)


                    print("---------")
                    print("MCFLIRT")
                    print(file)
                    print("---------")
                    print (rel_displacement_min)
                    print (rel_displacement_max)
                    print (rel_displacement_median)
                    print (rel_displacement_mean)
                    print (rel_displacement_range)
                    print (rel_displacement_proportion_gt_one)
                    print (rel_displacement_num_gt_one)
                    print (abs_displacement_min)
                    print (abs_displacement_max)
                    print (abs_displacement_median)
                    print (abs_displacement_mean)
                    print (abs_displacement_range)
                    print (abs_displacement_proportion_gt_one)
                    print (abs_displacement_num_gt_one)


                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_min_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_minimum_"+file, "mm", "float", "MCFLIRT relative displacement minimum for "+file, str(rel_displacement_min))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_max_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_maximum_"+file, "mm", "float", "MCFLIRT relative displacement maximum for "+file, str(rel_displacement_max))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_median_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_median_"+file, "mm", "float", "MCFLIRT relative displacement median for "+file, str(rel_displacement_median))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_mean_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_mean_"+file, "mm", "float", "MCFLIRT relative displacement mean for "+file, str(rel_displacement_mean))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_range_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_range_"+file, "mm", "float", "MCFLIRT relative displacement range for "+file, str(rel_displacement_range))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_proportion_gt_one_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_proportion_greaterthan_one_"+file, "proportion out of 1", "float", "MCFLIRT relative displacement - proportion of time units with displacement greater than 1mm for "+file, str(rel_displacement_proportion_gt_one))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_rel_disp_num_gt_one_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_relative_displacement_number_greaterthan_one_"+file, "time (seconds?)", "float", "MCFLIRT relative displacement - number of time units with displacement greater than 1mm for "+file, str(rel_displacement_num_gt_one))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_min_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_minimum_"+file, "mm", "float", "MCFLIRT absolute displacement minimum for "+file, str(abs_displacement_min))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_max_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_maximum_"+file, "mm", "float", "MCFLIRT absolute displacement maximum for "+file, str(abs_displacement_max))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_median_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_median_"+file, "mm", "float", "MCFLIRT absolute displacement median for "+file, str(abs_displacement_median))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_mean_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_mean_"+file, "mm", "float", "MCFLIRT absolute displacement mean for "+file, str(abs_displacement_mean))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_range_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_range_"+file, "mm", "float", "MCFLIRT absolute displacement range for "+file, str(abs_displacement_range))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_proportion_gt_one_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_proportion_greaterthan_one_"+file, "proportion out of 1", "float", "MCFLIRT absolute displacement - proportion of time units with displacement greater than 1mm for "+file, str(abs_displacement_proportion_gt_one))
                    num_in_cat+=1
                    write_to_IDP_file(subj, "MCFLIRT_abs_disp_num_gt_one_"+file, "tvb_IDP_MCFLIRT_disp", str(num_in_cat), "MCFLIRT_absolute_displacement_number_greaterthan_one_"+file, "time (seconds?)", "float", "MCFLIRT absolute displacement - number of time units with displacement greater than 1mm for "+file, str(abs_displacement_num_gt_one))
                    num_in_cat+=1




                except:
                    print("ERROR: prefiltered_func_data_mcf file not found")
    except:
        print("ERROR: no fMRI folder in subject directory")



def homotopic(subj,LUT_txt):
    #get indices of homotopic pairs
    #get the fc value for each pair
    #get distribution of these fc values  


    #import SC data
    LUT = ""
    try:
        #LUT = np.loadtxt(LUT_txt)
        with open(LUT_txt) as f:
            LUT = f.read().splitlines()
    except:
        print("ERROR: LUT file not found")

    index_pair_list = []
    counter = 0
    while counter <  np.shape(LUT)[0]:
        LUT[counter][1]
        counter1 = counter + 1
        while counter1 < np.shape(LUT)[0]:
            if LUT[counter1][1].replace("lh","").replace("LH","").replace("rh","").replace("RH","") == LUT[counter][1].replace("lh","").replace("LH","").replace("rh","").replace("RH",""):
                
                index_pair_list.append((counter,counter1))
                #record counter1 and counter as a pair
                break
            else:                
                counter1 += 1 
        counter += 1




    try:
        num_in_cat=1
        for file in os.listdir(subj + "/fMRI/"):
            if file.endswith(".ica"):

                #import FC and TS data
                fc_path = os.path.join(subj + "/fMRI/", file, "fc.txt")
                ts_path = os.path.join(subj + "/fMRI/", file, "ts.txt")

                FC = ""
                norm_ts = ""

                try:
                    FC = np.loadtxt(fc_path)
                    norm_ts = zscore(np.loadtxt(ts_path))
                    # norm_ts=np.loadtxt(subj + '/fMRI/rfMRI_0.ica/norm_ts.txt');

                except:
                    print("ERROR: fc, ts file not found")

                homotopic_sum = 0
                for pair in index_pair_list:
                    homotopic_sum += FC[pair[0]][pair[1]]
                homotopic_mean = homotopic_sum/len(index_pair_list)


                print("---------")
                print("HOMOTOPIC")
                print(file)
                print("---------")
                print (homotopic_mean)
                
                write_to_IDP_file(subj, "FC_homotopic_mean_"+file, "tvb_IDP_homotopic", str(num_in_cat), "FC_homotopic_mean_"+file, "pearson correlation coefficient", "float", "Functional connectivity homotopic mean for "+file, str(homotopic_mean))
                num_in_cat +=1

    except:
        print("ERROR: no fMRI folder in subject directory")



def write_to_IDP_file(subj,short,category,num_in_cat,long_var,unit,dtype,description,value):
    
    global IDP_num_counter
    file = os.path.join(subj + "/IDP_files/", "tvb_new_IDPs.txt")


    with open(file, 'a') as fp:
        fp.write("\n")
        try:
            line = '\t'.join([str(IDP_num_counter),short,category,num_in_cat,long_var,unit,dtype,description,"{:e}".format(float(value))])
            fp.write(line)
        except:
            line = '\t'.join([str(IDP_num_counter),short,category,num_in_cat,long_var,unit,dtype,description,value])
            fp.write(line)
    IDP_num_counter += 1



def new_IDP_gen(subj,LUT_txt):      #,fix4melviewtxt
    """Function that generates new IDPs for a subject.

    TODO: more error handling here and in function def to deal with 
            invalid files and paths

    Parameters
    ----------
    subj : string
        Full path to subject's directory.
    """


    #remove trailing forward slashes in subject paths
    if subj.endswith("/"):
        subj = subj[:-1]

    if not os.path.exists(subj + "/IDP_files/"):
        os.makedirs(subj + "/IDP_files/")

    subjName = subj[subj.rfind("/") + 1 :]


    # IDP_FC_file = os.path.join(subj + "/IDP_files/", "tvb_IDP_FC_dist.txt")
    # IDP_SC_file = os.path.join(subj + "/IDP_files/", "tvb_IDP_SC_dist.txt")
    # IDP_MELODIC_file = os.path.join(subj + "/IDP_files/", "tvb_IDP_MELODIC_SNR.txt")
    # IDP_MCFLIRT_file = os.path.join(subj + "/IDP_files/", "tvb_IDP_MCFLIRT_disp.txt")
    # IDP_homotopic_file = os.path.join(subj + "/IDP_files/", "tvb_IDP_homotopic.txt")
    # new_IDP_list_file = os.path.join(subj + "/IDP_files/", "tvb_new_IDPs.txt")

    new_IDP_file = os.path.join(subj + "/IDP_files/", "tvb_new_IDPs.txt")


    # IDP_output_files = [IDP_FC_file,IDP_SC_file,IDP_MELODIC_file,IDP_MCFLIRT_file,IDP_homotopic_file]

    # for file in IDP_output_files:
    #     with open(file, 'w') as fp:
    #         pass

    with open(new_IDP_file, 'w') as fp:
        line = '\t'.join(["num","short","category","num_in_cat","long","unit","dtype","description","value"])

        fp.write(line)



    fix4melviewtxt=""

    FC_distribution(subj)
    SC_distribution(subj)
    MELODIC_SNR(subj,fix4melviewtxt)
    MCFLIRT_displacement(subj)       

    homotopic(subj,LUT_txt)
    




    #TODO TL/distance, or ts.txt





if __name__ == "__main__":
    """Function that generates new IDPs for a subject.

    
    Usage
    ----------
    python  new_IDP_gen.py  subj
    

    Arguments
    ----------
    subj : 
        Full path to subject's directory.

    LUT_txt :
        $PARC_LUT env variable
    
    fix4melviewtxt :
        List of fix4melview txt files

    """

    #TODO: use argparse https://stackoverflow.com/questions/32761999/how-to-pass-an-entire-list-as-command-line-argument-in-python/32763023
    # try:
    new_IDP_gen(sys.argv[1],sys.argv[2]) #,sys.argv[3])

    