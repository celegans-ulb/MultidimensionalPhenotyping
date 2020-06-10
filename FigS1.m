
% FigS1

% Reproduces Figure S1

% Load data
% Run tSNE and plot per lifespan group


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
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'B');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);
inputAgesRel = inputAgesRel(indexS);
inputLifespans = inputLifespans(indexS);
inputNames = inputNames(indexS);
inputTreatments = inputTreatments(indexS);

% get unique data
[uniqueNames,indexUnique,~] = unique(inputNames);
uniqueLifespans = inputLifespans(indexUnique);
uniqueAges = unique(inputAges);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);;


%% make groups according to lifespan

% assign a group number according to lifespan
% 151 animals / 5 groups = 30 animals per group
inputLifespanGroup = NaN(numel(inputNames),1);
inputLifespanGroup(inputLifespans <= 12) = 1;
inputLifespanGroup(inputLifespans >= 13 & inputLifespans <= 14) = 2;
inputLifespanGroup(inputLifespans >= 15 & inputLifespans <= 16) = 3;
inputLifespanGroup(inputLifespans >= 17 & inputLifespans <= 18) = 4;
inputLifespanGroup(inputLifespans >= 19) = 5;


%% run tSNE

% set t-sne parameters
tsneNumDims = 2;
tsneIniDims = 30;
tsnePerplex = 30;

% run t-sne
tSNEresult = tsne(normData, [], tsneNumDims, tsneIniDims, tsnePerplex);


%% plot mean and standard error / subplots

% set colors
myColors = [0.2081    0.1663    0.5292;   
    0.2123    0.2138    0.6270; 
    0.1707    0.2919    0.7792;  
    0.0591    0.3598    0.8683;  
    0.0165    0.4266    0.8786;  
    0.0498    0.4586    0.8641;   
    0.0779    0.5040    0.8384;   
    0.0749    0.5375    0.8263;   
    0.0343    0.5966    0.8199;  
    0.0239    0.6287    0.8038;
    0.0267    0.6642    0.760;   
    0.0590    0.6838    0.7254;  
    0.1453    0.7098    0.6646;   
    0.2178    0.7250    0.6193;  
    0.3482    0.7424    0.5473;   
    0.4420    0.7481    0.5033;  
    0.5709    0.7485    0.4494;   
    0.6473    0.7456    0.4188;   
    0.7525    0.7384    0.3768;  
    0.8185    0.7327    0.3498;  
    0.9139    0.7258    0.3063;   
    0.9739    0.7314    0.2666;  
    0.9955    0.7861    0.1967;  
    0.9789    0.8271    0.1633;   
    0.9589    0.8949    0.1132;   
    0.9661    0.9514    0.0755];

% initialise variables
meanXstimAll = NaN(1,numel(uniqueAges));
meanYstimAll = NaN(1,numel(uniqueAges));
seXstimAll = NaN(1,numel(uniqueAges));
seYstimAll = NaN(1,numel(uniqueAges));
meanXstim = NaN(5,numel(uniqueAges));
meanYstim = NaN(5,numel(uniqueAges));
seXstim = NaN(5,numel(uniqueAges));
seYstim = NaN(5,numel(uniqueAges));

