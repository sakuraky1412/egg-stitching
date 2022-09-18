I1 = imread('/Users/christine/Downloads/Tanmay_work/Egg_tifs_masks/NPM_working/2019_PS089_P1_a/2019_PS089_P1_a_EH.tif');
I2 = imread('/Users/christine/Downloads/Tanmay_work/Egg_tifs_masks/NPM_working/2019_PS089_P2_a/2019_PS089_P2_a_EH.tif');

points1 = detectSURFFeatures(I1);
points2 = detectSURFFeatures(I2);

[f1,vpts1] = extractFeatures(I1,points1);
[f2,vpts2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(f1,f2) ;