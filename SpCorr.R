# Calculate spatial correlation and Dice coefficients for Limited vs Amplified maps

# Inputs:
# Limited motion beta coefficient map
# Amplified motion beta coefficient map
# Limited motion tstat map of significant positive voxels
# Amplified motion tstat map of significant positive voxels
# Brain mask

library(oro.nifti)

SpCorr <- function(limBeta,ampBeta,limTmask,ampTmask,brain_mask) {
  lim <- readNIfTI(limBeta)
  amp <- readNIfTI(ampBeta)
  lim_t <- readNIfTI(limTmask)
  amp_t <- readNIfTI(ampTmask)
  brainMask <- readNIfTI(brain_mask)
   
  # Correlation between unthresholded Limited and Amplified maps
  corr_unthresh=cor(lim*brainMask,amp*brainMask,method='pearson',use="na.or.complete")
  corr_unthresh <<- corr_unthresh
  
  # Correlation between maps thresholded by Limited map significant positive voxels
  lim_t[ lim_t > 0 ] = 1
  mask <- lim_t*brainMask

  limBinMask <- lim_t > 0
  ampBinMask <- amp_t > 0
  
  corr_thresh=cor(lim*mask,amp*mask,method='pearson',use="na.or.complete") 
  corr_thresh <<- corr_thresh
  
  # Dice coefficient between both maps thresholded independently
  maskOverlap <- limBinMask*ampBinMask*brainMask
  dice=2*sum(maskOverlap,na.rm=T)/(sum(limBinMask*brainMask)+sum(ampBinMask*brainMask))
  dice <<- dice
}