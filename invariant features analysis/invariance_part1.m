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
    clutch_name(i) = strcat(filesplit(1),'_',filesplit(2));
    egg_name(i) = filesplit(3);
    filenames(i) = convertCharsToStrings(filename); % a list of all the filenames
    egg_name_to_sift_data_map(filename) = readSIFTtxt(fullfile(dirinfo(i).folder,dirinfo(i).name)); % store SIFT data corresponding to filename
    if isempty( regexp( filename, '_in_' )  )
        clutch_names_without_in = [clutch_names_without_in, strcat(filesplit(1),'_',filesplit(2))];
        filenames_without_in = [filenames_without_in,convertCharsToStrings(filename)];
    end
end
fprintf('read egg data\n');
%% Create datasets for inter- and intra-clutch. 
% This will probably involve selecting at random
% one egg per clutch for interclutch
[G, TID] = findgroups(clutch_name'); % find the grouping of eggs according to clutch name
s = RandStream('dsfmt19937'); % specify random seed so that the result is the same everytime we run the program
randomSelectOne = @(egg_names)egg_names(randperm(s, numel(egg_names), 1)); % function to randomly select one egg from the given list of egg names
interclutch_eggs = splitapply(randomSelectOne,filenames',G); % for each clutch, apply the random select one function
interclutch_pairs = nchoosek(interclutch_eggs,2); % get all combinations of the interclutch pairs of eggs 
% selecting at random two eggs per clutch for intraclutch.
[without_in_G, TID] = findgroups(clutch_names_without_in');
% egg_in_definition = '_in_';
% egg_filenames = filenames';
% egg_name_includes_in = not( cellfun( @isempty, regexp( egg_filenames, egg_in_definition ) ) );
% egg_filenames( egg_name_includes_in ) = []; % remove egg names that include in
intraclutch_pairs = splitapply(@randomSelectTwo,filenames_without_in',without_in_G); % for each clutch, apply the random select two function
remove_empty_intraclutch_pairs = intraclutch_pairs(~any(cellfun('isempty',intraclutch_pairs),2),:); % remove empty entries resulted from one-egg clutches
fprintf('random select pairs\n');
%% For each pair of eggs, match features according to 128-d vector 
% (this, I think, is what NPM naturally does). 
% This will result in a histogram of
% orientational differences between eggs of the same clutch (intraclutch),
% and a histogram of
% orientational differences between eggs of different clutches (interclutch). 
% Use the same method with position and scale.
% the sift feature 132 columns are location(y,x), scale, orientation, and 128 entries of gradient orientation histogram
% thus position, i.e. y axis, dimension is 1; scale dimension is 3,
% orientation dimension is 4
interclutchOrientalHistogram = getOrientalDifferenceHistogram(interclutch_pairs, egg_name_to_sift_data_map);
intraclutchOrientalHistogram = getOrientalDifferenceHistogram(remove_empty_intraclutch_pairs, egg_name_to_sift_data_map);
interclutchPositionHistogram = getDifferenceHistogram(interclutch_pairs, egg_name_to_sift_data_map, 1);
intraclutchPositionHistogram = getDifferenceHistogram(remove_empty_intraclutch_pairs, egg_name_to_sift_data_map, 1);
interclutchScaleHistogram = getDifferenceHistogram(interclutch_pairs, egg_name_to_sift_data_map, 3);
intraclutchScaleHistogram = getDifferenceHistogram(remove_empty_intraclutch_pairs, egg_name_to_sift_data_map, 3);
fprintf('get histograms\n');
%% write results to csv files
writematrix(interclutchOrientalHistogram','interclutchOrientalHistogram.csv') 
writematrix(intraclutchOrientalHistogram','intraclutchOrientalHistogram.csv') 
writematrix(interclutchPositionHistogram','interclutchPositionHistogram.csv') 
writematrix(intraclutchPositionHistogram','intraclutchPositionHistogram.csv') 
writematrix(interclutchScaleHistogram','interclutchScaleHistogram.csv') 
writematrix(intraclutchScaleHistogram','intraclutchScaleHistogram.csv') 
writematrix(remove_empty_intraclutch_pairs,'intraclutchPairs.csv') 
writematrix(interclutch_pairs,'interclutchPairs.csv') 
fprintf('write histograms\n');
%% functions
function y = randomSelectTwo(egg_names)
    if numel(egg_names)>2 % if the clutch has more than two eggs
        s = RandStream('dsfmt19937'); % set random seed
        y = reshape((egg_names(randperm(s, numel(egg_names), 2))),[1 2]); % randomly select two eggs
    else
        y = ["", ""]; % otherwise return empty strings
    end
end

function eggPairDifferenceHistogram = getDifferenceHistogram(eggPairs, egg_name_to_sift_data_map, dim)
    for i = 1:numel(eggPairs(:,1)) % for each pair of eggs
        eggPair = eggPairs(i,:);
        % get the sift features for egg one and egg two in each pair of eggs
        sift_one = egg_name_to_sift_data_map(eggPair(1));
        sift_two = egg_name_to_sift_data_map(eggPair(2));
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
            meanFeatureDifferences(i) = -1;
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
        sift_one = egg_name_to_sift_data_map(eggPair(1));
        sift_two = egg_name_to_sift_data_map(eggPair(2));
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
            meanFeatureDifferences(i) = 0;
        else
            meanFeatureDifferences(i) = mean(featureDifferences); % mean of all the matched sift feature differences
        end
    end
    eggPairDifferenceHistogram = meanFeatureDifferences;
end
