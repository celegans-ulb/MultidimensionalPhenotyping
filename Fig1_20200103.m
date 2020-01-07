
% Fig1

% Reproduces Figure 1

% Load data
% Get Spearman correlation coefficient with age and relative age for basal
% and situmulation data
% Get corresponding p values
% Extract biomarkers of ageing
% Compare basal and stimulation data / Plot results


%% load data

% set directory
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);


%% get correlation coefficients (Spearman)

% initialise variables to store correlation coefficients
corrBageS = NaN(numel(inputFeatNames),1);
corrSageS = NaN(numel(inputFeatNames),1);
corrBageRelS = NaN(numel(inputFeatNames),1);
corrSageRelS = NaN(numel(inputFeatNames),1);

% initialise variables to store p values
pValBageS = NaN(numel(inputFeatNames),1);
pValSageS = NaN(numel(inputFeatNames),1);
pValBageRelS = NaN(numel(inputFeatNames),1);
pValSageRelS = NaN(numel(inputFeatNames),1);

% loop through features
for ii = 1:numel(inputFeatNames)
    
    % get indexes for basal and stimulated data
    indexB = ismember(inputTreatments,'B');
    indexS = ismember(inputTreatments,'S');
    
    % get correlation coefficients and p values
    [corrBageS(ii),pValBageS(ii)] = corr(inputAges(indexB),normData(indexB,ii),'type','Spearman');
    [corrSageS(ii),pValSageS(ii)] = corr(inputAges(indexS),normData(indexS,ii),'type','Spearman');
    [corrBageRelS(ii),pValBageRelS(ii)] = corr(inputAgesRel(indexB),normData(indexB,ii),'type','Spearman');
    [corrSageRelS(ii),pValSageRelS(ii)] = corr(inputAgesRel(indexS),normData(indexS,ii),'type','Spearman');

end

% get absolute values for correlation coefficients
corrBageS = abs(corrBageS);
corrSageS = abs(corrSageS);
corrBageRelS = abs(corrBageRelS);
corrSageRelS = abs(corrSageRelS);


%% extract biomarkers of ageing (Bonferroni)

% ageing biomarkers are features that correlate with relative age
% done from stimulation data

% get index of biomarkers
indexMarkerS = pValSageRelS * numel(inputFeatNames) < 0.05;


%% plot results

% plot ageing biomarkers in green and other features in blue
% plot a red line to show perfect correlation

figure;

% correlation with age
subplot(1,2,1)
scatter(corrBageS(indexMarkerS == 0),corrSageS(indexMarkerS == 0));
hold on;
scatter(corrBageS(indexMarkerS == 1),corrSageS(indexMarkerS == 1),[],[0.4660    0.6740    0.1880]);
plot([0 1],[0 1],'r');
hold off;
title('Age (Spearman)')
xlabel('Correlation (basal)')
ylabel('Correlation (stimulation)')

% correlation with relative age
subplot(1,2,2)
scatter(corrBageRelS(indexMarkerS == 0),corrSageRelS(indexMarkerS == 0));
hold on;
scatter(corrBageRelS(indexMarkerS == 1),corrSageRelS(indexMarkerS == 1),[],[0.4660    0.6740    0.1880]);
plot([0 1],[0 1],'r');
hold off;
title('Relative age (Spearman)')
xlabel('Correlation (basal)')
ylabel('Correlation (stimulation)')

