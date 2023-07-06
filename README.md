# Matching-of-extremely-variant-image-pairs
This repository provides the MATLAB Code (which uses MEX files of OpenCV Library) for Matching 10 Extremely Variant Image Pairs. This code was used for experiments in the research paper entitled: **"Potential of SIFT, SURF, KAZE, AKAZE, ORB, BRISK, AGAST, and 7 More Algorithms for Matching Extremely Variant Image Pairs"**. 

<ins>This code will work only after setting up **mexopencv** with your MATLAB. To do so, follow the guidelines mentioned in the **Step-1, Step-2, and Step-3 Instruction files**</ins>.

The code uses "full potential" of 14 feature detection algorithms by using their extremely low parameter thresholds. In this way, matching of extremely deteriorated images with their originals becomes robust.

The 14 feature detectors are: <ins>SIFT, SURF, KAZE, AKAZE, ORB, BRISK, AGAST, FAST, MSER, MSD, GFTT, Harris Corner Detector based GFTT, Harris Laplace Detector, Star Detector, and CenSurE</ins>.

The extremely variant image pairs represent 10 types of different deteriorations due to: <ins>extreme dust, smoke, darkness (dim light), extreme noise, motion-blur, extreme affine, JPEG compression, occlusion, sunlight/shadow, and decoration using light effects</ins>.

<ins>**If you use this code in any form, please cite our research paper**</ins>: https://ieeexplore.ieee.org/abstract/document/10099250

Complete PDF version of the research paper (with appendix) can be downloaded from this link: https://www.researchgate.net/publication/370177622_Potential_of_SIFT_SURF_KAZE_AKAZE_ORB_BRISK_AGAST_and_7_More_Algorithms_for_Matching_Extremely_Variant_Image_Pairs


## Important Instructions:
To run the code, download all the **.m** and **.mat** files (together with 10 image pairs) in **same folder**, and then execute the code...

**Code_Full_Potential.m** is the main (primary) code file which uses feature detectors with extremely low thresholds, for robust performance...

**Code_with_Default_Thresholds.m** is the secondary code file which uses feature detectors with default (normal) thresholds...
The "full potential performance" and the "normal performance" of the 14 feature detectors can be compared by running these 2 code files separately...

**analyseFeatureDetector.m** is a function which finds repeatability of the feature detector as well as correspondences between the image pair, by using ground-truth Homography...

**flannNNDRBasedMatching.m** is a function used to apply Nearest-Neighbor-Distance-Ratio (NNDR) based descriptor matching using FLANN...

**keypoint.mat** is a file used in the main code for improving computational efficiency while mapping keypoints to/from struct format...
