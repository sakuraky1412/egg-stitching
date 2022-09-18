%% Run mds
% read feature similarity matrix from csv file
featSim = readmatrix('featSim.csv');

% Get corresponding clutch names for each egg
for i=1:N 
    filename = dirinfo(i).name; 
    filesplit=strsplit(filename,'_');
    clutch_name(i) = filesplit(2);
    egg_name(i) = filesplit(3);
end 
fprintf('checkpoint3\n');
% invert the pairwise similarity
featSim=1-featSim; 
featSim(featSim==1)=0.9999;
upper = triu(featSim, 1);
flipUpper = upper';
distance = upper + flipUpper;
distance(logical(eye(size(distance)))) = 1; % fix the diagonal being 1 rather than 0 (a convention)
fprintf('checkpoint4\n');
% run mds, in this case with just 2 dimensions
dimensions=2;
Y=mdscale(distance,dimensions);
fprintf('checkpoint5\n'); 
% plot mds
% scatter(Y(:,1), Y(:,2)); % just scatter
subplot(2,1,1)
gscatter(Y(:,1), Y(:,2),clutch_name'); % colour by clutches
subplot(2,1,2)
heatmap(data)
saveas(gcf,'012003_rot_gscatter_SIFTdata.jpg');
fprintf('rot_gscatter_SIFTdata\n');
% For each clutch we were then able to compute the centroid, 
% which is simply given by the vectorial mean of all the points 
% corresponding to all the eggs of a particular clutch in the MDS subspace.
[G, TID] = findgroups(clutch_name');
meanY = splitapply(@mean,Y,G);
fprintf('checkpoint6\n');
% We then computed the distances from that centroid over 
% all the member points of that clutch. 
count = 1;
for i=1:length(meanY)
    groupNum = sum(G(:) == i);
    for j=count:count+groupNum-1
        X = [Y(j,:);meanY(i,:)];
        dist(j) = pdist(X);
    end
    count = count + groupNum;
end
fprintf('checkpoint7\n');
% Intraclutch variation was quantified as the mean distance between 
% the elements of the clutch and its centroid, 
% averaged over all clutches for a particular species.     
meanDist = splitapply(@mean,dist',G);
intra = mean(meanDist);
% Interclutch variation was quantified as the mean of the distances between 
% all the centroids of all the clutches for a particular species.
centroidDist = pdist(meanY);
inter = mean(centroidDist);
interSimMatrix = squareform(centroidDist);
heatmap(interSimMatrix);
saveas(gcf,'012003_rot_heatmap_SIFTdata.jpg');
fprintf('rot_heatmap_SIFTdata\n');
