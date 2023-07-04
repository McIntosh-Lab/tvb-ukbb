TVB - UK Biobank Pipeline
===================

The `TVB - UK Biobank Pipeline` project is a multi-modal MRI processing pipeline written in Python, bash, MATLAB, and R. It uses [FSL](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) as the basic building blocks and is heavily based on [the UK Biobank Pipeline](https://git.fmrib.ox.ac.uk/falmagro/UK_biobank_pipeline_v_1), developed by the [FMRIB Analysis Group, University of Oxford](https://www.win.ox.ac.uk/research/analysis-research).

The TVB implementation includes the addition of a user-provided parcellation for 1) computing ROI-based timeseries and functional connectivity (Pearson correlations) using resting-state fMRI; and 2) connectome construction using diffusion-weighted imaging tractography.

Paper
-----

This code supports the submitted paper "**A robust modular automated neuroimaging pipeline for model inputs to TheVirtualBrain**" by Noah Frazier-Logue, Justin Wang, Zheng Wang, Devin Sodums, Anisha Khosla, Alexandria Samson, Anthony R. McIntosh, and Kelly Shen.

See here for the paper preprint: https://doi.org/10.1101/2022.02.24.481836

Installation and Usage
----------------------

Check out [the wiki](https://github.com/McIntosh-Lab/tvb-ukbb/wiki) to view [installation instructions](https://github.com/McIntosh-Lab/tvb-ukbb/wiki/General-HPC-Installation-and-Usage) and [usage instructions](https://github.com/McIntosh-Lab/tvb-ukbb/wiki/Basic-Usage) for the TVB-UKBB pipeline, as well as [an overview of the pipeline](https://github.com/McIntosh-Lab/tvb-ukbb/wiki/Pipeline-Overview) and information on [how to customize the pipeline for your datasets](https://github.com/McIntosh-Lab/tvb-ukbb/wiki/Customizing-the-Pipeline).



Documentation
-------------

The original `UK_biobank_pipeline` is explained in detail in the paper [Image Processing and Quality Control for the first 10,000 Brain Imaging Datasets from UK Biobank](http://www.biorxiv.org/content/early/2017/04/24/130385).

Tractography for connectome construction is based on methods validated using tracer data in macaques (see Shen et al. 2019 https://doi.org/10.1016/j.neuroimage.2019.02.018).


Notes
-----

Parameter settings for processing toolboxes need to be customized to the acquisitions. It is advised that you review parameter choices for FSL tools including, but not limited to, EDDY, BEDPOSTX, PROBTRACKX2, FEAT, and FIX. Also note that FIX will require a training .RData file specific to your dataset. BIANCA (if you have T2 FLAIR images) will also require a manually segmented WM lesion training set.

.RData training files for FIX should be compatible with R 3.4.1. .RData files created in newer versions of R may work but there is no guarantee. It is recommended to create training files using the conda env and included R version.

Currently, gradient distortion correction, TOPUP distortion correction, NODDI,  AUTOPTX, task fMRI and susceptibility-weighted imaging processing from the original UKBiobank pipeline are either not implemented or remain untested.
