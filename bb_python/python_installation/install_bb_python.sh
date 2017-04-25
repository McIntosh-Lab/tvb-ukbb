#!/usr/bin/env bash
#
# Script name: install_bb_python.sh
#
# Description: Script to install python (Version of Python can be selected)
#
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
set -x
set -e

origDir=`pwd`

#Python version to install and name of the
#runnable python binary in the bin directory

#py_v="2.7.12"
#py_r="python"
py_v="3.5.1"
py_r="python3"

#Get, configure and install the proper Python version
wget https://www.python.org/ftp/python/$py_v/Python-$py_v.tgz
tar -xvzf Python-$py_v.tgz
cd Python-$py_v
./configure --prefix=`pwd`/../../bb_python$py_v
make
make install

cd ../../bb_python$py_v/bin
export PATH=`pwd`:$PATH

#Get and install pip (through get-pip and virtualenv)
git clone https://github.com/pypa/get-pip
./$py_r get-pip/get-pip.py
./$py_r pip install virtualenv

#Create and activate a virtual environment 
./$py_r virtualenv `pwd`/../../bb_python
. ../../bb_python/bin/activate

#Install the needed libraries
pip install --upgrade pip
pip install numpy==1.11.1
pip install nibabel==2.1.0
pip install pydicom==0.9.9
pip install scipy==0.18.0
pip install pandas==0.18.1
pip install scikit-learn==0.17.1
pip install ipython==5.1.0
pip install matplotlib==1.5.2
pip install nose==1.3.7
pip install sphinx==1.4.6


#Get and install gradunwarp from HCP github
#git clone https://github.com/Washington-University/gradunwarp.git

# Using our own version of gradunwarp
# This version includes the half-voxel 
# correction and is compatible with
# Python 3
cd $origDir
tar -zxvf gradunwarp_FMRIB.tar.gz
cd gradunwarp_FMRIB

if [ "$py_v" = "3.5.1" ] ; then
    for elem in `find . -name "*.py"` ; do python ../../bb_python3.5.1/bin/2to3 -w $elem ; done
fi
python setup.py install

#Clear not-needed files
cd ../..
rm -rf bb_python/bin/get-pip python_installation/gradunwarp_FMRIB python_installation/Python-$py_v python_installation/Python-$py_v.tgz

