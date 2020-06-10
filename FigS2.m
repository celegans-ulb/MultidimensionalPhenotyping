
% FigS2

% Reproduces Figure S2

% Load data
% Do PCA analysis
% For each lifespan group, get cumulative distance for several percentages
% of total variance: 50%, 60%, 70%, 80%, 90%.


%% load data

% set directory
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputNamesInterpDrop']);
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
inputAgesRelRound = round(inputAgesRel*20)/20;
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);
inputAgesRel = inputAgesRel(indexS);
inputAgesRelRound = inputAgesRelRound(indexS);
inputLifespans = inputLifespans(indexS);
inputNames = inputNames(indexS);

% get unique data
uniqueAges = unique(inputAges);
uniqueAgesRelRound = unique(inputAgesRelRound);
[uniqueNames,indexUnique] = unique(inputNames);
wormLifespans = inputLifespans(indexUnique);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);


%% make groups according to lifespan

% assign a group number according to lifespan
% 151 animals / 5 groups = 30 animals per group
inputLifespanGroup = NaN(numel(inputAges),1);
inputLifespanGroup(inputLifespans <= 12) = 1;
inputLifespanGroup(inputLifespans >= 13 & inputLifespans <= 14) = 2;
inputLifespanGroup(inputLifespans >= 15 & inputLifespans <= 16) = 3;
inputLifespanGroup(inputLifespans >= 17 & inputLifespans <= 18) = 4;
inputLifespanGroup(inputLifespans >= 19) = 5;

uniqueLifespanGroups = unique(inputLifespanGroup);
wormLifespanGroup = inputLifespanGroup(indexUnique);


%% do PCA

[PCAcoeff,PCAscore,PCAlatent,PCAtsquared,PCAexplained,PCAmu] = pca(normData);


%% calculate the speed of phenotypic change for several percentages of total variance

% initialise variables to store the phenotypic distance
phenotypicDistance50 = zeros(numel(uniqueLifespanGroups),numel(uniqueAges));
phenotypicDistance60 = zeros(numel(uniqueLifespanGroups),numel(uniqueAges));
phenotypicDistance70 = zeros(numel(uniqueLifespanGroups),numel(uniqueAges));
phenotypicDistance80 = zeros(numel(uniqueLifespanGroups),numel(uniqueAges));
phenotypicDistance90 = zeros(numel(uniqueLifespanGroups),numel(uniqueAges));

% loop through lifespan groups (50%)
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 2:numel(uniqueAges)
        
        % get current index
        indexCurrent1 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get current index + previous age (1 day difference)
        indexCurrent2 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj-1);
        
        % get mean coordinates
        phenotypeTime1 = nanmean(PCAscore(indexCurrent1,1:2));
        phenotypeTime2 = nanmean(PCAscore(indexCurrent2,1:2));
        
        % get phenotypic distance
        phenotypicDistance50(ii,jj) = norm(phenotypeTime1 - phenotypeTime2);
        
    end
end

% loop trhough lifespan groups (60%)
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 2:numel(uniqueAges)
        
        % get current index
        indexCurrent1 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get current index + previous age (1 day difference)
        indexCurrent2 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj-1);
        
        % get mean coordinates
        phenotypeTime1 = nanmean(PCAscore(indexCurrent1,1:5));
        phenotypeTime2 = nanmean(PCAscore(indexCurrent2,1:5));
        
        % get phenotypic distance
        phenotypicDistance60(ii,jj) = norm(phenotypeTime1 - phenotypeTime2);
        
    end
end

% loop trhough lifespan groups (70%)
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 2:numel(uniqueAges)
        
        % get current index
        indexCurrent1 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get current index + previous age (1 day difference)
        indexCurrent2 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj-1);
        
        % get mean coordinates
        phenotypeTime1 = nanmean(PCAscore(indexCurrent1,1:12));
        phenotypeTime2 = nanmean(PCAscore(indexCurrent2,1:12));
        
        % get phenotypic distance
        phenotypicDistance70(ii,jj) = norm(phenotypeTime1 - phenotypeTime2);
        
    end
end

% loop trhough lifespan groups (80%)
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 2:numel(uniqueAges)
        
        % get current index
        indexCurrent1 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get current index + previous age (1 day difference)
        indexCurrent2 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj-1);
        
        % get mean coordinates
        phenotypeTime1 = nanmean(PCAscore(indexCurrent1,1:28));
        phenotypeTime2 = nanmean(PCAscore(indexCurrent2,1:28));
        
        % get phenotypic distance
        phenotypicDistance80(ii,jj) = norm(phenotypeTime1 - phenotypeTime2);
        
    end
end

% loop trhough lifespan groups (90%)
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 2:numel(uniqueAges)
        
        % get current index
        indexCurrent1 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get current index + previous age (1 day difference)
        indexCurrent2 = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj-1);
        
        % get mean coordinates
        phenotypeTime1 = nanmean(PCAscore(indexCurrent1,1:72));
        phenotypeTime2 = nanmean(PCAscore(indexCurrent2,1:72));
        
        % get phenotypic distance
        phenotypicDistance90(ii,jj) = norm(phenotypeTime1 - phenotypeTime2);
        
    end
end

% get cumulatice distances
cumDistance50 = cumsum(phenotypicDistance50,2);
cumDistance60 = cumsum(phenotypicDistance60,2);
cumDistance70 = cumsum(phenotypicDistance70,2);
cumDistance80 = cumsum(phenotypicDistance80,2);
cumDistance90 = cumsum(phenotypicDistance90,2);


%% plot results

subplot(1,5,1)
plot(uniqueAges,cumDistance50,'linewidth',2);
xlim([0 30]);
ylim([0 300]);
title('50% total variance');
xlabel('Age (days)');
ylabel('Cumulative distance (AU)');

subplot(1,5,2)
plot(uniqueAges,cumDistance60,'linewidth',2);
xlim([0 30]);
ylim([0 300]);
title('60% total variance');
xlabel('Age (days)');
ylabel('Cumulative distance (AU)');

subplot(1,5,3)
plot(uniqueAges,cumDistance70,'linewidth',2);
xlim([0 30]);
ylim([0 300]);
title('70% total variance');
xlabel('Age (days)');
ylabel('Cumulative distance (AU)');

subplot(1,5,4)
plot(uniqueAges,cumDistance80,'linewidth',2);
xlim([0 30]);
ylim([0 300]);
title('80% total variance');
xlabel('Age (days)');
ylabel('Cumulative distance (AU)');

subplot(1,5,5)
plot(uniqueAges,cumDistance90,'linewidth',2);
xlim([0 30]);
ylim([0 300]);
title('90% total variance');
xlabel('Age (days)');
ylabel('Cumulative distance (AU)');



