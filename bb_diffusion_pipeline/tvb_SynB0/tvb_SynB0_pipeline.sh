#!/bin/bash

direc=$PWD/$1
SynB0_OUTPUTS=${direc}/dMRI/dMRI/SynB0

SynB0_TOPUP=1

for arg in "$@"
do
    case $arg in
        -i|--notopup)
        SynB0_TOPUP=0
    esac
done


# Set paths for executables
SynB0_DIR=$BB_BIN_DIR/bb_diffusion_pipeline/tvb_SynB0
export PATH=$PATH:$SynB0_DIR/data_processing:$SynB0_DIR/src

# Set up ANTS << move to init_vars?
#export ANTSPATH="/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Compiler/gcc9/ants/2.3.5/bin"

# Set up pytorch
#source /extra/pytorch/bin/activate # do I need to create a virtual environment on CC to activate this?

# Prepare input
${SynB0_DIR}/data_processing/SynB0_prepare_input.sh ${direc}/dMRI/dMRI/DWI_B0.nii.gz ${direc}/T1/T1_unbiased.nii.gz ${direc}/T1/T1_unbiased_brain.nii.gz ${SynB0_DIR}/atlases/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz ${SynB0_DIR}/atlases/mni_icbm152_t1_tal_nlin_asym_09c_2_5.nii.gz $SynB0_OUTPUTS

# Run inference
NUM_FOLDS=5
for i in $(seq 1 $NUM_FOLDS);
  do echo Performing inference on FOLD: "$i"
  python $SynB0_DIR/src/SynB0_inference.py $SynB0_OUTPUTS/T1_norm_lin_atlas_2_5.nii.gz $SynB0_OUTPUTS/b0_d_lin_atlas_2_5.nii.gz $SynB0_OUTPUTS/b0_u_lin_atlas_2_5_FOLD_"$i".nii.gz $SynB0_DIR/src/train_lin/num_fold_"$i"_total_folds_"$NUM_FOLDS"_seed_1_num_epochs_100_lr_0.0001_betas_\(0.9\,\ 0.999\)_weight_decay_1e-05_num_epoch_*.pth
done

# Take mean
echo Taking ensemble average
${FSLDIR}/bin/fslmerge -t $SynB0_OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz $SynB0_OUTPUTS/b0_u_lin_atlas_2_5_FOLD_*.nii.gz
${FSLDIR}/bin/fslmaths $SynB0_OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz -Tmean $SynB0_OUTPUTS/b0_u_lin_atlas_2_5.nii.gz

# Apply inverse xform to undistorted b0
echo Applying inverse xform to undistorted b0
${ANTSPATH}/antsApplyTransforms -d 3 -i $SynB0_OUTPUTS/b0_u_lin_atlas_2_5.nii.gz -r ${direc}/dMRI/dMRI/DWI_B0.nii.gz -n BSpline -t [$SynB0_OUTPUTS/epi_reg_d_ANTS.txt,1] -t [$SynB0_OUTPUTS/ANTS0GenericAffine.mat,1] -o $SynB0_OUTPUTS/b0_u.nii.gz

# Smooth image
echo Applying slight smoothing to distorted b0
${FSLDIR}/bin/fslmaths ${direc}/dMRI/dMRI/DWI_B0.nii.gz -s 1.15 $SynB0_OUTPUTS/b0_d_smooth.nii.gz

if [[ $SynB0_TOPUP -eq 1 ]]; then
    # Merge results and run through topup
    echo Running topup
    ${FSLDIR}/bin/fslmerge -t $SynB0_OUTPUTS/b0_all.nii.gz $SynB0_OUTPUTS/b0_d_smooth.nii.gz $SynB0_OUTPUTS/b0_u.nii.gz
    ${FSLDIR}/bin/topup -v --imain=$SynB0_OUTPUTS/b0_all.nii.gz --datain=${direc}/dMRI/dMRI/acqparams.txt --config=b02b0.cnf --iout=$SynB0_OUTPUTS/DWI_B0_all_topup.nii.gz --out=$SynB0_OUTPUTS/topup --subsamp=1,1,1,1,1,1,1,1,1 --miter=10,10,10,10,10,20,20,30,30 --lambda=0.00033,0.000067,0.0000067,0.000001,0.00000033,0.000000033,0.0000000033,0.000000000033,0.00000000000067 --scale=0
fi


# Done
echo FINISHED!!!
