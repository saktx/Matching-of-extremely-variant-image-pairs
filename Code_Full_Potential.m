close all
clear
clc
TOLERANCE = 2.5;

%%% IMAGE PAIR SELECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image_pair = choose_IMAGE_PAIR;

switch (image_pair)
    case 'DUSTY'
        I1 = imread('dusty1.bmp');
        I2 = imread('dusty2.bmp');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
    case 'SMOKY'
        I1 = imread('smoky1.bmp');
        I2 = imread('smoky2.bmp');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
    case 'DARK'
        I1 = imread('dark1.png');
        I2 = imread('dark2.png');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
    case 'NOISY'
        I1 = imread('noisy1.png');
        I2 = imread('noisy2.png');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
        
    case 'MOTION BLURRED'        
        I1 = imread('motionblur1.ppm');
        I2 = imread('motionblur2.ppm');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
    case 'EXTREMELY AFFINE'
        I1 = imread('affine1.ppm');
        I2 = imread('affine2.ppm');
        HOMOGRAPHY = [0.4271459000000 -0.6718176500000 453.6153400000000; 0.4410657900000 1.0133230000000 -46.5345690000000; 0.0005188771200 -0.0000788537310 1.0000];
        
    case 'JPEG COMPRESSED'        
        I1 = imread('compressed1.ppm');
        I2 = imread('compressed2.ppm');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
    case 'OCCLUDED'
        I1 = imread('occluded1.png');
        I2 = imread('occluded2.png');        
        HOMOGRAPHY = [0.4283 -0.1864 121.5736; 0.0022 0.3643 162.5073; -0.0002 -0.0005 1.0000]; % Occluded box

    case 'SUNNY-SHADOWED'
        I1 = imread('shadowed1.png');
        I2 = imread('shadowed2.png');       
        HOMOGRAPHY = [1.053420623891425 -0.050886178539287 15.127976936616541; 0.115994601178657 0.975842021431132 -21.774727664763439; 0.000209780726126 -0.000163633763307 1.0000];

    case 'DECORATED'
        I1 = imread('decorated1.png');
        I2 = imread('decorated2.png');
        HOMOGRAPHY = [1 0 0; 0 1 0; 0 0 1];
                
end

figure('units','normalized','outerposition',[0.125 0.125 0.75 0.75]),
subplot(1,2,1); imshow(I1); title('Reference Image'); subplot(1,2,2); imshow(I2); title('Test Image');
pause(1)
%%% SELECTION OF FEATURE DETECTOR & FEATURE DESCRIPTOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feature_detector = choose_DETECTOR_DESCRIPTOR;

switch (feature_detector)
    case 'SIFT'
        detector = cv.SIFT('NOctaveLayers',4,'ConstrastThreshold',1e-9,'EdgeThreshold',100,'Sigma',0.5);
        descriptor = detector;
        
    case 'SURF'
        detector = cv.SURF('NOctaveLayers',4,'HessianThreshold', 1e-9);
        descriptor = detector;
        
    case 'KAZE'
        detector = cv.KAZE('NOctaveLayers',4,'Threshold',1e-9);
        descriptor = detector;
        
    case 'AKAZE'
        detector = cv.AKAZE('NOctaveLayers',4,'DescriptorType','MLDB','Threshold',1e-9); % BEST AKAZE with KAZE descriptor, MLDB fails (default: 0.001) 61 byte Descriptor
        descriptor = detector;
       
    case 'ORB'
        detector = cv.ORB('MaxFeatures',500000,'FastThreshold',1);
        descriptor = detector;
        
    case 'BRISK'
        detector = cv.BRISK('Octaves',4,'Threshold',1);
        descriptor = detector;
        
    case 'AGAST'
        k1 = cv.AGAST(rgb2gray(I1),'Type','AGAST_7_12d','NonmaxSuppression',false,'Threshold',1);
        k2 = cv.AGAST(rgb2gray(I2),'Type','AGAST_7_12d','NonmaxSuppression',false,'Threshold',1);
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'FAST'
        k1 = cv.FAST(rgb2gray(I1),'NonmaxSuppression',false,'Threshold',1);
        k2 = cv.FAST(rgb2gray(I2),'NonmaxSuppression',false,'Threshold',1);
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'MSER'
        detector = cv.MSER('MaxEvolution',10000,'EdgeBlurSize',3);
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'MSD'
        detector = cv.MSDDetector('ThSaliency',1,'NMSRadius',0,'ComputeOrientation', true, 'NScales', 3);
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'GFTT'
        detector = cv.GFTTDetector('MinDistance',0.1,'MaxFeatures', 500000,'QualityLevel', 0.000001); % Shi-Tomasi Corners
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'GFTT-H'
        detector = cv.GFTTDetector('HarrisDetector',true,'K',0.001,'MaxFeatures', 500000,'QualityLevel', 0.000001); % ISSUE
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
    case 'HARRIS-L'
        detector = cv.HarrisLaplaceFeatureDetector('CornThresh',0.000001,'DOGThresh',0.000001,'MaxCorners',500000); % Harris Laplace Detector
        descriptor = cv.SIFT();
        
    case 'CenSurE'
        detector = cv.StarDetector('ResponseThreshold',0.001,'LineThresholdProjected',50,'LineThresholdBinarized',50,'SuppressNonmaxSize',0); % CenSurE
        descriptor = cv.SIFT(); % SIFT Descriptor for all Detectors which don't have their own Feature Description Algorithm
        
