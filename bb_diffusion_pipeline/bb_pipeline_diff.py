#!/bin/env python
#
# Script name: bb_pipeline_diff.py
#
# Description: Script with the dMRI pipeline.
# 			   This script will call the rest of dMRI functions.
#
# Authors: Fidel Alfaro-Almagro, Stephen M. Smith & Mark Jenkinson
#
# Copyright 2017 University of Oxford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import bb_pipeline_tools.bb_logging_tool as LT
import os.path


def bb_pipeline_diff(subject, jobHold, fileConfiguration):

    logger = LT.initLogging(__file__, subject)
    logDir = logger.logDir
    baseDir = logDir[0 : logDir.rfind("/logs/")]

    jobHold = str(jobHold)

    subname = subject.replace("/", "_")

    jobPREPARE = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 5   -N "bb_pre_eddy_'
        '${FSLDIR}/bin/fsl_sub -q all.q   -N "bb_pre_eddy_'
        + subname
        + '" -j '
        + jobHold
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_pre_eddy "
        + subject,
    )
    jobEDDY = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 75  -N "bb_eddy_'
        '${FSLDIR}/bin/fsl_sub -q bigmem_16.q  -R 8000 -N "bb_eddy_'
        + subname
        + '" -j '
        + jobPREPARE
        #+ "  -q $FSLGECUDAQ -l "
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_eddy_wrap "
        + baseDir,
    )
    jobPOSTEDDY = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 60  -N "bb_post_eddy_'
        '${FSLDIR}/bin/fsl_sub -q all.q  -N "bb_post_eddy_'
        + subname
        + '" -j '
        + jobEDDY
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_eddy/bb_post_eddy "
        + baseDir,
    )
    jobDTIFIT = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 5   -N "bb_dtifit_'
        '${FSLDIR}/bin/fsl_sub -q all.q   -N "bb_dtifit_'
        + subname
        + '" -j '
        + jobPOSTEDDY
        + "  -l "
        + logDir
        + " ${FSLDIR}/bin/dtifit -k "
        + baseDir
        + "/dMRI/dMRI/data_1_shell -m "
        + baseDir
        + "/dMRI/dMRI/nodif_brain_mask -r "
        + baseDir
        + "/dMRI/dMRI/data_1_shell.bvec -b "
        + baseDir
        + "/dMRI/dMRI/data_1_shell.bval -o "
        + baseDir
        + "/dMRI/dMRI/dti",
    )
    jobTBSS = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 240 -N "bb_tbss_'
        '${FSLDIR}/bin/fsl_sub -q all.q -N "bb_tbss_'
        + subname
        + '" -j '
        + jobDTIFIT
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_tbss/bb_tbss_general "
        + subject,
    )
    #jobNODDI = LT.runCommand(
        #logger,
        ##'${FSLDIR}/bin/fsl_sub -T 100 -N "bb_NODDI_'
        #'${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_NODDI_'
        #+ subname
        #+ '" -j '
        #+ jobTBSS
        #+ "  -l "
        #+ logDir
        #+ " $BB_BIN_DIR/bb_diffusion_pipeline/bb_NODDI "
        #+ subject,
    #)
    jobPREBEDPOSTX = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 5   -N "bb_pre_bedpostx_gpu_'
        '${FSLDIR}/bin/fsl_sub -q all.q   -N "bb_pre_bedpostx_gpu_'
        + subname
        + '" -j '
        + jobDTIFIT
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_pre_bedpostx_gpu "
        + baseDir
        + "/dMRI",
    )
    jobBEDPOSTX = LT.runCommand(
        logger,
        #'${FSLDIR}/bin/fsl_sub -T 190 -N "bb_bedpostx_gpu_'
        '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -N "bb_bedpostx_gpu_'
        + subname
        + '" -j '
        + jobPREBEDPOSTX
        #+ "  -q $FSLGECUDAQ -l "
        + "  -l "
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_bedpostx_gpu "
        + baseDir
        + "/dMRI",
    )
    ##### bb_post_bedpostx_gpu not necessary if using bedpostx package rather than xfibres (gpu) #####
    #jobPOSTBEDPOSTX = LT.runCommand(
        #logger,
        ##'${FSLDIR}/bin/fsl_sub -T 15  -N "bb_post_bedpostx_gpu_'
        #'${FSLDIR}/bin/fsl_sub -q bigmem_16.q  -N "bb_post_bedpostx_gpu_'
        #+ subname
        #+ '" -j '
        #+ jobBEDPOSTX
        #+ "  -l "
        #+ logDir
        #+ " $BB_BIN_DIR/bb_diffusion_pipeline/bb_bedpostx/bb_post_bedpostx_gpu "
        #+ baseDir
        #+ "/dMRI/dMRI",
    #)
    #### running our own tractography algorithms so turning AutoPtx option off
    #jobAUTOPTX = LT.runCommand(
        #logger,
        #"$BB_BIN_DIR/bb_diffusion_pipeline/bb_autoPtx/bb_autoPtx "
        #+ subname
        #+ " "
        #+ jobPOSTBEDPOSTX
        #+ ","
        #+ jobTBSS,
    #)   
    jobPREPROBTRACKX = LT.runCommand(
        logger,
        '${FSLDIR}/bin/fsl_sub -q all.q -N "bb_pre_probtrackx_'
        + subname
        + '" -j '
        + jobBEDPOSTX
        + ' -l '
        + logDir
        + " $BB_BIN_DIR/bb_diffusion_pipeline/bb_probtrackx2/bb_pre_probtrackx2 "
        + baseDir,
    )
    jobPROBTRACKX = LT.runCommand(
        logger,
        '${FSLDIR}/bin/fsl_sub -q bigmem_16.q -R 8000 -N "bb_probtrackx_'
        + subname
        + '" -j '
        + jobPREPROBTRACKX
        + " -l "
        + logDir
        +" $BB_BIN_DIR/bb_diffusion_pipeline/bb_probtrackx2/bb_probtrackx2 "
        + baseDir
        + "/dMRI",
    )
    print("FINISH DIFFUSION")
    return jobPROBTRACKX

