
% Table S1

% Load data
% Get Spearman correlation coefficient with relative age
% Extract and sort biomarkers of ageing and correlation coefficients


%% load data

% set directory
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputAgesRelInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAgesRel = inputAgesRel(indexS);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);


%% get correlation coefficients (Spearman)

% initialise variable to store correlation coefficients
corrAgeRel = NaN(numel(inputFeatNames),1);

% initialise variable to store p values
pValAgeRel = NaN(numel(inputFeatNames),1);

% loop through features
for ii = 1:numel(inputFeatNames)
    
    % get correlation coefficients
    [corrAgeRel(ii),pValAgeRel(ii)] = corr(inputAgesRel,normData(:,ii),'type','Spearman');

end

% get absolute values
corrAgeRel = abs(corrAgeRel);


%% extract biomarkers and sort by coefficient (Bonferroni)

% get index
indexAgeRel = pValAgeRel * numel(inputFeatNames) < 0.05;

% get markers
markersAgeRel = inputFeatNames(indexAgeRel);
coeffAgeRel = corrAgeRel(indexAgeRel);
pValAgeRel = pValAgeRel(indexAgeRel);

% sort coefficient and markers
[sortedCoeffAgeRel,indexSortAgeRel] = sort(coeffAgeRel,'descend');
sortedMarkersAgeRel = markersAgeRel(indexSortAgeRel);
sortedPvalAgeRel = pValAgeRel(indexSortAgeRel)' * numel(inputFeatNames);







