#!/bin/bash
#This script uses beta coefficient and t-statistic maps to run analysis within an ROI.

#Check if the inputs are correct
if [ $# -ne 7 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the beta coefficient map"
  echo "Input 2 should be the t-statistic map (don't include '.nii.gz' in file name)"
  echo "Input 3 should be the ROI mask"
  echo "Input 4 should be the degrees of freedom"
  echo "Input 5 should be the brain mask"
  echo "Input 6 should be the subject ID"
  echo "Input 7 should be the output directory"
  exit
fi

input_bcoef="${1}"
input_tstat="${2}"
ROI="${3}"
dof="${4}"
brain_mask="${5}"
sub_ID="${6}"
output_dir=${7}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${sub_ID}_ROIstats.txt" ]
then

  # calculate no. pos voxels, median bcoef, and tstat
  # find t-stat threshold for a < 0.05
  tstat=$( cdf -p2t fitt 0.05 ${dof} )
  tstat=${tstat##* }
  echo "tstat is $tstat in $model"

  # convert tstat to z score by FDR correction and threshold significant positive voxels
  3dFDR -input ${input_tstat}.nii.gz -mask ${brain_mask} -prefix ${input_tstat}_fdr.nii.gz
  fslmaths ${input_tstat}_fdr.nii.gz -thr ${tstat} ${input_tstat}_fdr05.nii.gz # threshold by tstat (includes pos and neg significant tstats)
  fslmaths ${input_tstat}.nii.gz -thr 0 -bin ${input_tstat}_thrp.nii.gz # find where tstat is positive
  3dcalc -a ${input_tstat}_fdr05.nii.gz -b ${input_tstat}_thrp.nii.gz \
    -expr 'a*b' -prefix ${input_tstat}_fdrp05.nii.gz # FDR-correct p > 0.05, only positive activated voxels

  # calculate activation extent, median beta coefficient, median t-statistic
  actExtent=`3dBrickStat -positive -nonan -count -mask ${ROI} ${input_tstat}_fdrp05.nii.gz`
    totROIvox=`3dBrickStat -count -non-zero ${ROI}`
    actExtentPer=`printf "%.6f\n" $((10**6 * $actExtent/$totROIvox))e-6` # gives 6 digits after decimal
  medbcoef_full=`3dBrickStat -nonan -median -positive -mask ${ROI} ${input_bcoef}`
    medbcoef_full_length=${#medbcoef_full}
    medianb=`echo ${medbcoef_full} | cut -c6-${medbcoef_full_length}`
  medtstat_full=`3dBrickStat -nonan -median -positive -mask ${ROI} ${input_tstat}.nii.gz`
    medtstat_full_length=${#medtstat_full}
    mediant=`echo ${medtstat_full} | cut -c6-${medtstat_full_length}`

  # Save to text file: Subject ID, activation extent, median bcoef, median tstat in ROI
  echo -e ${sub_ID} '\t' ${actExtentPer} '\t' ${medianb} '\t' ${mediant} >> ${output_dir}/${sub_ID}_ROIstats.txt


else
  echo "** ALREADY RUN: subject=${sub_ID} **"
fi
