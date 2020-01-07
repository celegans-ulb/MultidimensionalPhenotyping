
% Fig4

% Reproduces Figure 4

% Load data
% Do PCA analysis
% Plot results (stimulation data) as subplots


%% load data

% set directory
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputNamesInterpDrop']);
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);
inputAgesRel = inputAgesRel(indexS);
inputLifespans = inputLifespans(indexS);
inputNames = inputNames(indexS);

% get unique data
uniqueAges = unique(inputAges);
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

wormLifespanGroup = inputLifespanGroup(indexUnique);


%% do PCA

[PCAcoeff,PCAscore,PCAlatent,PCAtsquared,PCAexplained,PCAmu] = pca(normData);


%% plot mean and standard error / subplots

% initialise variables
meanXstimAll = NaN(1,numel(uniqueAges));
meanYstimAll = NaN(1,numel(uniqueAges));
seXstimAll = NaN(1,numel(uniqueAges));
seYstimAll = NaN(1,numel(uniqueAges));
meanXstim = NaN(5,numel(uniqueAges));
meanYstim = NaN(5,numel(uniqueAges));
seXstim = NaN(5,numel(uniqueAges));
seYstim = NaN(5,numel(uniqueAges));

myColors = lines;

subplot(2,3,1);
scatter(PCAscore(:,1),PCAscore(:,2),36,inputAgesRel,'o');
axis off;
title('lifespan \leq 12 days','Fontsize',16);
hold on;
subplot(2,3,2);
scatter(PCAscore(:,1),PCAscore(:,2),36,inputAgesRel,'o');
title('13 days \leq lifespan \leq 14 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,3);
scatter(PCAscore(:,1),PCAscore(:,2),36,inputAgesRel,'o');
title('15 days \leq lifespan \leq 16 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,4);
scatter(PCAscore(:,1),PCAscore(:,2),36,inputAgesRel,'o');
title('17 days \leq lifespan \leq 18 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,5);
scatter(PCAscore(:,1),PCAscore(:,2),36,inputAgesRel,'o');
title('19 days \leq lifespan','Fontsize',16);
axis off;
hold on;
subplot(2,3,6)
axis off;

% loop through ages
for ii = 1:numel(uniqueAges)
    
    % get index for that age
    indexS = inputAges == uniqueAges(ii);
    indexS1 = inputAges == uniqueAges(ii) & inputLifespanGroup == 1;
    indexS2 = inputAges == uniqueAges(ii) & inputLifespanGroup == 2;
    indexS3 = inputAges == uniqueAges(ii) & inputLifespanGroup == 3;
    indexS4 = inputAges == uniqueAges(ii) & inputLifespanGroup == 4;
    indexS5 = inputAges == uniqueAges(ii) & inputLifespanGroup == 5;
    
    % get mean values and standard deviations
    meanXstimAll(ii) = nanmean(PCAscore(indexS,1));
    meanYstimAll(ii) = nanmean(PCAscore(indexS,2));
    meanXstim(1,ii) = nanmean(PCAscore(indexS1,1));
    meanXstim(2,ii) = nanmean(PCAscore(indexS2,1));
    meanXstim(3,ii) = nanmean(PCAscore(indexS3,1));
    meanXstim(4,ii) = nanmean(PCAscore(indexS4,1));
    meanXstim(5,ii) = nanmean(PCAscore(indexS5,1)); 
    meanYstim(1,ii) = nanmean(PCAscore(indexS1,2));
    meanYstim(2,ii) = nanmean(PCAscore(indexS2,2));
    meanYstim(3,ii) = nanmean(PCAscore(indexS3,2));
    meanYstim(4,ii) = nanmean(PCAscore(indexS4,2));
    meanYstim(5,ii) = nanmean(PCAscore(indexS5,2));
    seXstimAll(ii) = nanstd(PCAscore(indexS,1))/sqrt(sum(indexS));
    seYstimAll(ii) = nanstd(PCAscore(indexS,2))/sqrt(sum(indexS));
    seXstim(1,ii) = nanstd(PCAscore(indexS1,1))/sqrt(sum(indexS1));
    seXstim(2,ii) = nanstd(PCAscore(indexS2,1))/sqrt(sum(indexS2));
    seXstim(3,ii) = nanstd(PCAscore(indexS3,1))/sqrt(sum(indexS3));
    seXstim(4,ii) = nanstd(PCAscore(indexS4,1))/sqrt(sum(indexS4));
    seXstim(5,ii) = nanstd(PCAscore(indexS5,1))/sqrt(sum(indexS5));  
    seYstim(1,ii) = nanstd(PCAscore(indexS1,2))/sqrt(sum(indexS1));
    seYstim(2,ii) = nanstd(PCAscore(indexS2,2))/sqrt(sum(indexS2));
    seYstim(3,ii) = nanstd(PCAscore(indexS3,2))/sqrt(sum(indexS3));
    seYstim(4,ii) = nanstd(PCAscore(indexS4,2))/sqrt(sum(indexS4));
    seYstim(5,ii) = nanstd(PCAscore(indexS5,2))/sqrt(sum(indexS5));
 
    % plot
    subplot(2,3,1);
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(1,ii)-seXstim(1,ii),meanXstim(1,ii)+seXstim(1,ii)], ...
        [meanYstim(1,ii),meanYstim(1,ii)], [meanXstim(1,ii),meanXstim(1,ii)], ...
        [meanYstim(1,ii)-seYstim(1,ii),meanYstim(1,ii)+seYstim(1,ii)], ...
        '-', 'LineWidth', 2, 'Color', 'r')
    subplot(2,3,2)
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(2,ii)-seXstim(2,ii),meanXstim(2,ii)+seXstim(2,ii)], ...
        [meanYstim(2,ii),meanYstim(2,ii)], [meanXstim(2,ii),meanXstim(2,ii)], ...
        [meanYstim(2,ii)-seYstim(2,ii),meanYstim(2,ii)+seYstim(2,ii)], ...
        '-', 'LineWidth', 2, 'Color', 'r')
    subplot(2,3,3);
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(3,ii)-seXstim(3,ii),meanXstim(3,ii)+seXstim(3,ii)], ...
        [meanYstim(3,ii),meanYstim(3,ii)], [meanXstim(3,ii),meanXstim(3,ii)], ...
        [meanYstim(3,ii)-seYstim(3,ii),meanYstim(3,ii)+seYstim(3,ii)], ...
        '-', 'LineWidth', 2, 'Color', 'r')
    subplot(2,3,4);
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(4,ii)-seXstim(4,ii),meanXstim(4,ii)+seXstim(4,ii)], ...
        [meanYstim(4,ii),meanYstim(4,ii)], [meanXstim(4,ii),meanXstim(4,ii)], ...
        [meanYstim(4,ii)-seYstim(4,ii),meanYstim(4,ii)+seYstim(4,ii)], ...
        '-', 'LineWidth', 2, 'Color', 'r')
    subplot(2,3,5);
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(5,ii)-seXstim(5,ii),meanXstim(5,ii)+seXstim(5,ii)], ...
        [meanYstim(5,ii),meanYstim(5,ii)], [meanXstim(5,ii),meanXstim(5,ii)], ...
        [meanYstim(5,ii)-seYstim(5,ii),meanYstim(5,ii)+seYstim(5,ii)], ...
        '-', 'LineWidth', 2, 'Color', 'r')
    subplot(2,3,6)
        
end