end

%%% FEATURE DETECTION (Detection of Key-Points)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Detect key-points in case of Any Detector Other than AGAST, FAST, and MSER
if (strcmp(feature_detector,'AGAST') ~= 1 && strcmp(feature_detector,'FAST') ~= 1 && strcmp(feature_detector,'MSER') ~= 1)
    k1 = detector.detect(I1);
    [~,ind] = unique(cat(1, k1.pt),'rows'); % select only UNIQUE Keypoints without repetition (Unique w.r.t location)
    k1 = k1(ind);

    k2 = detector.detect(I2);
    [~,ind] = unique(cat(1, k2.pt),'rows'); % select only UNIQUE Keypoints without repetition (Unique w.r.t location)
    k2 = k2(ind);
end

%%% Detect key-points in case of MSER detector (Here we are extracting unique Pixels from the detected MSER Regions)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (strcmp(feature_detector,'MSER') == 1)
    [MSERregions1, ~] = detector.detectRegions(I1);
    [MSERregions2, ~] = detector.detectRegions(I2);

    load('keypoint.mat');
    counter = 0;
    mask = 0 * I1(:,:,1);
    for i=1:length(MSERregions1)
        for j=1:length(MSERregions1{i})
            if (mask(MSERregions1{i}(j,2)+1,MSERregions1{i}(j,1)+1) < 1)
                counter = counter + 1;
                mask(MSERregions1{i}(j,2)+1,MSERregions1{i}(j,1)+1) = 1;
                keypoint(counter).pt = [(MSERregions1{i}(j,1)+1) (MSERregions1{i}(j,2)+1)];

                if (counter > 1)
                    keypoint(counter).size = keypoint(1).size;
                    keypoint(counter).angle = keypoint(1).angle;
                    keypoint(counter).response = keypoint(1).response;
                    keypoint(counter).octave = keypoint(1).octave;
                    keypoint(counter).class_id = keypoint(1).class_id;
                end
            end
        end
    end

    k1 = keypoint;  % key-points in image-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('keypoint.mat');
    counter = 0;
    mask = 0 * I1(:,:,1);
    for i=1:length(MSERregions2)
        for j=1:length(MSERregions2{i})
            if (mask(MSERregions2{i}(j,2)+1,MSERregions2{i}(j,1)+1) < 1)
                counter = counter + 1;
                mask(MSERregions2{i}(j,2)+1,MSERregions2{i}(j,1)+1) = 1;
                keypoint(counter).pt = [(MSERregions2{i}(j,1)+1) (MSERregions2{i}(j,2)+1)];

                if (counter > 1)
                    keypoint(counter).size = keypoint(1).size;
                    keypoint(counter).angle = keypoint(1).angle;
                    keypoint(counter).response = keypoint(1).response;
                    keypoint(counter).octave = keypoint(1).octave;
                    keypoint(counter).class_id = keypoint(1).class_id;
                end
            end
        end
    end

    k2 = keypoint; % key-points in image-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

out1 = cv.drawKeypoints(I1, k1, 'Color', [0 255 0]);
out2 = cv.drawKeypoints(I2, k2, 'Color', [255 0 0]);
%%% Display the detected key-points
figure('units','normalized','outerposition',[0.125 0.125 0.75 0.75]),
subplot(1,2,1); imshow(out1); title('Key-Points in Reference Image'); subplot(1,2,2); imshow(out2); title('Key-Points in Test Image');
pause(1)

