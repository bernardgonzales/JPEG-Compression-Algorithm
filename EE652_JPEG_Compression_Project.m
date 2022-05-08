% Bernard Gonzales
% JPEG Data Compression
% EE652
% Description: This script is the main driver for the JPEG Data
% Compression. 

%% Clean
clc
close all
clear
clearvars;


%% Initialization - Read in source image 

% Read in image
rgbImage = imread('mazmass_1600x1200.jpg');


%% Subsample 

% Convert the image from RGB to YCbCr
ycbcr = rgb2ycbcr(rgbImage);

% Separate Y, Cb, and Cr
Y = ycbcr(:,:,1);
Cb = ycbcr(:,:,2);
Cr = ycbcr(:,:,3);

% Subsample Cb/Cr to 4:2:2 by overwriting every other pizel with the
% previous value
up_resampler = vision.ChromaResampler();
up_resampler.Resampling = '4:4:4 to 4:2:2';
[SubCb, SubCr] = up_resampler(Cb, Cr);


%% DCT 
% Perform DCT on all components. Using PadPartialBlocks to pad partial
% blocks with zeros to make them full sized.

DCT = @(block_struct) dct2(block_struct.data);

yDCT = blockproc(Y,[8 8],DCT);
cbDCT = blockproc(SubCb,[8 8],DCT,'PadPartialBlocks' ,true);
crDCT = blockproc(SubCr,[8 8],DCT,'PadPartialBlocks' ,true);


%% Quantization 
% Quanitize all components by dividing each value in the 8x8 block by 
% the corresponding luminance nad chrominance values.

Luminance = [16 11 10 16 24 40 51 61
             12 12 14 19 26 58 60 55
             14 13 16 24 40 57 69 56
             14 17 22 29 51 87 80 62
             18 22 37 56 68 109 103 77
             24 35 55 64 81 104 113 92
             49 64 78 87 103 121 120 101
             72 92 95 98 112 100 103 99];
        
Chrominance = [17 18 24 47 99 99 99 99;
              18 21 26 66 99 99 99 99;
              24 26 56 99 99 99 99 99
              47 66 99 99 99 99 99 99;
              99 99 99 99 99 99 99 99;
              99 99 99 99 99 99 99 99;
              99 99 99 99 99 99 99 99;
              99 99 99 99 99 99 99 99;];

yQuantStruct = @(block_struct) round(block_struct.data./Luminance);
cbCrQuantStruct = @(block_struct) round(block_struct.data./Chrominance);

quantizedY = blockproc(yDCT, [8 8], yQuantStruct);
quantizedCb = blockproc(cbDCT, [8 8], cbCrQuantStruct);
quantizedCr = blockproc(crDCT, [8 8], cbCrQuantStruct);


%% Zigzag 
% List the quanitized values into a long line. Prepartion for Arithmetic
% Coding.

yZigZag = zeros(size(quantizedY, 1)/8 * size(quantizedY, 2)/8, 64);
cbZigZag = zeros(size(quantizedCb, 1)/8 * size(quantizedCb, 2)/8, 64);
crZigZag = zeros(size(quantizedCr, 1)/8 * size(quantizedCr, 2)/8, 64);
index = 1;
yBlock = zeros(8);
cbBlock = zeros(8);
crBlock = zeros(8);

%Zigzag trace each block of Y and store in yZigZag
for row = 1:8:size(quantizedY, 1) 
    for col = 1:8:size(quantizedY, 2) 

        % Declare block location
        endRow = row + 7;
        endCol = col + 7;
        
        % Isolate block
        yBlock = quantizedY(row:endRow, col:endCol);
        yZigZag(index, :) = Zigzag(yBlock);
        
        index = index + 1;
    end
end

% Reset index for storing zigzag values
index = 1;

