# Meniscus_T1rho_and_T2star
Matlab code for calculating T1rho and T2* for knee meniscus of PTOA subjects segmented in OsiriX.

A collection of Matlab M-files for reading Philips DICOM MRI T1rho and T2star knee image data, registering the spin lock or echo times using Melastix and elastix, reading OsiriX meniscus segmentation CSV files and calculating T1rho or T2star.

The analysis sequence is similar in structure to the sequence in MRI_T1rho_T2star_reliability repository.  Please see the ImageAnalysisPipeline6.pdf file.

The original two analyzes were:  1. Using the entire segmented meniscus (mri_m_fit.m) and 2. Using the segmented meniscus with the top and bottom pixels removed (eroded) (mri_em_fit.m).

The current M-file for generating the ROIs is seg_ama_rois.m.  The resulting output MAT files are used for calculating the qMRI (mri_mes_fit_y2.m).

Please see the header comments in the M-files.

Note that the data must be in particular subject directories with subdirectories for visits (BASELINE, YEAR1, and YEAR2).
