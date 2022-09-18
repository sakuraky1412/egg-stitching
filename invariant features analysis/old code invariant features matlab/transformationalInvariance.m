% import all SIFT txt files to matlab
txtfilefolder=fullfile(cd, '/SIFTdata'); % text file folder
dirinfo = dir(txtfilefolder); % get list of current text file dirs
dirinfo = dirinfo(~ismember({dirinfo.name},{'.','..'})); % remove matlab's . and .. entries in listing
N = length(dirinfo);

% Get corresponding clutch names for each egg
for i=1:N 
    if strcmp(dirinfo(i).name,'.DS_Store') == 1
        continue;
    end
    filename = dirinfo(i).name; 
    filesplit=strsplit(filename,'_');
    clutch_name(i) = filesplit(2);
    egg_name(i) = filesplit(3);
end 

[G, clutch_names] = findgroups(clutch_name');
clutches = splitapply(func,egg_name,G)

func = @(x,y) var(x-y);
[G,smokers] = findgroups(Smoker);
varBP = splitapply(func,Systolic,Diastolic,G)

% Create datasets for inter- and intra-clutch. 
% This will probably involve selecting at random
% one egg per clutch for interclutch, and 
% selecting at random two eggs per clutch for intraclutch.

% For each pair of eggs, match features according to 128-d vector 
% (this, I think, is what NPM naturally does). 
% Then measure, say, orientational difference 
% between each pair of matched features. 
% Do this
% for all features on each pair of eggs (both intra- and inter-clutch), 
% and these differences can be
% scaled (e.g. by subtracting mean and dividing by standard deviation). 
% This will result in a histogram of
% orientational differences between eggs of the same clutch (intraclutch),
% and a histogram of
% orientational differences between eggs of different clutches (interclutch). 
% We can calculate whether
% these histograms differ (e.g. using a t-test) – 
% I can do this if we have the raw data – a list of
% orientational differences for intraclutch, 
% and a list of orientational differences for interclutch.
% 
% Use the same method with position and scale.


% 
% for i=1:N % for each text file do the following loop
%    % read text file
%     siftDataFull{i}=readSIFTtxt(fullfile(dirinfo(i).folder,dirinfo(i).name)); % this inputs
%     %txt files into a cell array (requires funcrion readSIFTtxt
% end 
% 