%% This code was written to run NPM to get all pairwise distances between images in a test folder
% Ben Hogan 11/09/18
 
% This little tutorial starts when you have a bunch of egg images in
% /Images, and each has an identically names binary mask in /Masks. It
% edits the images by taking just one color channel (green), and
% applying the mask. It moves them to individual folders (one per egg
% image). It then runs NPM processing on these images, applying enhancement
% and then extracting SIFT features. Then it runs matching, getting all
% pairwise similarities. It then opens the similarity matrix and makes a
% toy plot of the results.
 
% The first section make folders for all the eggs, and copies each eggs image to
% its folder. The second section runs NPM (processing then matching) on those folders. 
% The third loads the results into matlab. 
 
% In this case, lots of information is encoded in the filename itself, so once we
% have results, we can generate a table that corresponds to the images.
 
%% I would suggest changing the directory set below to ones that make sense on your machine
% then try to go through and see what stuff is doing. This is by no means
% the optimal or only way to run NPM, just the one that was easiest for my
% work using NPM so far.
 
 
%% Notes - 
% IMAGE FORMAT/PRE-PROCESSING
% This code assumes that you have already converted your images to a
% sensible format, or a desired format. In general you want to use .tiffs
% generated from raw files as this process retains color and image quality
% better than shooting in jpg. Otherwise you might only be interested in
% one color channel of the image - which you could separate by loading
% images rather than just moving them, and doing some manipulations.
 
% Note, I've only ever used greyscale images - in this script i'll just
% arbritrarily take the green channel.
 
% MASKS -
% NPM can do some masking, assuming you have a constant background. Equally Stoddard lab
% has the EggXtractor, which (I think) is much more flexible and automatic, but I haven't used it. 
 
% I manually made the masks in the folder using ImageJ and a 
% function that it bundled in with Jolyon Troscianko's
% mica toolbox (Egg Tools>Egg shape cutout). To use that, install mica,
% open an egg image use the multi-point tool to click at the top, bottom,
% and then in 3+ symetric pairs down the edges, then use select the tool in the menu. To
% accept the yellow line produced around the egg
% use the invisible button at the lower left (cursor
% turns to a hand when hovering over it). You can then go
% edit>selection>make inverse, then edit>selection>create mask. You can
% write a macro to speed up that process. You'll want the mask named the
% same as the image, but with suffix _CR.
 
% Initially, stick all eggs in unique folders (for easy running of NPM on all pairwise comparisons)
 
% Set current directory
MasterDir='/Users/christine/Downloads/Tanmay_work/Egg_tifs_masks/';
cd(MasterDir);
 
% Set locations
EggOriginalFolder=fullfile(cd, '/Images'); % Image files
MaskOriginalFolder=fullfile(cd, '/Masks'); % Mask files
WantedLocation = fullfile(cd, '/NPM_working'); % empty dir to put folders that are unique for each egg
 
% Get lists of egg images and masks
dirinfo = dir(EggOriginalFolder); % get list of current egg dirs
dirinfo = dirinfo(~ismember({dirinfo.name},{'.','..'})); % remove matlab's . and .. entries in listing
maskinfo = dir(MaskOriginalFolder); % get list of current egg mask dirs
maskinfo = maskinfo(~ismember({maskinfo.name},{'.','..'})); % remove matlab's . and .. entries in listing
 
% Check that the masks and images match up in number and name
if  size(dirinfo,1)~=size(maskinfo,1)
    warning('Number of masks and images does not match')
end
if sum(ismember({maskinfo.name},{maskinfo.name})) ~= size(dirinfo,1)
    warning('Mask and image names do not match up')
end
     
% make a directory for each egg, mask the egg and move the egg images there
for i=1:length(dirinfo) % for each egg image do the following loop
    if strcmp(dirinfo(i).name,'.DS_Store') == 1 % || strcmp(maskinfo(i).name,'.DS_Store') == 1
        continue;
    end
    % read and mask image
    im=imread(fullfile(dirinfo(i).folder, dirinfo(i).name)); % read image
    %%%% NOTE IVE REMOVED THE LINE WHICH TAKES THE GREEN CHANNEL HERE
%     bw=imread(fullfile(maskinfo(i).folder, maskinfo(i).name))./255; % read mask image
%     im=bsxfun(@times, im, cast(bw, 'like', im)); % mask image %% IS THIS MASKING? CANT TELL FROM IMAGE
%     
%     % rotate images which are 'sideways' to make them 'upright'
%     if size(im,2)>size(im,1)
%         im=rot90(im,1);
%     end
%     %rotate images pointing downwards to make them point upwards
%     if sum(sum(~im(1:50,:)))<sum(sum(~im([size(im,1)-49]:size(im,1),:)))
%         im=rot90(im,2);
%     end

    % get name and location
    this=dirinfo(i).name(1:end-4); % egg name, removes .tif
    where=char([WantedLocation,'/', this]); % where to put it
     
    % if we don't have a directory there called that, make one
    if exist(where,'dir')~=7
        mkdir(where); 
    end
     
    % copy the original across, and save masked version too
    copyfile([EggOriginalFolder,'/', this, '*'], where); % copy image
    imwrite(im, [where,'/', this, '_CR.tif']); % copy mask % THIS LINE DOESNT WORK
     
    % if you get an error about writing, make sure images are not read-only
    % (or force the move with matlab 'f').
end
 
clear i this where dirinfo maskinfo im bw % tidy up
 
