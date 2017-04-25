# Settings file for SWI
# Modify these settings based on your system setup
SWIVERSION=1.00

# Get the OS and CPU type
FSL_SWI_OS=`uname -s`
FSL_SWI_ARCH=`uname -m`

if [ -z "${FSL_SWIDIR}" ]; then
	FSL_SWIDIR=$( cd $(dirname $0) ; pwd)
	export FSL_SWIDIR
fi

# edit the following variables according to your local setup

# Part I MATLAB settings
# =======================
# Point this variable at your MATLAB install folder
if [ -z "${FSL_SWI_MATLAB_ROOT}" ]; then
       FSL_SWI_MATLAB_ROOT=/opt/fmrib/MATLAB/R2016a
       # On OS X this will most likely be something like /Applications/MATLAB_R20XX.app
fi
# On OS X this will most likely be something like /Applications/MATLAB_R20XX.app

# Point this variable at your MATLAB command - this is usually in
# $FSL_SWI_MATLAB_ROOT/bin/matlab
FSL_SWI_MATLAB=${FSL_SWI_MATLAB_ROOT}/bin/matlab

# Point this variable at your MATLAB compiler command - this is
# usually $FSL_SWI_MATLAB_ROOT/bin/mcc
FSL_SWI_MCC=${FSL_SWI_MATLAB_ROOT}/bin/mcc

# Point this variable at an installed MATLAB compiler runtime. This
# MUST be the same as the version given in the file MCR.version
# (which is populated when the software is compiled).
FSL_SWI_MCRROOT=/opt/fmrib/MATLAB/MATLAB_Compiler_Runtime

if [ -f ${FSL_SWIDIR}/MCR.version ]; then
	FSL_SWI_MCRV=`cat ${FSL_SWIDIR}/MCR.version`
fi

if [ ! -z "${FSL_SWI_MCRV}" ]; then
	FSL_SWI_MCR=${FSL_SWI_MCRROOT}/${FSL_SWI_MCRV}
fi

# This is name of the folder containing the compiled MATLAB functions
FSL_SWI_MLCDIR=${FSL_SWIDIR}/compiled/${FSL_SWI_OS}/${FSL_SWI_ARCH}

# See README for instructions on compilation of the MATLAB portions

# Set this to the MATLAB start-up options. Typically you will
# want to disable Java, display output, the desktop environment
# and the splash screen
FSL_SWI_MLOPTS="-nodisplay -nodesktop -nosplash"

# Set this to the MATLAB 'evaluate string' option
FSL_SWI_MLEVAL="-r"
# Set this to the pass in file option
FSL_SWI_MLFILE="\<"

# Part II Octave settings
# =======================
# Point this variable at your Octave command (or leave it blank to
# disable Octave mode
# Linux:
FSL_SWI_OCTAVE=/usr/bin/octave
# Mac OS X installed via MacPorts
#FSL_SWI_OCTAVE=/opt/local/bin/octave
# Disable Octave mode
#FSL_SWI_OCTAVE=

# Set this to the Octave start-up options. Typically you will need to
# enable 'MATLAB' mode (--traditional) and disable display output
FSL_SWI_OCOPTS="--traditional -q --no-window-system"

# Set this to the Octave 'evaluate string' option
FSL_SWI_OCEVAL="--eval"
# Set this to the pass in file option
FSL_SWI_OCFILE=""

# Part III General settings
# =========================
# This variable selects how we run the MATLAB portions of SWI.
# It takes the values 0-2:
#   0 - Try running the compiled version of the function
#   1 - Use the MATLAB script version
#   2 - Use Octave script version
FSL_SWI_MATLAB_MODE=0

FSL_SWI_CIFTIRW="$BB_BIN_DIR/bb_ext_tools/workbench/CIFTIMatlabReaderWriter";
# Set this to the location of the HCP Workbench command for your platform
FSL_SWI_WBC="$BB_BIN_DIR/bb_ext_tools/workbench//bin_linux64/wb_command";

export FSL_SWI_CIFTIRW FSL_SWI_WBC

# Set this to the location of the FSL MATLAB scripts
if [ -z "${FSLDIR}" ]; then
	echo "FSLDIR is not set!"
	exit 1
fi
FSL_SWI_FSLMATLAB=${FSLDIR}/etc/matlab

#############################################################
