TVB - UK Biobank Pipeline
===================

The `TVB - UK Biobank Pipeline` project is a multi-modal MRI processing pipeline written in Python, bash, MATLAB, and R. It uses [FSL](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) as the basic building blocks and is heavily based on [the UK Biobank Pipeline](https://git.fmrib.ox.ac.uk/falmagro/UK_biobank_pipeline_v_1), developed by the [FMRIB Analysis Group, University of Oxford](https://www.win.ox.ac.uk/research/analysis-research).

The TVB implementation includes the addition of a user-provided parcellation for 1) computing ROI-based timeseries and functional connectivity (Pearson correlations) using resting-state fMRI; and 2) connectome construction using diffusion-weighted imaging tractography.



Dependencies
------------

The only external dependencies required for this pipeline are:
* FSL (6.0.4)
* AFNI (18.0.22)
* Freesurfer (5.3.0)
* Anaconda/Miniconda (latest release)
* git (>=2)
* gfortran (installation only)
* OGS/GE (Open Grid Scheduler/Grid Engine version 2011.11)

Note: these software versions are what we used to develop the pipeline. Newer versions may work but we cannot guarantee that.

Note: these software versions are what we used to develop the pipeline. Newer versions may work but we cannot guarantee that.


Installation
------------

**RRI USERS - PLEASE COMPLETE THIS STEP FIRST**

Note: these instructions are specifically for `gateway`. This has not been tested on any other system so it is advised to install onto `gateway`.
* Copy the following and paste it at the bottom of your .bashrc file in your home directory on `gateway`:
```
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nfrazier-logue/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nfrazier-logue/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nfrazier-logue/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nfrazier-logue/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```
* Create a directory in your home directory called `conda_cache`.
* Create a file in your home directory on gateway called `.condarc` and copy the following into it:
```
channels:
 - defaults
 - anaconda
 - conda-forge
pkgs_dirs:
 - /home/<username>/conda_cache
```
  where `<username>` on the last line is your `gateway` username. Continue with the rest of the instructions below.

**GENERAL INSTALL INSTRUCTIONS**

1) Download the [latest release .zip from the repository here](https://github.com/McIntosh-Lab-RRI/tvb-ukbb/releases/latest) (read the instructions on the release page)
2) Unzip the .zip file to where you'd like the pipeline to be installed; e.g. unzipping it in `/home/<username>` will yield `/home/<username>/tvb-pipeline`
3) `cd` into `tvb-pipeline` and run `chmod +x install_ukbb.sh`
4) Run `./install_ukbb.sh`. This may take a while and **you will have to enter your GitHub username and password midway through** as the repository is currently invite-only.
5) Once the installer finishes, `cd` into `tvb-ukbb` and edit file `init_vars`. Lines specified with `#TO BE MODIFIED BY USER` are the only lines you should need to change.

Note: at present, changes may need to be made to the code handling Grid Engine/SGE queuing depending on your system. Currently we use queues `all.q`, `bigmem_16.q`, and `bigmem_64.q`; they are set to their respective environment variables by default in `init_vars` and can be modified as necessary.

Usage
-----

Following the installation example above,

1) Source the file `init_vars` to activate the conda environment and define environment variables. For example, if your pipeline is located at `/home/username/tvb-pipeline/`, simply run

`. /home/username/tvb-pipeline/tvb-ukbb/init_vars`

and your environment will be loaded.

2) `cd` to the directory containing your subject directory, e.g., `subjDir`.

3) Run a subject with

`python /home/username/tvb-pipeline/tvb-ukbb/bb_pipeline_tools/bb_pipeline.py subjDir`

4) Monitor the progress of your subject by `cd`ing to `subjDir/logs`.


Documentation
-------------

The original `UK_biobank_pipeline` is explained in detail in the paper [Image Processing and Quality Control for the first 10,000 Brain Imaging Datasets from UK Biobank](http://www.biorxiv.org/content/early/2017/04/24/130385).

Tractography for connectome construction is based on methods validated using tracer data in macaques (see Shen et al. 2019 https://doi.org/10.1016/j.neuroimage.2019.02.018).


Notes
-----

Parameter settings for processing toolboxes need to be customized to the acquisitions. It is advised that you review parameter choices for FSL tools including, but not limited to, EDDY, BEDPOSTX, PROBTRACKX2, FEAT, and FIX. Also note that FIX will require a training .RData file specific to your dataset. BIANCA (if you have T2 FLAIR images) will also require a manually segmented WM lesion training set.

.RData training files for FIX should be compatible with R 3.4.1. .RData files created in newer versions of R may work but there is no guarantee. It is recommended to create training files using the conda env and included R version.

Currently, gradient distortion correction, TOPUP distortion correction, NODDI,  AUTOPTX, task fMRI and susceptibility-weighted imaging processing from the original UKBiobank pipeline are either not implemented or remain untested.
