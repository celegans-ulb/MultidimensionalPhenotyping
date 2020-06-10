

% Fig0_dataPrep

% Extract data from all featuresN files, combine and save for future use

% Read hdf5 files from Sebastian
% Load data
% Extract lifespan and worm info
% Interpolate missing data
% Clean dataset from bad worms and bad features
% Save variables


%% get file lists

% Some featuresN files could not be read and were removed to create the 
% "filtered" set. However, their existence is important to determine the 
% lifespan of worms, so two file lists are created.

% set directory
directory1 = '/Volumes/AGEiNG/Results_ageing_all/';
directory2 = '/Volumes/AGEiNG/Results_ageing_filtered/';

% get the list of files
[fileList1, ~] = dirSearch(directory1, 'featuresN.hdf5');
[fileList2, ~] = dirSearch(directory2, 'featuresN.hdf5');


%% get list of feature names and list of feature types (10th percentile, ...)

% open first file to get names of the structure fields
myData = h5read(fileList1{1},'/features_stats');
featNames = myData.name';

% store feature names in a cell array
inputFeatNames = cell(size(featNames,1),1);
for ii = 1:size(featNames,1)
    inputFeatNames{ii} = featNames(ii,:);
end

%  extract feature type
inputFeatType = cell(numel(inputFeatNames),1);
for ii = 1:numel(inputFeatNames)
    % get underscores
    myUnderscores = strfind(inputFeatNames{ii},'_');
    % get postfix
    inputFeatType{ii} = inputFeatNames{ii}(myUnderscores(end)+1:end);
end


%% get worm names, ages, type of treatment

% initialise variables to store worm info
inputAges = NaN(numel(fileList2),1);
inputNames = cell(numel(fileList2),1);
inputShortNames = cell(numel(fileList2),1);
inputTreatments = cell(numel(fileList2),1);

% hack file names to get names, ages and treatment
% loop through files
for ii = 1:numel(fileList2)
    
    % get underscore index
    myUnderscores = strfind(fileList2{ii},'_');

    % retreive data from file name
    inputAges(ii) = str2double(fileList2{ii}(myUnderscores(5)+2:myUnderscores(6)-1));
    inputTreatments{ii} = fileList2{ii}(myUnderscores(7)+1);
    inputNames{ii} = fileList2{ii}(myUnderscores(6)+1:myUnderscores(8)-1);
    inputShortNames{ii} = fileList2{ii}(myUnderscores(6)+1:myUnderscores(7)-1);

end


%% get lifespan, relative age and prognosis for each animal

% initialise variables to store lifespan
tempAges = NaN(numel(fileList1),1);
tempNames = cell(numel(fileList1),1);
inputLifespans = NaN(numel(fileList2),1);

% get list of names and ages for all files (first file list, otherwise the
% lifespan might be wrong)
for ii = 1:numel(fileList1)
    
     % get underscore index
    myUnderscores = strfind(fileList1{ii},'_');

    % retreive data from file name
    tempAges(ii) = str2double(fileList1{ii}(myUnderscores(5)+2:myUnderscores(6)-1));
    tempNames{ii} = fileList1{ii}(myUnderscores(6)+1:myUnderscores(8)-1);
    
end

% loop through filtered files
for ii = 1:numel(fileList2)
    
    % get ages for that that animal
    myAges = tempAges(ismember(tempNames,inputNames{ii}));
    
    % store lifespan
    inputLifespans(ii) = max(myAges) + 1;
    
end

% get relative ages and remaining lifespan
inputAgesRel = inputAges ./ inputLifespans;
inputAgesLeft = inputLifespans - inputAges;


%% load mean for each feature and store in matrix

% initialise matrix to store features data
rawData = NaN(numel(fileList2),numel(inputFeatNames));

% load data
% select only first tagged worm since "join trajectories did not work in that
% case". Although this drops a worm which "comes back"
% loop through files
for ii = 1:numel(fileList2)
   
    % display number of file
    disp(ii);
    
    % get data
    myData = h5read(fileList2{ii},'/features_stats');
    myData = myData.value;
      
    % Store first tagged worm
    rawData(ii,:) = myData;
    
end


%% interpolate missing data

% initialise matrix for interpolated data
interpData = rawData;

