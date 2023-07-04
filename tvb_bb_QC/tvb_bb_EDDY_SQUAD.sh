#!/bin/bash
#
# Script name: tvb_bb_EDDY_SQUAD.sh
#
# Description: Script to generate EDDY QUAD for subjects in folder
#
## Author: Justin Wang


. $BB_BIN_DIR/bb_pipeline_tools/bb_set_header

set -x

origDir=`pwd`

dirScript=`dirname $0`


#export FSLDIR=/opt/HCPpipelines-4.1.3/fsl


### EDDY SQUAD ###
	echo ""
	echo "STARTING EDDY SQUAD -------"

	#EDDY SQUAD
	
		#EDDY_SQUAD_output_folder_base=$origDir/EDDY_SQUAD
		EDDY_SQUAD_output_folder=$origDir/EDDY_SQUAD
		#i=0

		#while [ -d $EDDY_SQUAD_output_folder ]
		#do
			#EDDY_SQUAD_output_folder=$EDDY_SQUAD_output_folder_base$i
			#((i+=1))
		#done
		rm -rf $EDDY_SQUAD_output_folder
		
		
		${FSLDIR}/bin/eddy_squad -o $EDDY_SQUAD_output_folder $origDir/eddy_quad_list.txt


. $BB_BIN_DIR/bb_pipeline_tools/bb_set_footer
