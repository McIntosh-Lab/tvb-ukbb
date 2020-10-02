#!/bin/bash
# Script to report which MCR you need to install
MCR_URL="https://www.mathworks.com/products/compiler/matlab-runtime.html"

here=$( cd $(dirname $0) ; pwd)
. "${here}/settings.sh"
mcr_file="${FSL_FIXDIR}/compiled/${FSL_FIX_OS}/${FSL_FIX_ARCH}/MCR.version"
if [ -f "${mcr_file}" ]; then
    mcr=$(cat "${mcr_file}")
    echo "Download MATLAB Compiler Runtime ${mcr} from ${MCR_URL}."
else
    echo "Can't find MATLAB compiled software for this OS"
fi