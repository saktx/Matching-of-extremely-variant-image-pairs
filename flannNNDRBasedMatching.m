function [ptsObj, ptsScene] = flannNNDRBasedMatching(k1,k2,d1,d2,descriptor_type,threshold_ratio)
    
    binary = strcmp(descriptor_type,'uint8');
    if binary == 0
        matcher = cv.DescriptorMatcher('FlannBasedMatcher', 'Index',{'KDTree','Trees',4}, 'Search',{'Checks',32}); % GOOD VALUES of Trees BETWEEN 1 to 16, (Parallel Search) for String based descriptors
        %matcher = cv.DescriptorMatcher('FlannBasedMatcher', 'Index',{'KDTree','Trees',12}); % BEST VALUES of Trees BETWEEN 1 to 16, (Parallel Search) for String based descriptors
        %matcher = cv.DescriptorMatcher('FlannBasedMatcher', 'Index',{'KMeans','Iterations',3}); % BEST VALUES of Trees BETWEEN 1 to 16, (Parallel Search) for String based descriptors
        %matcher = cv.DescriptorMatcher('FlannBasedMatcher', 'Index',{'HierarchicalClustering','Trees',6,'LeafSize',15}); % BEST VALUES of Trees BETWEEN 1 to 16, (Parallel Search) for String based descriptors

    else
        matcher = cv.DescriptorMatcher('FlannBasedMatcher','Index',{'LSH', 'TableNumber',6, 'KeySize',15, 'MultiProbeLevel',1}, 'Search',{'Checks',32}); % For Binary Descriptors
        %matcher = cv.DescriptorMatcher('FlannBasedMatcher','Index',{'LSH','TableNumber',6, 'KeySize',15, 'MultiProbeLevel',2}); % BEST RESULTS ORB Descriptors (not AKAZE and BRISK)
        %matcher = cv.DescriptorMatcher('FlannBased');
    end
    
    matches = matcher.knnMatch(d1, d2, 2);
    
    % rejecting matches which don't have two neighbors
    ids = logical(zeros(1,numel(matches)));
    if binary == 1
        for i = 1:numel(matches)
            flag = size(matches{i},2);
            if flag==2
                ids(i)=1;
            end
        end
        matches = matches(ids);
    end
    
    idx = cellfun(@(m) m(1).distance < threshold_ratio * m(2).distance, matches);   % As done in D. Lowe's Paper
    m = cellfun(@(m) m(1), matches(idx));

    if (isempty(m) == 0)
        ptsObj = cat(1, k1([m.queryIdx]+1).pt);   % queryIdx: index of query descriptors in image 1
        ptsScene = cat(1, k2([m.trainIdx]+1).pt); % trainIdx: index of train descriptors in image 2
    else
        ptsObj = double.empty;
        ptsScene = double.empty;
    end
end