%% Okay run NPM on those folders to get output
% NPM can be run from command line, but its far easier to run from matlab
% (in my opinion). Since we have made a file directory that has a unique
% folder for each image - we can easily generate all comparisons. 
 
% define location of NPM .exe files 
% NPMFolder=strcat(MasterDir, 'NPMv2.00a');
NPMFolder=strcat(MasterDir, 'NPMv1.05_64bit');
cd(NPMFolder) 
% define where we want to save similarity matrix to
saveSimMatrix=strcat(MasterDir, 'DataOut/SimMatrix.csv');
 
% First we use the npm_process .exe to pre-process each of the files. 
% First we tell NPM to work on the directory containing all our unique folders 
% We already have masks so we won't use that option here. NPM process then
% asks what kind of image enhancements we want. 0 is none, 1+ is some.
% Here we'll choose option 8. Next we enter 1 to run that image
% enhancement, generating files in each folder suffixed _EH. Then we enter
% 2 to get the SIFT features extracted. You can see all options and pick
% manually with command system('npm_process'). We'll just put it in as a
% string to do it all at once. 
 
% Run processing
% strCommandLine = char(strcat("./npm_process",{' '}, WantedLocation,{' '}, '8 1 2'));
% strCommandLine = char(strcat("./npm_process -debug 1",{' '}, WantedLocation,{' '}, '8 1 2'));
strCommandLine = char(strcat("./npm_process -debug 4",{' '}, WantedLocation,{' '}, '8 1 2'));
system(strCommandLine);  
 
% Matching works in a similar way, here we set the path (we enter the same
% path two times in order to get all pairwise comparisons), then a bunch of
% options - see NPM documentation for explanation of what they are.
% system('npm_match') may help.
 
% Run matching
% strCommandLine = char(strcat("./npm_match",{' '}, WantedLocation,{' '}, WantedLocation,{' '},'0 2 2 1 -c', {' '}, saveSimMatrix));
% strCommandLine = char(strcat("./npm_match -debug 1",{' '}, WantedLocation,{' '}, WantedLocation,{' '},'0 2 2 1 -c', {' '}, saveSimMatrix));
strCommandLine = char(strcat("./npm_match -debug 4",{' '}, WantedLocation,{' '}, WantedLocation,{' '},'0 2 2 1 -c', {' '}, saveSimMatrix));
system(strCommandLine); 
 
% So we now have a similarity matrix saved out into DataOut. 
clear strCommandLine 
 
%% Read in the data, split it to row/column identifiers and data
cd(MasterDir);
% read the data, temporarily as a table
data = readtable('DataOut/SimMatrix.csv', 'ReadRowNames', true);
 
% save the row identifiers (which can double as column identifiers since they are in the same order)
names = data.Properties.RowNames; 
datainfo=names;

datatable = table2array(data);
 
% convert the data itself to a simple array of doubles
data = cellfun(@(x)str2double(x), table2array(data)); 
 
% Can extract information from the filenames to store in a table for later
% use, I do this here by splitting up the filename into sections and
% recording the resulting parts.
for i=1:length(names)
    [~,split,~]=fileparts(char(names(i,:))); % get just filename (lose directory or file type)
    datainfo(i,2)={split}; % record that whole filename
    split=strsplit(split,'_'); % split the filename into all sections separated by underscores
    datainfo(i,3)=split(1); % record year
    datainfo(i,4)=split(2); % record clutch
    datainfo(i,5)=split(3); % record egg
    datainfo(i,6)=split(4); % record egg side
    %%%TD: I will need to add side of egg...datainfo(i,6)=split(4); ??
     
    if size(split,2)>4 % if theres more information
        datainfo(i,7)={1}; % mark as experimental
        datainfo(i,8)=split(end); % record host nest
    else % if theres no more information
        datainfo(i,7)={0}; % mark as non-experimental
        datainfo(i,8)={NaN}; % mark host nest as nan
    end
    clear split i
     
end
clear names
 
varNames={'FilePath', 'FileName', 'Year', 'Clutch', 'Egg','Side', 'Experimental', 'Host'}; % define names of each of these; 
%I have added 'side' to account for 4 'sides' of an egg;
datainfo=cell2table(datainfo,'VariableNames',varNames); % turn that array into a table (for easy saving etc).
clear varNames
 
%% Invert similarity to get distance, fix diagonals, and try MDS
% One way to visualize (and do maths on) these pairwise distances is
% embedding them in a lower dimensional space. One method is MDS. One for
% just visualization (that looks nice) is tSNE. We have also undertaken
% analyses using the raw pairwise distances, which avoids the loss of
% information that can occur with embedding - but is less
% plottable/visually appealing. Clustering on the basis of the embedded
% points is also a cool idea.
 
% invert the pairwise similarity
data=1-data; % now we have distance
data(logical(eye(size(data)))) = 1; % fix the diagonal being 1 rather than 0 (a convention)
 
% run mds, in this case with just 2 dimensions
dimensions=2;
Y=mdscale(data,dimensions);
 
% plot mds
% scatter(Y(:,1), Y(:,2)); % just scatter
subplot(2,1,1)
gscatter(Y(:,1), Y(:,2),table2array(datainfo(:,7))); % colour by experimental egg or not
subplot(2,1,2)
heatmap(data)

%%Questions for Ben. What does mds do? It seems to just change a 2d array
%%(distances) into another 2D array. Why cant i just plot the data as it
%%is,and I would surely do all analyses with raw data, rather than the mds data (Y)? 
%%Doesn't the raw data basically show a quantification for the amount of 
%%difference (in higher level features) between two eggs? 
