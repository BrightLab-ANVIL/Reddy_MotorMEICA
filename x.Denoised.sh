#!/bin/bash
#This script uses denoised fMRI data to calculate DVARS and create a gray plot.

#Check if the inputs are correct
if [ $# -ne 5 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the denoised fMRI data"
  echo "Input 2 should be the brain mask"
  echo "Input 3 should be the gray matter (1s)/white matter (2s) mask"
  echo "Input 4 should be the subject ID"
  echo "Input 5 should be the output directory"
  exit
fi

input_file="${1}"
brain_mask="${2}"
GMWM_mask="${3}"
sub_ID="${4}"
output_dir=${5}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_DVARS.1D" ]
then

# Compute DVARS
3dTto1D -input ${input_file} -method dvars -mask ${brain_mask} -prefix ${output_dir}/${sub_ID}_DVARS.1D

# Create grayplots
range=0.05
rangeName="Point05"

3dGrayplot -input ${input_file} -mask ${GMWM_mask} -pvorder -range $range -prefix ${output_dir}/${sub_ID}_grayplot_range${rangeName}.png

else
  echo "** ALREADY RUN: subject=${sub_ID} **"
fi