%%% CHECK REPEATABILITY OF THE DETECTOR (Takes Long Time)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [Repeatability, Correspondences, k1_projected_on_I2, k2_projected_on_I1] = analyseFeatureDetector(I1,I2,k1,k2,HOMOGRAPHY,TOLERANCE);

%%% KEY-POINTS DESCRIPTION (Description of the Key-Points detected in previous step)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[descriptors1, k1] = descriptor.compute(I1, k1);
[descriptors2, k2] = descriptor.compute(I2, k2);
descriptor_type = descriptor.descriptorType();

%%% DESCRIPTOR MATCHING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold_ratio = 0.9;  % NNDR Threshold Ratio (Threshold Ratio = 0.9 as per our Research Paper)
[ptsObj, ptsScene] = flannNNDRBasedMatching(k1,k2,descriptors1,descriptors2,descriptor_type, threshold_ratio);
%%% The above function "flannNNDRBasedMatching" applies K-D Tree based method for String based Descriptors (SIFT, SURF, KAZE)
%%% and Multi-Probe LSH Method for Binary Descriptors (AKAZE, ORB, BRISK)

%%% OUTLIER REJECTION by Ground Truth HOMOGRAPHY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

euclidean_distance = zeros(1,length(ptsObj));
inliers = logical(zeros(length(ptsObj),1));

for i=1:length(ptsObj)
    pts_left = transpose(ptsObj(i,:));
    pts_left = cat(1,pts_left,1);
    pts_right = HOMOGRAPHY*pts_left;
    pts_right = pts_right./pts_right(3); % Normalization
    
    euclidean_distance(i) = sqrt((ptsScene(i,1)-pts_right(1))^2 + (ptsScene(i,2)-pts_right(2))^2);
    
    if euclidean_distance(i) < TOLERANCE
        inliers(i)=1;
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Features_1 = numel(k1)
Features_2 = numel(k2)
Total_matches = numel(ptsObj(:,1))
Correct_Matches = sum(inliers)
%Correspondences = Correspondences      %(Found by REPEATABILITY CHECK)

%%% Display Matched Corresponding Points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imgObj = I1;
imgScene = I2;

s=1; k=1;
[spot,null,s] = find(inliers);        % i is the number of inlier point

xyobj = [];
xyimg = [];

fx = size(inliers);
fx=fx(1);
for i = 1:fx(1)

    if inliers(i)==1  % REMOVAL of OUTLIERS detected by RANSAC
        xyobj(k,1) = ptsObj(i,1);
        xyobj(k,2) = ptsObj(i,2);
        xyimg(k,1) = ptsScene(i,1);
        xyimg(k,2) = ptsScene(i,2);
        k=k+1;    
    end
end

figure('units','normalized','outerposition',[0.125 0.125 0.75 0.75]),
showMatchedFeatures(imgObj,imgScene,xyobj,xyimg,'montage','PlotOptions',{'go','ro','y-'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CODE END HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function choice = choose_IMAGE_PAIR

    d = dialog('Position',[675 400 250 150],'Name','Select One');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Select an Image Pair:');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'DUSTY';'SMOKY';'DARK';'NOISY';'MOTION BLURRED';'EXTREMELY AFFINE';'JPEG COMPRESSED';'OCCLUDED';'SUNNY-SHADOWED';'DECORATED'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Select',...
           'Callback','delete(gcf)');
       
    choice = 'DUSTY';
       
    % Wait for d to close before running to completion
    uiwait(d);
   
       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          choice = char(popup_items(idx,:));
       end
end


function choice = choose_DETECTOR_DESCRIPTOR

    d = dialog('Position',[675 400 250 150],'Name','Select One');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String','Select a Detector:');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[75 70 100 25],...
           'String',{'SIFT';'SURF';'KAZE';'AKAZE';'ORB';'BRISK';'AGAST';'FAST';'MSER';'MSD';'GFTT';'GFTT-H';'HARRIS-L';'CenSurE'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Select',...
           'Callback','delete(gcf)');
       
    choice = 'SIFT';
       
    % Wait for d to close before running to completion
    uiwait(d);
   
       function popup_callback(popup,event)
          idx = popup.Value;
          popup_items = popup.String;
          choice = char(popup_items(idx,:));
       end
end