%Zigzag trace each block of Cb and Cr and store in (cb/cr)ZigZag
for row = 1:8:size(quantizedCb, 1)
    for col = 1:8:size(quantizedCb, 2)

        % Declare block location
        endRow = row + 7;
        endCol = col + 7;
        
        % Isolate block and zigzag
        cbBlock = quantizedCb(row:endRow, col:endCol);
        cbZigZag(index, :) = Zigzag(cbBlock);
        
        crBlock = quantizedCr(row:endRow, col:endCol);
        crZigZag(index, :) = Zigzag(crBlock);
        
        index = index + 1;
    end
end


%% Run Length Encoding
rleY = {};
rleCb = {};
rleCr = {};

% Run-Length encode all rows of arthimetic encoded Y
disp("Performing Run-Length Encoding on Y component...");
for row = 1 : size(yZigZag,1)
    res = RunLengthEncode(yZigZag(row,:));
    rleY(row,:) = {res};
end
disp("Done")

% Run-Length encode all rows of arthimetic encoded Cb
disp("Performing Run-Length Encoding on Cb component...");
for row = 1: size(cbZigZag,1)
    res = RunLengthEncode(cbZigZag(row,:));
    rleCb(row,:) = {res};
end
disp("Done")

% Run-Length encode all rows of arthimetic encoded Cr
disp("Performing Run-Length Encoding on Cr component...");
for row = 1: size(crZigZag,1)
    res = RunLengthEncode(crZigZag(row,:));
    rleCr(row,:) = {res};
end
disp("Done")


%% Arithmetic Encoding


% Perform Arithmetic Encoding on run-length encoded Y
sourceY = {};
seqY = {};
countsY = {};
arithEncodedY = {};

disp("Performing Arithmetic Encoding on Y component...");
[sourceY, seqY, countsY, arithEncodedY] = ArithmeticEncode(rleY, "Y");
disp("Done")

% Perform Arithmetic Encoding on run-length encoded Cb
sourceCb = {};
seqCb = {};
countsCb = {};
arithEncodedCb = {};

disp("Performing Arithmetic Encoding on Cb component...");
[sourceCb, seqCb, countsCb, arithEncodedCb] = ArithmeticEncode(rleCb, "Cb");
disp("Done")

% Perform Arithmetic Encoding on run-length encoded Cr
sourceCr = {};
seqCr = {};
countsCr = {};
arithEncodedCr = {};

disp("Performing Arithmetic Encoding on Cr component...");
[sourceCr, seqCr, countsCr, arithEncodedCr] = ArithmeticEncode(rleCr, "Cr");
disp("Done")


%% Arithmetic Decoding
arithDecodedY = {};
arithDecodedCb = {};
arithDecodedCr = {};

% Perform Arithmetic Decoding on run-length decoded Y
disp("Performing Arithmetic Decoding on Y component...");
[arithDecodedY] = ArithmeticDecode(sourceY,countsY,seqY,arithEncodedY);
disp("Done")

% Perform Arithmetic Decoding on run-length decoded Cb
disp("Performing Arithmetic Decoding on Cb component...");
[arithDecodedCb] = ArithmeticDecode(sourceCb,countsCb,seqCb,arithEncodedCb);
disp("Done")

% Perform Arithmetic Decoding on run-length decoded Cr
disp("Performing Arithmetic Decoding on Cr component...");
[arithDecodedCr] = ArithmeticDecode(sourceCr,countsCr,seqCr,arithEncodedCr);
disp("Done")

%% Run Length Decoding
rldY = {};
rldCb = {};
rldCr = {};

% Run-Length decode all rows on run-length encoded Y
disp("Performing Run-Length Decoding on Y component...");
counter = 1;
for (cell = 1 : 2 : size(arithDecodedY,2))
    fun1 = cell2mat(arithDecodedY(cell));
    fun2 = cell2mat(arithDecodedY(cell+1));
    rldY(counter,:) = {RunLengthDecode( fun2, fun1 )};
    counter = counter + 1;
end
disp("Done")


