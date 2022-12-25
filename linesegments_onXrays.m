
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following source code is based on the papers, we have published.
% K. C. Santosh, Sema Candemir, Stefan Jäger, Alexandros Karargyris, Sameer K. Antani, George R. Thoma, Les Folio:
% Automatically Detecting Rotation in Chest Radiographs Using Principal Rib-Orientation Measure for Quality Control. 
% Int. J. of Patt. Reco. & Art. Intell. 29(2) (2015)
%
% Sema Candemir, Eugene Borovikov, K. C. Santosh, Sameer K. Antani, George R. Thoma:
% RSILC: Rotation- and Scale-Invariant, Line-based Color-aware descriptor. 
% Image Vision Comput. 42: 1-12 (2015)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Important notice:
% This code is just a prototype, and helps you understand the "CONVOLUTION"
% process.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function linesegments_onXrays


%% start

%% Clear workspace and Variables
clc; % Clear command window.
clear all; % Delete all variables.
close all; % Close all figure windows except those created by imtool.
imtool close all; % Close all figure windows created by imtool.
workspace; % Make sure the workspace panel is showing.


%% Read Images
%  Directory path and Extension of files to read
inputDir = 'imageXray'; 
inputDirsegment = 'lungXray';
imgExt = '.png' ;

directory = [pwd filesep inputDir] ;
Images = dir([directory filesep '*' imgExt]); % get all images in Directory with  defined ext

% directory for lung segments
directory1 = [pwd filesep inputDirsegment]; % Full file path for lung segments

%% output dir
mkdir('lineOutput');


for N = 1:length(Images) % Number of images in directory
    
    file1 = [directory filesep Images(N).name]; % Full file path
    [pathstr,fname,ext] = fileparts(file1); % Separate Path, filename and ext
   
   
    %% read Images
    Img = imread(file1);

    %% resize the image (make it small - to speed up)
    imgRatio = 0.25;
    Img = imresize(Img,imgRatio,'bilinear');
    
    %% corresponding lung segments
    file2 = [directory1 filesep strcat(fname, '_mask', ext)]; % Full file path
    SegmentMask = imread(file2);
    SegmentMask = imresize(SegmentMask, [size(Img,1) size(Img,2)],'bilinear'); 
    
    
    %% visualization
    
    figure(1), imshow(Img);
   
    %% pre-processing: histogram equalization
    Img = histeq(Img);
   figure(2), imshow(Img); 
    
    
    
    %% apply canny edge detection
    Img_edge = edge(Img,'canny',0.1);
    figure(3), imshow(Img_edge);
    
    %% directional filters
    filters = CreateFilters(); % call it from outside.
    
    
    %% Convolution
    LineImg = ApplyFilters(Img_edge,filters);
    figure(4), imshow(LineImg.deg_0);
    
    
    %% take the region inside the segment Mask
    for column = 1:size(Img,1)
        for row = 1:size(Img,2)
            if(SegmentMask(column,row)== 0)
                LineImg.deg_0(column,row) = 0;
                LineImg.deg_30(column,row) = 0;
                LineImg.deg_60(column,row) = 0;
                LineImg.deg_90(column,row) = 0;
                LineImg.deg_120(column,row) = 0;
                LineImg.deg_150(column,row) = 0;
            end
        end
    end
    figure(5), imshow(LineImg.deg_0);
    
    %% refine the Line image according to line direction
    threshold = 10;
    LineImg.deg_0 = refineLineImg(LineImg.deg_0,threshold);
    LineImg.deg_30 = refineLineImg(LineImg.deg_30,threshold);
    LineImg.deg_60 = refineLineImg(LineImg.deg_60,threshold);
    LineImg.deg_90 = refineLineImg(LineImg.deg_90,threshold);
    LineImg.deg_120 = refineLineImg(LineImg.deg_120,threshold);
    LineImg.deg_150 = refineLineImg(LineImg.deg_150,threshold);
    
    figure(6), imshow(LineImg.deg_0);
    
    
    %% make those line segments a bit bold; 
    se = strel('disk', 3);
    LineImg.deg_0 = imdilate(LineImg.deg_0, se);
    LineImg.deg_30 = imdilate(LineImg.deg_30, se);
    LineImg.deg_60 = imdilate(LineImg.deg_60, se);
    LineImg.deg_90 = imdilate(LineImg.deg_90, se);
    LineImg.deg_120 = imdilate(LineImg.deg_120, se);
    LineImg.deg_150 = imdilate(LineImg.deg_150, se);
    
    figure(7), imshow(LineImg.deg_0);
    
    
    %% saving them (png files).
    FilterNames = fieldnames(filters);
    
    for filter_cnt = 1:length(FilterNames)
        Output_Img = getfield(LineImg,FilterNames{filter_cnt});
        fname_withPath = sprintf('lineOutput/%s_%s.png',fname,FilterNames{filter_cnt});
        imwrite(Output_Img,fname_withPath,'png')
    end
    
end
end





function LineImg = refineLineImg(LineImg,threshold)

[L n] = bwlabel(LineImg,8);

for i = 1:n
    [r,c] = find(L == i);
    
    if(min(c) ~= max(c))
        [minval.c index] = min(c); minval.r = r(index);
        [maxval.c index] = max(c); maxval.r = r(index);
    else
        [minval.r index] = min(r); minval.c = c(index);
        [maxval.r index] = max(r); maxval.c = c(index);
    end
    
    line_lngth = sqrt((maxval.r-minval.r)^2 + (maxval.c-minval.c)^2);
    
    if(line_lngth < threshold)
        for ii = 1:length(r)
            LineImg(r(ii),c(ii))=0;
        end
    end
    
end
end

