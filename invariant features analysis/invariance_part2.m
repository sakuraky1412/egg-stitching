% Calculate the mean (absolute) difference in orientation 
% between pairs of matched features in each host egg and 
% the experimental egg.
%% read the table to get host nests, exp nests, host egg removed
% and the experience egg
A = readtable( 'PSexperimentscomplete_forKuanChi.csv' );
% HostNest = A.HostNest;
% ExpNest = A.ExpNest;
% ExpEggReceived = A.ExpEggReceived;
% HostEggRemoved = A.HostEggRemoved;
% Year = A.Year;
underscore = {'_'};
in = {'in'};
postfix = {'_stitched.TXT'};
host_cluster_names = strcat(num2str(A.Year), underscore, A.HostNest);
host_egg_removed_filenames = strcat(num2str(A.Year), underscore, A.HostNest, underscore, A.HostEggRemoved, postfix);
experience_egg_filenames = strcat(num2str(A.Year), underscore, A.ExpNest, underscore, A.ExpEggReceived, underscore, in, underscore, A.HostNest, postfix);

%% import all SIFT txt files to matlab
txtfilefolder=fullfile(cd, '/SIFTdata'); % text file folder
dirinfo = dir(txtfilefolder); % get list of current text file dirs
dirinfo = dirinfo(~ismember({dirinfo.name},{'.','..'})); % remove matlab's . and .. entries in listing
N = length(dirinfo);
fprintf('read sift data\n');
%% Get corresponding clutch names for each egg
% map that stores egg name as key and sift data as value 
egg_name_to_sift_data_map = containers.Map('KeyType','char','ValueType','any');
clutch_names_without_in=[];
filenames_without_in=[];
for i=1:N
    % remove hidden files in the MACOS system
    if strcmp(dirinfo(i).name,'.DS_Store') == 1
        continue;
    end
    filename = dirinfo(i).name; % filename, e.g. 2018_PS012_A2_in_PS049_stitched.TXT
    filesplit=strsplit(filename,'_');
    egg_name_to_sift_data_map(filename) = readSIFTtxt(fullfile(dirinfo(i).folder,dirinfo(i).name)); % store SIFT data corresponding to filename
    if isempty( regexp( filename, '_in_' )  )
        clutch_names_without_in = [clutch_names_without_in, strcat(filesplit(1),'_',filesplit(2))];
        filenames_without_in = [filenames_without_in,convertCharsToStrings(filename)];
    end
end
fprintf('read egg data\n');

clutch_name_to_egg_names = containers.Map('KeyType','char','ValueType','any');
% For each clutch
for i = 1:numel(filenames_without_in)
    current_filename = filenames_without_in(i);
    filename_split=strsplit(current_filename,'_');
    current_clutch_name = strcat(filename_split(1),'_',filename_split(2));
    if isKey(clutch_name_to_egg_names, current_clutch_name)
        clutch_name_to_egg_names(current_clutch_name) = [clutch_name_to_egg_names(current_clutch_name), current_filename];
    else 
        clutch_name_to_egg_names(current_clutch_name) = [current_filename];
    end
% Find eggs of the clutch
    
% Match features with the excluded egg

% Calculate two differences

% For each clutch, mean difference
end

for i = 1:numel(host_cluster_names)
    clutch = clutch_name_to_egg_names(char(host_cluster_names(i)));
    removed_host_egg = host_egg_removed_filenames(i);
    experience_egg = experience_egg_filenames(i);
    clutch_without_removed_host_egg = setdiff(clutch, removed_host_egg); 
    for j = 1:numel(clutch_without_removed_host_egg)
        eggPairs(j, :) = [experience_egg, clutch_without_removed_host_egg(j)];
    end
    sprintf('calculating cluster: %f \n', i);
    positionHistogram = getDifferenceHistogram(eggPairs, egg_name_to_sift_data_map, 1);
    meanClutchDifference(1, i) = mean(positionHistogram);
    scaleHistogram = getDifferenceHistogram(eggPairs, egg_name_to_sift_data_map, 3);
    meanClutchDifference(3, i) = mean(scaleHistogram);
    orientalHistogram = getOrientalDifferenceHistogram(eggPairs, egg_name_to_sift_data_map);
    meanClutchDifference(5, i) = mean(orientalHistogram);

    eggPair = string({experience_egg, removed_host_egg;});
    positionDiff = getDifferenceHistogram(eggPair, egg_name_to_sift_data_map, 1);
    meanClutchDifference(2, i) = mean([positionHistogram, positionDiff]);
    scaleDiff = getDifferenceHistogram(eggPair, egg_name_to_sift_data_map, 3);
    meanClutchDifference(4, i) = mean([scaleHistogram, scaleDiff]);
    orientalDiff = getOrientalDifferenceHistogram(eggPair, egg_name_to_sift_data_map);
    meanClutchDifference(6, i) = mean([orientalHistogram, orientalDiff]);
