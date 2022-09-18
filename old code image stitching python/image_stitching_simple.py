# USAGE
# python image_stitching_simple.py --images images/scottsdale --output output.png

# import the necessary packages
import os

from imutils import paths
import numpy as np
import argparse
import imutils
import cv2
from PIL import Image


# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-i", "--images", type=str, required=True,
	help="path to input directory of images to stitch")
ap.add_argument("-m", "--masks", type=str, required=True,
	help="path to input directory of masks")
ap.add_argument("-o", "--output", type=str, required=True,
	help="path to the output image")
args = vars(ap.parse_args())

# grab the paths to the input images and initialize our images list
print("[INFO] loading images...")
imagePaths = sorted(list(paths.list_images(args["images"])))
images = []

print("[INFO] loading masks...")
masksPaths = sorted(list(paths.list_images(args["masks"])))
masks = []

assert len(imagePaths) == len(masksPaths)

# loop over the image paths, load each one, and add them to our
# images to stich list
for i, imagePath in enumerate(imagePaths):
	image = cv2.imread(imagePath)

	# src1 = cv2.imread(imagePath)
	# src2 = cv2.imread(masksPaths[i])
	#
	# # src2 = cv2.resize(src2, src1.shape[1::-1])
	# dst = cv2.bitwise_and(src1, src2)
	# # cv2.imwrite('opencv_bitwise_and.jpg', dst)
	#
	# # src = cv2.imread('images/eggs/opencv_bitwise_and.jpg', 1)
	# tmp = cv2.cvtColor(dst, cv2.COLOR_BGR2GRAY)
	# _, alpha = cv2.threshold(tmp, 0, 255, cv2.THRESH_BINARY)
	# b, g, r = cv2.split(dst)
	# rgba = [b, g, r, alpha]
	# dst = cv2.merge(rgba, 4)
	# outputPath = os.path.join("images/output/", os.path.basename(imagePath))
	#
	# if dst.shape[1] > dst.shape[0]:
	# 	dst = cv2.rotate(dst, cv2.ROTATE_90_COUNTERCLOCKWISE)
	#
	# cv2.imwrite(outputPath, dst)

	images.append(image)



# initialize OpenCV's image sticher object and then perform the image
# stitching
print("[INFO] stitching images...")
stitcher = cv2.createStitcher() if imutils.is_cv3() else cv2.Stitcher_create()
(status, stitched) = stitcher.stitch(images)

# if the status is '0', then OpenCV successfully performed image
# stitching
if status == 0:
	# write the output stitched image to disk
	cv2.imwrite(args["output"], stitched)

	# display the output stitched image to our screen
	cv2.imshow("Stitched", stitched)
	cv2.waitKey(0)

# otherwise the stitching failed, likely due to not enough keypoints)
# being detected
else:
	print("[INFO] image stitching failed ({})".format(status))