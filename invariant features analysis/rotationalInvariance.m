% % import all SIFT txt files to matlab
% txtfilefolder=fullfile(cd, '/SIFTdata'); % text file folder
% dirinfo = dir(txtfilefolder); % get list of current text file dirs
% dirinfo = dirinfo(~ismember({dirinfo.name},{'.','..'})); % remove matlab's . and .. entries in listing
% N = length(dirinfo);
% % map that stores egg name as key and sift data as value 
% egg_name_to_sift_data_map = containers.Map('KeyType','char','ValueType','any');
% 
% % Get corresponding clutch names for each egg
% for i=1:N
%     % remove hidden files in the MACOS system
%     if strcmp(dirinfo(i).name,'.DS_Store') == 1
%         continue;
%     end
%     filename = dirinfo(i).name; % filename, e.g. 2018_PS012_A2_in_PS049_stitched.TXT
%     filesplit=strsplit(filename,'_');
%     clutch_name(i) = filesplit(2);
%     egg_name(i) = filesplit(3);
%     filenames(i) = convertCharsToStrings(filename); % a list of all the filenames
%     egg_name_to_sift_data_map(filename) = readSIFTtxt(fullfile(dirinfo(i).folder,dirinfo(i).name)); % store SIFT data corresponding to filename
% end

