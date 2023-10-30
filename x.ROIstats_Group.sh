#!/bin/bash
#This script uses beta coefficient and t-statistic maps to run analysis within an ROI on the group level.

#Check if the inputs are correct
if [ $# -ne 6 ]
then
  echo "Insufficient inputs"
  echo "Input 1 should be the beta coefficient map (unthresholded)"
  echo "Input 2 should be the t-statistic map (unthresholded)"
  echo "Input 3 should be the t-statistic map (clustered)"
  echo "Input 4 should be the ROI mask"
  echo "Input 5 should be the output prefix"
  echo "Input 6 should be the output directory"
  exit
fi

input_bcoef="${1}"
input_tstat="${2}"
input_tstat_c="${3}"
ROI="${4}"
output_prefix="${5}"
output_dir=${6}

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi

if [ ! -f ${output_dir}/"${output_prefix}_ROIstats.txt" ]
then

  # calculate activation extent, median beta coefficient, median t-statistic
  actExtent=`3dBrickStat -positive -nonan -count -mask ${ROI} ${input_tstat_c}`
    totROIvox=`3dBrickStat -count -non-zero ${ROI}`
    actExtentPer=`printf "%.6f\n" $((10**6 * $actExtent/$totROIvox))e-6` # gives 6 digits after decimal
  medbcoef_full=`3dBrickStat -nonan -median -positive -mask ${ROI} ${input_bcoef}`
    medbcoef_full_length=${#medbcoef_full}
    medianb=`echo ${medbcoef_full} | cut -c6-${medbcoef_full_length}`
  medtstat_full=`3dBrickStat -nonan -median -positive -mask ${ROI} ${input_tstat}`
    medtstat_full_length=${#medtstat_full}
    mediant=`echo ${medtstat_full} | cut -c6-${medtstat_full_length}`

  # Save to text file: Subject ID, activation extent, median bcoef, median tstat in ROI
  echo -e ${output_prefix} '\t' ${actExtentPer} '\t' ${medianb} '\t' ${mediant} >> ${output_dir}/${output_prefix}_ROIstats.txt


else
  echo "** ALREADY RUN: ${output_prefix} **"
fi