subplot(2,3,1);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,inputAgesRel,'o');
axis off;
title('all lifespans','Fontsize',16);
hold on;
subplot(2,3,2);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,[0.8 0.8 0.8],'o');
axis off;
title('lifespan \leq 12 days','Fontsize',16);
hold on;
subplot(2,3,3);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,[0.8 0.8 0.8],'o');
title('13 days \leq lifespan \leq 14 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,4);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,[0.8 0.8 0.8],'o');
title('15 days \leq lifespan \leq 16 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,5);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,[0.8 0.8 0.8],'o');
title('17 days \leq lifespan \leq 18 days','Fontsize',16);
axis off;
hold on;
subplot(2,3,6);
scatter(tSNEresult(:,1),tSNEresult(:,2),36,[0.8 0.8 0.8],'o');
title('19 days \leq lifespan','Fontsize',16);
axis off;
hold on;

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
    meanXstimAll(ii) = nanmean(tSNEresult(indexS,1));
    meanYstimAll(ii) = nanmean(tSNEresult(indexS,2));
    meanXstim(1,ii) = nanmean(tSNEresult(indexS1,1));
    meanXstim(2,ii) = nanmean(tSNEresult(indexS2,1));
    meanXstim(3,ii) = nanmean(tSNEresult(indexS3,1));
    meanXstim(4,ii) = nanmean(tSNEresult(indexS4,1));
    meanXstim(5,ii) = nanmean(tSNEresult(indexS5,1)); 
    meanYstim(1,ii) = nanmean(tSNEresult(indexS1,2));
    meanYstim(2,ii) = nanmean(tSNEresult(indexS2,2));
    meanYstim(3,ii) = nanmean(tSNEresult(indexS3,2));
    meanYstim(4,ii) = nanmean(tSNEresult(indexS4,2));
    meanYstim(5,ii) = nanmean(tSNEresult(indexS5,2));
    seXstimAll(ii) = nanstd(tSNEresult(indexS,1))/sqrt(sum(indexS));
    seYstimAll(ii) = nanstd(tSNEresult(indexS,2))/sqrt(sum(indexS));
    seXstim(1,ii) = nanstd(tSNEresult(indexS1,1))/sqrt(sum(indexS1));
    seXstim(2,ii) = nanstd(tSNEresult(indexS2,1))/sqrt(sum(indexS2));
    seXstim(3,ii) = nanstd(tSNEresult(indexS3,1))/sqrt(sum(indexS3));
    seXstim(4,ii) = nanstd(tSNEresult(indexS4,1))/sqrt(sum(indexS4));
    seXstim(5,ii) = nanstd(tSNEresult(indexS5,1))/sqrt(sum(indexS5));  
    seYstim(1,ii) = nanstd(tSNEresult(indexS1,2))/sqrt(sum(indexS1));
    seYstim(2,ii) = nanstd(tSNEresult(indexS2,2))/sqrt(sum(indexS2));
    seYstim(3,ii) = nanstd(tSNEresult(indexS3,2))/sqrt(sum(indexS3));
    seYstim(4,ii) = nanstd(tSNEresult(indexS4,2))/sqrt(sum(indexS4));
    seYstim(5,ii) = nanstd(tSNEresult(indexS5,2))/sqrt(sum(indexS5));
 
    % plot
    subplot(2,3,1);
    plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
        [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
        [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
        '-', 'LineWidth', 2,'Color','r')
    subplot(2,3,2);
%     plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
%         [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
%         [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
%         '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(1,ii)-seXstim(1,ii),meanXstim(1,ii)+seXstim(1,ii)], ...
        [meanYstim(1,ii),meanYstim(1,ii)], [meanXstim(1,ii),meanXstim(1,ii)], ...
        [meanYstim(1,ii)-seYstim(1,ii),meanYstim(1,ii)+seYstim(1,ii)], ...
        '-', 'LineWidth', 2, 'Color', myColors(ii,:))
    subplot(2,3,3)
%     plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
%         [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
%         [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
%         '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(2,ii)-seXstim(2,ii),meanXstim(2,ii)+seXstim(2,ii)], ...
        [meanYstim(2,ii),meanYstim(2,ii)], [meanXstim(2,ii),meanXstim(2,ii)], ...
        [meanYstim(2,ii)-seYstim(2,ii),meanYstim(2,ii)+seYstim(2,ii)], ...
        '-', 'LineWidth', 2, 'Color', myColors(ii,:))
    subplot(2,3,4);
%     plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
%         [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
%         [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
%         '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(3,ii)-seXstim(3,ii),meanXstim(3,ii)+seXstim(3,ii)], ...
        [meanYstim(3,ii),meanYstim(3,ii)], [meanXstim(3,ii),meanXstim(3,ii)], ...
        [meanYstim(3,ii)-seYstim(3,ii),meanYstim(3,ii)+seYstim(3,ii)], ...
        '-', 'LineWidth', 2, 'Color', myColors(ii,:))
    subplot(2,3,5);
%     plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
%         [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
%         [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
%         '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(4,ii)-seXstim(4,ii),meanXstim(4,ii)+seXstim(4,ii)], ...
        [meanYstim(4,ii),meanYstim(4,ii)], [meanXstim(4,ii),meanXstim(4,ii)], ...
        [meanYstim(4,ii)-seYstim(4,ii),meanYstim(4,ii)+seYstim(4,ii)], ...
        '-', 'LineWidth', 2, 'Color', myColors(ii,:))
    subplot(2,3,6);
%     plot([meanXstimAll(ii)-seXstimAll(ii),meanXstimAll(ii)+seXstimAll(ii)], ...
%         [meanYstimAll(ii),meanYstimAll(ii)], [meanXstimAll(ii),meanXstimAll(ii)], ...
%         [meanYstimAll(ii)-seYstimAll(ii),meanYstimAll(ii)+seYstimAll(ii)], ...
%         '-', 'LineWidth', 2,'Color','k')
    plot([meanXstim(5,ii)-seXstim(5,ii),meanXstim(5,ii)+seXstim(5,ii)], ...
        [meanYstim(5,ii),meanYstim(5,ii)], [meanXstim(5,ii),meanXstim(5,ii)], ...
        [meanYstim(5,ii)-seYstim(5,ii),meanYstim(5,ii)+seYstim(5,ii)], ...
        '-', 'LineWidth', 2, 'Color', myColors(ii,:))
        
end
