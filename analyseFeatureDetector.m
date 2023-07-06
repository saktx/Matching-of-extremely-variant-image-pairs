
function [Repeatability, Correspondences, k1_projected_on_I2, k2_projected_on_I1] = analyseFeatureDetector(I1,I2,k1,k2,HOMOGRAPHY,TOLERANCE)

% TOLERANCE = 1; % Tolerance = 1 (in pixels)

cols1 = size(I1,2);
rows1 = size(I1,1);

cols2 = size(I2,2);
rows2 = size(I2,1);

k1_projected_on_I2 = k1;
k2_projected_on_I1 = k2;

Inv_HOMOGRAPHY = inv(HOMOGRAPHY);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

points1 = ones(length(k1),3);
points2 = ones(length(k2),3);

for i=1:length(k1)
    points1(i,1) = k1(i).pt(1);
    points1(i,2) = k1(i).pt(2);
end

for i=1:length(k2)
    points2(i,1) = k2(i).pt(1);
    points2(i,2) = k2(i).pt(2);
end

points1 = transpose(points1);
points2 = transpose(points2);

var = size(points1);
for i=1:var(2) % i=1:length(points1)
    pt_vector = HOMOGRAPHY * points1(:,i);
    pt_vector = pt_vector./pt_vector(3);    % Normalization
    
    k1_projected_on_I2(i).pt(1) = pt_vector(1);
    k1_projected_on_I2(i).pt(2) = pt_vector(2);
end

var = size(points2);
for i=1:var(2)     % i=1:length(points2)
    pt_vector = Inv_HOMOGRAPHY * points2(:,i);
    pt_vector = pt_vector./pt_vector(3);    % Normalization
    
    k2_projected_on_I1(i).pt(1) = pt_vector(1);
    k2_projected_on_I1(i).pt(2) = pt_vector(2);
end


%{
out = cv.drawKeypoints(I1, k1, 'Color',[0,255,0]); % overlay detected keypoints on the image
figure, imshow(out);

out = cv.drawKeypoints(I1, k2_projected_on_I1, 'Color',[0,255,0]); % overlay detected keypoints on the image
figure, imshow(out);

out = cv.drawKeypoints(I2, k2, 'Color',[0,255,0]); % overlay detected keypoints on the image
figure, imshow(out);

out = cv.drawKeypoints(I2, k1_projected_on_I2, 'Color',[0,255,0]); % overlay detected keypoints on the image
figure, imshow(out);
%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_1 = logical(ones(1,length(k1))');
counter_1 = 0;
for i=1:length(k1_projected_on_I2)
   if (k1_projected_on_I2(i).pt(1) > cols2) || (k1_projected_on_I2(i).pt(2) > rows2) || (k1_projected_on_I2(i).pt(1) < 1) || (k1_projected_on_I2(i).pt(2) < 1)
       counter_1 = counter_1 + 1;
       idx_1(i) = 0;
   end
end
k1_projected_on_I2 = k1_projected_on_I2(idx_1);


idx_2 = logical(ones(1,length(k2))');
counter_2 = 0;
for i=1:length(k2_projected_on_I1)
   if (k2_projected_on_I1(i).pt(1) > cols1) ||  (k2_projected_on_I1(i).pt(2) > rows1) || (k2_projected_on_I1(i).pt(1) < 1) ||  (k2_projected_on_I1(i).pt(2) < 1)
       counter_2 = counter_2 + 1;
       idx_2(i) = 0;
   end
end
k2_projected_on_I1 = k2_projected_on_I1(idx_2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%% Points Common in Overlapping Region of I1 and I2  %%%%%%%%%%%%%%%%%%%%%%%%
%

idx_1 = logical(zeros(1,length(k1_projected_on_I2))');
idx_2 = logical(zeros(1,length(k2))');
counter = 0;

for i=1:length(k2)
     ptsScene = k2(i).pt;
     
     for j=1:length(k1_projected_on_I2)
            
            pts_right = k1_projected_on_I2(j).pt;
            
            euclidean_distance = sqrt((ptsScene(1)-pts_right(1))^2 + (ptsScene(2)-pts_right(2))^2);

            if (euclidean_distance < TOLERANCE) && (idx_2(i)~= 1) && (idx_1(j)~= 1)
                idx_1(j) = 1;
                idx_2(i) = 1;
                counter = counter + 1;
            end
            
    end
end

ids_1 = find(idx_1);
ids_2 = find(idx_2);

% k2_projected_on_I1 is the no. of points detected in Image-2 after the
% geometrical transformation of Image-1 (i.e. these points are detected in Image-2, inside the overlapping region of both images )

% Points detected in Image-1 inside the overlapping region of Image-1 and
% Image-2 are not considered in calculation of repeatability

%Repeatability = counter / min(length(k2_projected_on_I1),length(k1_projected_on_I2));

Repeatability = counter / length(k1_projected_on_I2);   % Consider Image-A features
Correspondences = counter;

end


