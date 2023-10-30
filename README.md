## Denoising task-correlated head motion from motor-task fMRI data with multi-echo ICA
This analysis code is shared alongside the manuscript found here: https://doi.org/10.1101/2023.07.19.549746

Relevant data files can be found on OpenNeuro: https://doi.org/10.18112/openneuro.ds004662.v1.0.0

## Code
### MRI pre-processing and registration
All anatomical and functional MRI pre-processing and registration scripts can be found at https://github.com/BrightLab-ANVIL/PreProc_BRAIN

Detailed information on tedana and mult-echo fMRI analysis can be found at https://tedana.readthedocs.io

### Motion analysis
MotionCalc.m: Calculation of Framewise Displacement (FD) and task-correlation of motion

### Subject-level fMRI analysis
x.GLM_REML_ICA.sh: Subject-level modeling for ME-ICA models

x.GLM_REML.sh: Subject-level modeling for SE and ME-OC models

x.Denoised.sh: Calculation of DVARS and creation of grayplots from denoised datasets

x.ROIstats.sh: ROI analysis

SpCorr.R: Spatial correlation analysis

### Group-level fMRI analysis
x.GroupLevel.sh: Group-level modeling and clustering