% Run-Length decode all rows on run-length encoded Cb
disp("Performing Run-Length Decoding on Cb component...");
counter = 1;
for (cell = 1 : 2 : size(arithDecodedCb,2))
    fun1 = cell2mat(arithDecodedCb(cell));
    fun2 = cell2mat(arithDecodedCb(cell+1));
    rldCb(counter,:) = {RunLengthDecode( fun2, fun1 )};
    counter = counter + 1;
end
disp("Done")

% Run-Length decode all rows on run-length encoded Cr
disp("Performing Run-Length Decoding on Cr component...");
counter = 1;
for (cell = 1 : 2 : size(arithDecodedCr,2))
    fun1 = cell2mat(arithDecodedCr(cell));
    fun2 = cell2mat(arithDecodedCr(cell+1));
    rldCr(counter,:) = {RunLengthDecode( fun2, fun1 )};
    counter = counter + 1;
end
disp("Done")


%% Inverse Zigzag

rleMatY = cell2mat(rldY);
rleMatCb = cell2mat(rldCb);
rleMatCr = cell2mat(rldCr);

invYZigZag = zeros(size(quantizedY, 1), size(quantizedY, 2));
invCbZigZag = zeros(size(quantizedCb, 1), size(quantizedCb, 2));
invCrZigZag = zeros(size(quantizedCr, 1), size(quantizedCr, 2));

index = 1;

for row = 1:8:size(quantizedY, 1)
    for col = 1:8:size(quantizedY, 2)
        endRow = row + 7;
        endCol = col + 7;
        
        invYZigZag(row:endRow, col:endCol) = InverseZigZag(rleMatY(index, :), 8, 8);
        
        index = index + 1;
    end
end

index = 1;

%Inverse Zigzag trace each block for the Cb/Cr components
for row = 1:8:size(quantizedCb, 1)
    for col = 1:8:size(quantizedCb, 2)
        endRow = row + 7;
        endCol = col + 7;
        
        invCbZigZag(row:endRow, col:endCol) = InverseZigZag(rleMatCb(index, :), 8, 8);
        invCrZigZag(row:endRow, col:endCol) = InverseZigZag(rleMatCr(index, :), 8, 8);
        
        index = index + 1;
    end
end


%% Inverse Quantize

%Initialize the structs for inverse quantization
invyQuantStruct = @(block_struct) round(block_struct.data .* Luminance);
invcbCrQuantStruct = @(block_struct) round(block_struct.data .* Chrominance);

%Perform inverse quantization on the components
invquantizedY = blockproc(invYZigZag, [8 8], invyQuantStruct);
invquantizedCb = blockproc(invCbZigZag, [8 8], invcbCrQuantStruct);
invquantizedCr = blockproc(invCrZigZag, [8 8], invcbCrQuantStruct);


%% Inverse DCT

%Initialize the struct for inverse DCT
iDCT = @(block_struct) idct2(block_struct.data);

%Perform inverse DCT on the components
iDCTY = blockproc(invquantizedY, [8 8], iDCT);
iDCTCb = blockproc(invquantizedCb, [8 8], iDCT);
iDCTCr = blockproc(invquantizedCr, [8 8], iDCT);

% Round values
iDCTY=uint8(iDCTY);
iDCTCb=uint8(iDCTCb);
iDCTCr=uint8(iDCTCr);


%% Upsample using row column replication

up_resampler = vision.ChromaResampler();

up_resampler.Resampling = '4:2:2 to 4:4:4';
[Cb_resized_upsample, Cr_resized_upsample] = up_resampler(iDCTCb, iDCTCr);

YCbCr_linear = cat(3,iDCTY,Cb_resized_upsample,Cr_resized_upsample);


%% Convert to RGB 

intRgb = ycbcr2rgb(YCbCr_linear);


%% Display original and reconstructed images

figure, subplot(1,3,1), imshow(rgbImage), title({'Original Image'});
subplot(1,3,3), imshow(intRgb), title({'Reconstructed Image'});
