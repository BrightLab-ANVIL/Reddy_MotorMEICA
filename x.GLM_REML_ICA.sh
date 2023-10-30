#!/bin/bash
#This script uses pre-processed brain fMRI data and and creates a general linear model using AFNI and FSL.

#Check if the inputs are correct
if [ $# -ne 9 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the fMRI data you want to model"
  echo "Input 2 should be the demeaned motion parameters"
  echo "Input 3 should be the demeaned R grip regressor"
  echo "Input 4 should be the demeaned L grip regressor"
  echo "Input 5 should be the subject ID"
  echo "Input 6 should be the output directory"
  echo "Input 7 should be the demeaned end-tidal CO2 regressor"
  echo "Input 8 should be the orthogonalized rejected ICA components"
  echo "Input 9 should be the number of rejected ICA components"
  exit
fi

input_file="${1}"
motion_file="${2}"
Rgrip_file="${3}"
Lgrip_file="${4}"
sub_ID="${5}"
output_dir=${6}
CO2_file="${7}"
rejComp_file="${8}"
num_ica="${9}"

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_bucket.nii.gz" ]
then

  # Create design matrix using 3dDeconvolve
  # Add the correct number of rejected ICA components to GLM
  run3dDeconvolve="3dDeconvolve -input ${input_file} -polort 4 -num_stimts $((9+${num_ica}))"
	run3dDeconvolve="${run3dDeconvolve} -stim_file 1 "${motion_file}[0]" -stim_label 1 MotionRx"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 2 "${motion_file}[1]" -stim_label 2 MotionRy"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 3 "${motion_file}[2]" -stim_label 3 MotionRz"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 4 "${motion_file}[3]" -stim_label 4 MotionTx"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 5 "${motion_file}[4]" -stim_label 5 MotionTy"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 6 "${motion_file}[5]" -stim_label 6 MotionTz"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 7 "${Rgrip_file}" -stim_label 7 RGrip"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 8 "${Lgrip_file}" -stim_label 8 LGrip"
  run3dDeconvolve="${run3dDeconvolve} -stim_file 9 "${CO2_file}" -stim_label 9 CO2"

  for i in $(seq 1 1 ${num_ica});
  do
    run3dDeconvolve="${run3dDeconvolve} -stim_file $((9+${i})) "${rejComp_file}{$((${i}-1))}"\' -stim_label $((9+${i})) "Rej${i}""
  done

  run3dDeconvolve="${run3dDeconvolve} -x1D ${output_dir}/"${sub_ID}_matrix.1D" -x1D_stop" #save matrix but don't run analysis

  eval ${run3dDeconvolve}

  # Run GLM using 3dREMLfit
  3dREMLfit -input ${input_file} \
    -matrix ${output_dir}/"${sub_ID}_matrix.1D" \
    -tout -rout \
    -Rbeta ${output_dir}/"${sub_ID}_bcoef.nii.gz" \
    -Rbuck ${output_dir}/"${sub_ID}_bucket.nii.gz" \
    -Rfitts ${output_dir}/"${sub_ID}_fitts.nii.gz" \
    -Rerrts ${output_dir}/"${sub_ID}_errts.nii.gz"

  # Calculate beta coefficients x each nuisance regressor and subtract from OC time series
  3dSynthesize -cbucket ${output_dir}/"${sub_ID}_bcoef.nii.gz" \
    -matrix ${output_dir}/"${sub_ID}_matrix.1D" \
    -select polort Rej Motion CO2 \
    -prefix ${output_dir}/"${sub_ID}_noise.nii.gz"

  3dcalc -a ${input_file} \
    -b ${output_dir}/"${sub_ID}_noise.nii.gz" \
    -expr 'a-b' \
    -prefix ${output_dir}/"${sub_ID}_denoised.nii.gz"

else
  echo "** ALREADY RUN: subject=${sub_ID} **"
fi
