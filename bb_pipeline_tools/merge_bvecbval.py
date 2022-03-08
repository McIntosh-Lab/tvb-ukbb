#!/bin/env python
# Script name: merge_bvecbval.py
#
# Description: Concatenate bval and bvec values into respective files.
#
import numpy as np

bval1000 = np.loadtxt('1000.bval') 
bval2000 = np.loadtxt('2000.bval') 

bvec1000 = np.loadtxt('1000.bvec') 
bvec2000 = np.loadtxt('2000.bvec') 

bval = np.concatenate((bval1000, bval2000))
bval = bval[:,np.newaxis]
bval = bval.T
np.savetxt('bval',bval,fmt='%i')

bvec = np.concatenate((bvec1000, bvec2000), axis=1)
np.savetxt('bvec',bvec,fmt='%0.6f')

