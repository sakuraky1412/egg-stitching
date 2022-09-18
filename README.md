# Egg stitching 

Given images of the four sides (a, b, c, d) of an egg, stitch the images together to form a panorama of the egg. 

## Description

This code is used in the study of the invariant features of eggshell patterns between host and parasite birds.

## Getting Started

### Dependencies

* [OpenCV 4.2.0](https://opencv.org/opencv-4-2-0/)
* [Nature Pattern Match](http://www.naturepatternmatch.org/) (optional, only needed for generating input files)

### Directory

- opencv_imagestitching_v4.py
  - Main python file to be executed to produce stitched egg images
- matched features folder
  - Contains matched features csv files, which are generated with a modified version of NPM with the eggshell image data set. 
- old code folder
  - Contains code files in experimental stages 
- 00_prinias with eggs wrong way around
  - Excel file that stores the names of the eggs whose images are upside down

### Input

* A matched features csv file

  * generated with NPM, containing the following columns

    ```
    ref_id,pt1x,pt1y, query_id,pt2x,pt2y
    ```

  * Ref_id and query_id refer to the name of the egg images matched together

  * Pt1x, pt1y, pt2x, pt2y marks the start and end points of the matched SIFT features

* Eggshell image data set

  * The corresponding images of the four sides of the eggs


### Executing program

* Create "images" folder and create "input" and "output" folders in it
* Put the eggshell images to be stitched in the "input" folder, e.g.

  * 2020_PS056_P1_a_EH.tif
  * 2020_PS056_P1_b_EH.tif
  * 2020_PS056_P1_c_EH.tif
  * 2020_PS056_P1_d_EH.tif

* Edit opencv_imagestitching_v4.py line 165 to specify the matched features file name, e.g. "matched features/matched_features_2020_PS056_P1.csv".
* (Optional) edit line 180 to use the correct delimiter, either "," or ";", depending on the csv file, if you get an "IndexError: list index out of range" on line 185
* Execute opencv_imagestitching_v4.py

  * Example output

    ```
    Start reading npm sift features...
    Egg 1/1
    Start reading 2020_PS056_P1...
    Start stitching 2020_PS056_P1...
    ```


- The stitched image files will be written to images/output
  - 2020_PS056_P1_stitched.tif

## Authors

[Kuan-Chi Chen](chen26k@mtholyoke.edu), [Tanmay Dixit](td349@cam.ac.uk), [Christopher Town](cpt23@cam.ac.uk)

## Acknowledgments

[Stoddard, M. C., R. M. Kilner, and C. Town. 2014.](https://www.nature.com/articles/ncomms5117) Pattern recognition algorithm reveals how birds evolve individual egg pattern signatures. Nature Communications. DOI: 10.1038/ncomms5117

Lowe, D. G. Object recognition from local scale-invariant features. Proc Seventh IEEE Int. Conf. Computer Vision (IEEE) 2, 1150–1157 (1999).