% loop through worms
for ii = 1:size(rawData,1)
    
    % display numer of file
    disp(ii);
    
    % get NaN number and index
    myNaN = isnan(rawData(ii, :));
    myNaNnumber = sum(myNaN);
    indexNaN = find(isnan(rawData(ii, :)));
    
    % check for the presence of NaNs and interpolate
    if myNaNnumber == 0
        continue
        
    else
        % get index for current worm
        indexWorm = ismember(inputShortNames,inputShortNames{ii}) & ismember(inputTreatments,inputTreatments{ii});
        % get ages of the worm
        myAges = inputAges(indexWorm);
        % loop through features
        for jj = 1:myNaNnumber
            % get data for that feature
            myData = rawData(indexWorm,indexNaN(jj));
            % check that there is more than one value
            if sum(~isnan(myData)) < 2
                continue
            else
                % do linear interpolation with no extrapolation
                vq = interp1(myAges(~isnan(myData)),myData(~isnan(myData)),inputAges(ii));
                interpData(ii,indexNaN(jj)) = vq;
            end
        end
    end
end


%% Drop features that are all NaNs

% get number of NaNs per feature
myNaNnumber = sum(isnan(interpData),1);

% get index for good features (less than 100% of NaNs)
indexGood = myNaNnumber < numel(inputNames);
numberBad = numel(inputFeatNames) - sum(indexGood);
% display number of features which will be dropped
disp([num2str(numberBad) ' features were dropped']);

% keep only good features
inputFeatNames = inputFeatNames(indexGood);
inputFeatType = inputFeatType(indexGood);
cleanData = interpData(:,indexGood);


%% clean dataset from worms with too many NaNs

% define acceptable number of NaNs (25% of feature number)
nanThreshold = floor(size(cleanData,2) * 0.25);

% get number of NaNs per worm
myNaNnumber = sum(isnan(cleanData),2);
numberBad = sum(myNaNnumber > nanThreshold);

% display number of worms which will be dropped
disp([num2str(numberBad) ' worms were dropped']);

% get keep index
indexGood = myNaNnumber < nanThreshold;

% drop bad worms and get new variables
cleanData = cleanData(indexGood,:);
inputAges = inputAges(indexGood);
inputAgesRel = inputAgesRel(indexGood);
inputAgesLeft = inputAgesLeft(indexGood);
inputLifespans = inputLifespans(indexGood);
inputNames = inputNames(indexGood);
inputShortNames = inputShortNames(indexGood);
inputTreatments = inputTreatments(indexGood);


%% Clean data from bad features

% drop any feature that still contains NaNs

% get number of NaNs per feature
myNaNnumber = sum(isnan(cleanData),1);

% get index for good features
indexGood = myNaNnumber == 0;
numberBad = numel(inputFeatNames) - sum(indexGood);
% display number of features which will be dropped
disp([num2str(numberBad) ' features were dropped']);

% keep only good features
inputFeatNames = inputFeatNames(indexGood);
inputFeatType = inputFeatType(indexGood);
cleanData = cleanData(:,indexGood);

% rename data
inputData = cleanData;



%% save variables

% save features
save('/Volumes/AGEiNG/Ageing datasets/inputDataInterpDrop.mat', ...
    'inputData');

% save worms info
save('/Volumes/AGEiNG/Ageing datasets/inputAgesInterpDrop.mat', ...
    'inputAges');
save('/Volumes/AGEiNG/Ageing datasets/inputAgesRelInterpDrop.mat', ...
    'inputAgesRel');
save('/Volumes/AGEiNG/Ageing datasets/inputAgesRelRoundInterpDrop.mat', ...
    'inputAgesRelRound');
save('/Volumes/AGEiNG/Ageing datasets/inputAgesLeftInterpDrop.mat', ...
    'inputAgesLeft');
save('/Volumes/AGEiNG/Ageing datasets/inputLifespansInterpDrop.mat', ...
    'inputLifespans');
save('/Volumes/AGEiNG/Ageing datasets/inputNamesInterpDrop.mat', ...
    'inputNames');
save('/Volumes/AGEiNG/Ageing datasets/inputShortNamesInterpDrop.mat', ...
    'inputShortNames');
save('/Volumes/AGEiNG/Ageing datasets/inputTreatmentsInterpDrop.mat', ...
    'inputTreatments');

% save feature info
save('/Volumes/AGEiNG/Ageing datasets/inputFeatNamesInterpDrop.mat', ...
    'inputFeatNames');
save('/Volumes/AGEiNG/Ageing datasets/inputFeatTypeInterpDrop.mat', ...
    'inputFeatType');