%% previous work
% for i=1:N % for each text file do the following loop
%    % read text file
%     siftDataFull{i}=readSIFTtxt(fullfile(dirinfo(i).folder,dirinfo(i).name)); % this inputs
%     %txt files into a cell array (requires funcrion readSIFTtxt
% end 
% 
% %% A FINAL IDEA FOR INVARIANT FEATURES PROJECT
% %% Could convert orientations of each vector (4th dimension) to zero
% % method for converting the orientation dimension of each SIFT feature to 
% % a constant and then perhaps compare eggs within a clutch to see whether 
% % there is rotational invariance between but not within clutches.
% % This could test for rotational invariance within and between clutches
% %% now try with siftDataFull
% %this converts the 4th dimension of every SIFT vector to zero. i.e. gets
% %rid of variation in the orientation term.
% siftDataRotateZero=siftDataFull;
% % for i=1:N
% %     siftDataRotateZero{i}(:,4)=0;
% % end
% 
% %% Contributed by Kuan-Chi Chen
% % create feature similarity matrix 
% featSim = zeros(N,N);
% % for each egg
% % calculate the number of matching features with every other egg
% % similarity is quantified as the number of matching features
% % divided by the number of features of the current egg
% fprintf('checkpoint1\n');
% % fileID = fopen('featSim.txt','w');
% 
% % for i=1:N
% i = 1;
%     feat1 = siftDataRotateZero{i};
%     for j=i:N
%         feat2 = siftDataRotateZero{j};
%         [indexPairs,matchmetric] = matchFeatures(feat1,feat2);
%         featSim(i,j) = length(indexPairs) / length(feat1);
%         sim = length(indexPairs) / length(feat1);
% %         fprintf(fileID,'%f; ',sim);
%         fprintf('j: %d\n', j);
% %     fprintf(fileID,'\n');
%     fprintf('i: %d\n', i);
%     end
% % end
% fclose(fileID);
% fprintf('checkpoint2\n');
% 
% % store feature similarity matrix to csv file
% writematrix(featSim,'featSim.csv');

% %% Run mds
% % read feature similarity matrix from csv file
% featSim = readmatrix('featSim.csv');
% 
% 
% fprintf('checkpoint3\n');
% % invert the pairwise similarity
% featSim=1-featSim; 
% featSim(featSim==1)=0.9999;
% upper = triu(featSim, 1);
% flipUpper = upper';
% distance = upper + flipUpper;
% distance(logical(eye(size(distance)))) = 1; % fix the diagonal being 1 rather than 0 (a convention)
% fprintf('checkpoint4\n');
% % run mds, in this case with just 2 dimensions
% dimensions=2;
% opts = statset('MaxIter',100);
% Y=mdscale(distance,dimensions,'Options',opts);
% % Y=mdscale(distance,dimensions);
% fprintf('checkpoint5\n'); 
% %% try tsne
% rng('default') % for reproducibility
% % Y = tsne(distance,'Algorithm','exact','Distance','mahalanobis');
% subplot(2,2,1)
% gscatter(Y(:,1), Y(:,2),clutch_name', [], [], [], 'off')
% title('Mahalanobis')
% 
% rng('default') % for fair comparison
% Y = tsne(distance,'Algorithm','exact','Distance','cosine');
% subplot(2,2,2)
% gscatter(Y(:,1), Y(:,2),clutch_name', [], [], [], 'off')
% title('Cosine')
% 
% rng('default') % for fair comparison
% Y = tsne(distance,'Algorithm','exact','Distance','chebychev');
% subplot(2,2,3)
% gscatter(Y(:,1), Y(:,2),clutch_name', [], [], [], 'off')
% title('Chebychev')
% 
% rng('default') % for fair comparison
% Y = tsne(distance,'Algorithm','exact','Distance','euclidean');
% subplot(2,2,4)
% gscatter(Y(:,1), Y(:,2),clutch_name', [], [], [], 'off')
% title('Euclidean')
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_gscatter_tsne.jpg');
% fprintf('rot_gscatter_tsne\n');
% 
% %% plot mds
% % scatter(Y(:,1), Y(:,2)); % just scatter
% % subplot(2,1,1)
% gscatter(Y(:,1), Y(:,2),clutch_name', [], [], [], 'off'); % colour by clutches
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_gscatter_SIFTdata.jpg');
% fprintf('rot_gscatter_SIFTdata\n');
% % subplot(2,1,2)
% hold off;
% heatmap(featSim);
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_heatmap_SIFTdata.jpg');
% fprintf('rot_heatmap_SIFTdata\n');
% 
% %% Calculate inter/intra clutch variation
% % For each clutch we were then able to compute the centroid, 
% % which is simply given by the vectorial mean of all the points 
% % corresponding to all the eggs of a particular clutch in the MDS subspace.
% [G, TID] = findgroups(clutch_name');
% meanY(:,1) = splitapply(@mean,Y(:,1),G);
% meanY(:,2) = splitapply(@mean,Y(:,2),G);
% fprintf('checkpoint6\n');
% % We then computed the distances from that centroid over 
% % all the member points of that clutch. 
% % count = 1;
% % for i=1:length(meanY)
% %     groupNum = sum(G(:) == i);
% %     for j=count:count+groupNum-1
% %         X = [Y(j,:);meanY(i,:)];
% %         dist(j) = pdist(X);
% %     end
% %     count = count + groupNum;
% % end
% % meanDist = splitapply(@mean,dist',G);
% % intra = mean(meanDist);
% 
% dist = zeros(length(Y),1);
% for i=1:length(Y)
%     groupNum = G(i);
%     pair = [Y(i,:);meanY(groupNum,:)];
%     dist(i) = pdist(pair);
% end
% 
% fprintf('checkpoint7\n');
% % Intraclutch variation was quantified as the mean distance between 
% % the elements of the clutch and its centroid, 
% % averaged over all clutches for a particular species.     
% intra = mean(dist);
% % Interclutch variation was quantified as the mean of the distances between 
% % all the centroids of all the clutches for a particular species.
% centroidDist = pdist(meanY);
% inter = mean(centroidDist);
% interSimMatrix = squareform(centroidDist);
% heatmap(interSimMatrix);
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_heatmap_interSimMatrix.jpg');
% fprintf('rot_heatmap_interSimMatrix\n');
% 
% %% gaussian kernel pca------------------------------------------------------
% 
% figure
% hold on
% gscatter(Y(:, 1), Y(:, 2), clutch_name', [], [], [], 'off')
% % plot(Xtest(:, 1), Xtest(:, 2), 'LineStyle', 'none', 'Marker', '>')
% % legend(["X (class1)", "X (class2)", "X (class3)", "X (class4)", "Xtest"])
% title('original data')
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_kpca_scatter.jpg');
% fprintf('rot_kpca_scatter\n');
% 
% % fit pca model and get the coefficient for projection with dataset 'X'
% % setting 'AutoScale' true is reccomended (default:false)
% kpca = KernelPca(Y, 'gaussian', 'gamma', 2.5, 'AutoScale', true);
% 
% % set the subspace dimention number M of projected data
% % (M <= D, where D is the dimention of the original data)
% M = 2;
% 
% % project the train data 'X' into the subspace by using the coefficient
% projected_Y = project(kpca, Y, M);
% 
% % project the test data 'Xtest' as well
% % projected_Xtest = project(kpca, Xtest, M);
% 
% % plot
% figure
% hold on
% gscatter(projected_Y(:, 1), projected_Y(:, 2), clutch_name', [], [], [], 'off')
% % plot(projected_Xtest(:, 1), projected_Xtest(:, 2), 'LineStyle', 'none', 'Marker', '>')
% title('pca with gaussian kernel')
% xlabel('principal dim')
% ylabel('second dim')
% % legend(["projected X (class1)", "projected X (class2)", "projected X (class3)", "projected X (class4)", "projected Xtest"])
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_kpca_gaussian.jpg');
% fprintf('rot_kpca_gaussian\n');
% 
% %% Calculate inter/intra clutch variation
% % For each clutch we were then able to compute the centroid, 
% % which is simply given by the vectorial mean of all the points 
% % corresponding to all the eggs of a particular clutch in the MDS subspace.
% % [G, TID] = findgroups(clutch_name');
% % meanProjected_Y = splitapply(@mean,projected_Y,G);
% meanProjected_Y(:,1) = splitapply(@mean,projected_Y(:,1),G);
% meanProjected_Y(:,2) = splitapply(@mean,projected_Y(:,2),G);
% fprintf('checkpoint6\n');
% % We then computed the distances from that centroid over 
% % all the member points of that clutch. 
% % count = 1;
% % for i=1:length(meanProjected_Y)
% %     groupNum = sum(G(:) == i);
% %     for j=count:count+groupNum-1
% %         X = [projected_Y(j,:);meanProjected_Y(i,:)];
% %         dist(j) = pdist(X);
% %     end
% %     count = count + groupNum;
% % end
% % meanDist = splitapply(@mean,dist',G);
% % intraGaussian = mean(meanDist);
% 
% dist = zeros(length(projected_Y),1);
% for i=1:length(projected_Y)
%     groupNum = G(i);
%     pair = [projected_Y(i,:);meanProjected_Y(groupNum,:)];
%     dist(i) = pdist(pair);
% end
% 
% fprintf('checkpoint7\n');
% % Intraclutch variation was quantified as the mean distance between 
% % the elements of the clutch and its centroid, 
% % averaged over all clutches for a particular species.     
% intraGaussian = mean(dist);
% % Interclutch variation was quantified as the mean of the distances between 
% % all the centroids of all the clutches for a particular species.
% centroidDist = pdist(meanProjected_Y);
% interGaussian = mean(centroidDist);
% interSimMatrix = squareform(centroidDist);
% hold off;
% heatmap(interSimMatrix);
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_heatmap_gaussian.jpg');
% fprintf('rot_heatmap_gaussian\n');
% 
% %% make a linear kernel pca model
% % (The result is equal to normal pca, but the internal algorithm is 
% % different)
% linear_model = KernelPca(Y, 'linear');
% 
% % plot the contribution ratio
% figure
% hold on
% plot([1 2 3 4], linear_model.contribution_ratio(1:4), '-.<b')
% xlabel('dimention')
% ylabel('contribution ratio')
% title('contribution ratio of the linear kernel pca')
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_linear_cr.jpg');
% fprintf('rot_linear_cr\n');
% % threshold the max number of subspace dimention
% % by the accumulated contribution ratio
% th = 0.95;
% accumulated = cumsum(linear_model.contribution_ratio(1:4));
% for max_dim = 1:4
%     if accumulated(max_dim) > th
%         break;
%     end
% end
% 
% % make the model compact by releasing some unnecessary properties
% set_compact(linear_model, 'MaxDim', max_dim);
% 
% % project the data and plot
% projected = project(linear_model, Y, max_dim);
% figure
% gscatter(projected(:, 1), projected(:, 2), clutch_name', [], [], [], 'off')
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_linear.jpg');
% fprintf('rot_linear\n');
% 
% %% Calculate inter/intra clutch variation
% % For each clutch we were then able to compute the centroid, 
% % which is simply given by the vectorial mean of all the points 
% % corresponding to all the eggs of a particular clutch in the MDS subspace.
% % [G, TID] = findgroups(clutch_name');
% % meanProjected = splitapply(@mean,projected,G);
% meanProjected(:,1) = splitapply(@mean,projected(:,1),G);
% meanProjected(:,2) = splitapply(@mean,projected(:,2),G);
% fprintf('checkpoint6\n');
% % We then computed the distances from that centroid over 
% % all the member points of that clutch. 
% % count = 1;
% % for i=1:length(meanProjected)
% %     groupNum = sum(G(:) == i);
% %     for j=count:count+groupNum-1
% %         X = [projected(j,:);meanProjected(i,:)];
% %         dist(j) = pdist(X);
% %     end
% %     count = count + groupNum;
% % end
% % meanDist = splitapply(@mean,dist',G);
% % intraLinear = mean(meanDist);
% 
% dist = zeros(length(projected),1);
% for i=1:length(projected)
%     groupNum = G(i);
%     pair = [projected(i,:);meanProjected(groupNum,:)];
%     dist(i) = pdist(pair);
% end
% 
% fprintf('checkpoint7\n');
% % Intraclutch variation was quantified as the mean distance between 
% % the elements of the clutch and its centroid, 
% % averaged over all clutches for a particular species.     
% intraLinear = mean(dist);
% % Interclutch variation was quantified as the mean of the distances between 
% % all the centroids of all the clutches for a particular species.
% centroidDist = pdist(meanProjected);
% interLinear = mean(centroidDist);
% interSimMatrix = squareform(centroidDist);
% hold off;
% heatmap(interSimMatrix);
% saveas(gcf,'/Users/christine/Downloads/Tanmay_output/rot_heatmap_linear.jpg');
% fprintf('rot_heatmap_linear\n');

function y = randomSelectTwo(egg_names)
    if numel(egg_names)>2 % if the clutch has more than two eggs
        s = RandStream('dsfmt19937'); % set random seed
        y = reshape((egg_names(randperm(s, numel(egg_names), 2))),[1 2]); % randomly select two eggs
    else
        y = ["", ""]; % otherwise return empty strings
    end
end

function eggPairDifferenceHistogram = getDifferenceHistogram(eggPairs, egg_name_to_sift_datam_map, dim)
    for i = 1:numel(eggPairs(:,1)) % for each pair of eggs
        eggPair = eggPairs(i,:);
        % get the sift features for egg one and egg two in each pair of eggs
        sift_one = egg_name_to_sift_datam_map(eggPair(1));
        sift_two = egg_name_to_sift_datam_map(eggPair(2));
        % get the matched sift features
        indexPairs = matchFeatures(sift_one,sift_two);
        for j = 1:numel(indexPairs(:,1)) % for each pair of matched features
            indexPair = indexPairs(j,:);
            featureDifferences(j) = sift_one(indexPair(1), dim) - sift_two(indexPair(2), dim); % difference between two sift features at the specified dimension
        end
        if numel(indexPairs) == 0
            meanFeatureDifferences(i) = 0;
        else
            meanFeatureDifferences(i) = mean(featureDifferences); % mean of all the matched sift feature differences
        end
    end
    eggPairDifferenceHistogram = meanFeatureDifferences;
end

% especially for orientational dimension 
% the same as above function except that we take absolute difference
% between the angles and modify the value if it is greater than pi
function eggPairDifferenceHistogram = getOrientalDifferenceHistogram(eggPairs, egg_name_to_sift_datam_map)
    for i = 1:numel(eggPairs(:,1)) % for each pair of eggs
        eggPair = eggPairs(i,:);
        % get the sift features for egg one and egg two in each pair of eggs
        sift_one = egg_name_to_sift_datam_map(eggPair(1));
        sift_two = egg_name_to_sift_datam_map(eggPair(2));
        % get the matched sift features
        indexPairs = matchFeatures(sift_one,sift_two);
        for j = 1:numel(indexPairs(:,1)) % for each pair of matched features
            indexPair = indexPairs(j,:);
            angleAbsDiff = abs(sift_one(indexPair(1), 4)) - abs(sift_two(indexPair(2), 4)); % absolute difference between two sift features at the orientational dimension
            if angleAbsDiff>pi % if the difference is larger than pi
                featureDifferences(j) = 2*pi - angleAbsDiff; % adjust the angle difference
            else
                featureDifferences(j) = angleAbsDiff;
            end
        end
        if numel(indexPairs) == 0
            meanFeatureDifferences(i) = 0;
        else
            meanFeatureDifferences(i) = mean(featureDifferences); % mean of all the matched sift feature differences
        end
    end
    eggPairDifferenceHistogram = meanFeatureDifferences;
end

