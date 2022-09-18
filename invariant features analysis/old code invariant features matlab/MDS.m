MasterDir='/Users/christine/Downloads/Tanmay_work/Egg_tifs_masks/';
%% Read in the data, split it to row/column identifiers and data
cd(MasterDir);
% read the data, temporarily as a table
data = readtable('DataOut/SimMatrix.csv', 'ReadRowNames', true);
 
% save the row identifiers (which can double as column identifiers since they are in the same order)
names = data.Properties.RowNames; 
datainfo=names;
datatable=table2array(data);
 
% convert the data itself to a simple array of doubles
% data = cellfun(@(x)str2double(x), datatable); 
data = datatable;
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
fprintf('checkpoint1\n'); 
% run mds, in this case with just 2 dimensions
dimensions=2;
Y=mdscale(data,dimensions);
fprintf('checkpoint2\n'); 
% plot mds
% scatter(Y(:,1), Y(:,2)); % just scatter
subplot(2,1,1)
gscatter(Y(:,1), Y(:,2),table2array(datainfo(:,7))); % colour by experimental egg or not
subplot(2,1,2)
heatmap(data)
saveas(gcf,'/Users/christine/Downloads/Tanmay_output/012003_ori_gscatter_SimMatrix.jpg');
fprintf('ori_gscatter_SimMatrix\n');