end

%% write results to csv files
writematrix(meanClutchDifference','meanClutchDifference.csv') 
fprintf('write histograms\n');

%% functions
function eggPairDifferenceHistogram = getDifferenceHistogram(eggPairs, egg_name_to_sift_data_map, dim)
    for i = 1:numel(eggPairs(:,1)) % for each pair of eggs
        eggPair = eggPairs(i,:);
        % get the sift features for egg one and egg two in each pair of eggs
        if isKey(egg_name_to_sift_data_map, eggPair(1))
            sift_one = egg_name_to_sift_data_map(eggPair(1));
        else
            fprintf('cannot find egg sift features: ');
            disp(eggPair(1));
            meanFeatureDifferences(i) = 0;
            continue
        end
        if isKey(egg_name_to_sift_data_map, eggPair(2))
            sift_two = egg_name_to_sift_data_map(eggPair(2));
        else
            fprintf('cannot find egg sift features: ');
            disp(eggPair(2));
            meanFeatureDifferences(i) = 0;
            continue
        end
        % get the matched sift features
        indexPairs = matchFeatures(sift_one,sift_two);
        for j = 1:numel(indexPairs(:,1)) % for each pair of matched features
            indexPair = indexPairs(j,:);
            featureDifferences(j) = abs(sift_one(indexPair(1), dim) - sift_two(indexPair(2), dim)); % difference between two sift features at the specified dimension
            if featureDifferences(j) == 0
                fprintf('feature difference is zero\n');
            elseif featureDifferences(j) < 0
                fprintf('feature difference is negative\n');
            end
        end
        if numel(indexPairs) == 0
%             fprintf('no matched features\n');
            sprintf('no matched features: %f \n', i);
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
function eggPairDifferenceHistogram = getOrientalDifferenceHistogram(eggPairs, egg_name_to_sift_data_map)
    for i = 1:numel(eggPairs(:,1)) % for each pair of eggs
        eggPair = eggPairs(i,:);
        % get the sift features for egg one and egg two in each pair of eggs
        if isKey(egg_name_to_sift_data_map, eggPair(1))
            sift_one = egg_name_to_sift_data_map(eggPair(1));
        else
            fprintf('cannot find egg sift features: ');
            disp(eggPair(1));
            meanFeatureDifferences(i) = 0;
            continue
        end
        if isKey(egg_name_to_sift_data_map, eggPair(2))
            sift_two = egg_name_to_sift_data_map(eggPair(2));
        else
            fprintf('cannot find egg sift features: ');
            disp(eggPair(2));
            meanFeatureDifferences(i) = 0;
            continue
        end
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
            featureDifferences(j) = abs(featureDifferences(j)); % difference between two sift features at the specified dimension
            if featureDifferences(j) == 0
                fprintf('feature difference is zero\n');
            elseif featureDifferences(j) < 0
                fprintf('feature difference is negative\n');
            end
        end
        if numel(indexPairs) == 0
%             fprintf('no matched features\n');
            sprintf('no matched features: %f \n', i);
            meanFeatureDifferences(i) = 0;
        else
            meanFeatureDifferences(i) = mean(featureDifferences); % mean of all the matched sift feature differences
        end
    end
    eggPairDifferenceHistogram = meanFeatureDifferences;
end
