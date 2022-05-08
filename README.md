# JPEG-Compression-Algorithm

## OVERVIEW
Please see for overview on how JPEG Compression Algorithm works.


https://www.youtube.com/watch?v=g_XFw7jQmlo&t=549s&ab_channel=bernardgonzales

Overview: This program simulates the JPEG Compression algorithm in MATLAB. 

Procedure: 

1. Import image
2. Convert to YCbCr
3. Subsample components to 4:2:2
4. Perform DCT 
5. Quantize 
6. Zigzag scan 
7. Run-Length encode 
8. Arithmetic encode
9. Arithmetic decode 
10. Run-Length decode 
11. Inverse zig zag scan
12. Inverse DCT
13. Upsample to 4:4:4
14. Convert to RGB 

Note: In the program I swapped the places of Run-Length Encode/Decode and Arithmetic Encode/Decode to decrease processing time.

## PREREQUISITES
To run this MATLAB program you will need the following: </br>
1. MATLAB with the following tool boxes installed: Computer Vision Toolbox & Image Processing Toolbox


## RUNNING THE PROGRAM
1. Download and extract the .m files onto your local machine.
2. Open MATLAB
3. In MATLAB, change current folder to the location of the downloaded .m files.
4. Open the EE652_JPEG_Compression_Project.m file.
5. Click the run button. 


## RESULTS
* The program will run through each step of the JPEG compression algorithm. Each step is described in the pop up text box.
* The Arithmetic coding step takes a few minutes to complete.
* Both the original and reconstructed images are displayed after program completion.