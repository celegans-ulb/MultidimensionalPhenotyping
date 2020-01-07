
% Fig 6e

% Reproduces Figure 6e

% Load data
% Split dataset into train and test sets and predict prognosis 
% For each animal of the test set, determine the average deviation of the
% prognosis from a neutral decline, as in Zhang et al.


%% load data

% set directory
% directory = 'G:\Ageing datasets\';
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputNamesInterpDrop']);
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesLeftInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
inputAgesRelRound = round(inputAgesRel*10)/10;
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);
% load predictive features
% load ('G:\AGEING\Ageing_Scripts\myFeatCumAge100');


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);
inputAgesRel = inputAgesRel(indexS);
inputAgesRelRound = inputAgesRelRound(indexS);
inputAgesLeft = inputAgesLeft(indexS);
inputLifespans = inputLifespans(indexS);
inputTreatments = inputTreatments(indexS);
inputNames = inputNames(indexS);

% get unique data
uniqueAges = unique(inputAges);
uniqueAgesRelRound = unique(inputAgesRelRound);
uniqueNames = unique(inputNames);


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


%% split dataset into train and test sets

% Here, dataset in split according to individuals, since predictions will
% be made for each individual of the test set to extract the average deviation

% set rng for reproducibility
rng = 3455;

% number to train (50%)
numberTrain = round(numel(uniqueNames)*0.5);
numberTest = numel(uniqueNames) - numberTrain;

% get indexes for train and test sets
indexNamesTrain = randperm(numel(uniqueNames),numberTrain)';
indexNamesTest = 1:numel(uniqueNames);
indexNamesTest = setdiff(indexNamesTest,indexNamesTrain);
namesTrain = uniqueNames(indexNamesTrain);
indexTrain = ismember(inputNames,namesTrain);
indexTest = indexTrain == 0;

% get sets of data
trainData = normData(indexTrain,:);
trainAges = inputAges(indexTrain);
trainAgesLeft = inputAgesLeft(indexTrain);
trainAgesRel = inputAgesRel(indexTrain);
testData = normData(indexTest,:);
testAges = inputAges(indexTest);
testAgesLeft = inputAgesLeft(indexTest);
testAgesRel = inputAgesRel(indexTest);
testAgesRelRound = inputAgesRelRound(indexTest);
testLifespans = inputLifespans(indexTest);
testLifespanGroup = inputLifespanGroup(indexTest);
testNames = inputNames(indexTest);


%% make prediction
   
disp('go')
tic
% train SVM
myModel = fitrsvm(trainData,trainAgesLeft);
toc

% predict
predValues = predict(myModel,testData);

% set minimum value to 0
predValues(predValues < 0) = 0;


%% get neutral decline

% neutral decline is defined as the straight line between initial and final
% time points

progStart = nanmean(predValues(testAgesRelRound == 0));
progEnd = nanmean(predValues(testAgesRelRound == 0.9));
neutralY = [progStart progEnd];
neutralX = [0 0.9];


%% get average deviation

% initialise variables
wormLifespan = NaN(75,1);
wormGroup = NaN(75,1);
devTotal = NaN(75,1);
devAverage = NaN(75,1);

% loop through selected worms
for ii = 1:numberTest
    
    % get index
    indexWorm = ismember(testNames,uniqueNames(indexNamesTest(ii)));
    
    % get data
    myPrognosis = predValues(indexWorm);
    myAges = testAgesRel(indexWorm);
    wormLifespan(ii) = unique(testLifespans(ii));
    wormGroup(ii) = unique(testLifespanGroup(ii));
    
    % get average deviation
    devTotal(ii) = trapz(myAges,myPrognosis) - trapz(neutralX,neutralY);
    devAverage(ii) = devTotal(ii) / wormLifespan(ii);
    
end
    

%% plot results (coloured by lifespan group)

% plot results and linear fit, get the r2 of the fit

figure;
% plot average deviation
scatter(wormLifespan(wormGroup == 1),devAverage(wormGroup == 1),[],[0 0.4470 0.7410],'filled');
hold on;
scatter(wormLifespan(wormGroup == 2),devAverage(wormGroup == 2),[],[0.8500 0.3250 0.0980],'filled');
scatter(wormLifespan(wormGroup == 3),devAverage(wormGroup == 3),[],[ 0.9290 0.6940 0.1250],'filled');
scatter(wormLifespan(wormGroup == 4),devAverage(wormGroup == 4),[],[0.4940 0.1840 0.5560],'filled');
scatter(wormLifespan(wormGroup == 5),devAverage(wormGroup == 5),[],[0.4660 0.6740 0.1880],'filled');
% get linear fit and plot
[myFit,myGof] = fit(wormLifespan,devAverage,'poly1');
plot(myFit,'k');
hold off;
xlabel('Lifespan (days)','FontSize',16);
ylabel('Average deviation (days of prognosis)','FontSize',16);

