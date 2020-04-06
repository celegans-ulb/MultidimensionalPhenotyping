
% Fig6abcd

% Reproduces Figure 6 a,b,c,d

% Load data
% train svm
% predict prognosis from the model


%% load data

% set directory
% directory = 'G:\Ageing datasets\';
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesLeftInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
inputAgesRelRound = round(inputAgesRel*10)/10;
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
load ([directory 'inputNamesInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);
% load predictive features
%load ('G:\AGEING\Ageing_Scripts\myFeatCumAge100');


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

% get unique groups
uniqueLifespanGroups = unique(inputLifespanGroup);


%% split dataset into train and test sets

% Here, dataset is split according to individuals

% set rng for reproducibility
rng = 3455;

% number to train (80%)
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

 
%% get predictions per lifespan group

% initialise variables
predMeanAge = NaN(5,numel(uniqueAges));
predStdAge = NaN(5,numel(uniqueAges));
predSeAge = NaN(5,numel(uniqueAges));
predMeanAgeRel = NaN(5,numel(uniqueAgesRelRound));
predStdAgeRel = NaN(5,numel(uniqueAgesRelRound));
predSeAgeRel = NaN(5,numel(uniqueAgesRelRound));

% loop through lifespan groups
for ii = 1:5
    
    % loop through ages
    for jj = 1:numel(uniqueAges)
    
    % get index
    indexCurrent = testLifespanGroup == ii & testAges == uniqueAges(jj);
    
    % get data
    predMeanAge(ii,jj) = nanmean(predValues(indexCurrent));
    predStdAge(ii,jj) = nanstd(predValues(indexCurrent));
    predSeAge(ii,jj) = predStdAge(ii,jj) / sqrt(sum(indexCurrent));
    
    end

end

% loop through lifespan groups
for ii = 1:5
    
    % loop through ages
    for jj = 1:numel(uniqueAgesRelRound)
    
    % get index
    indexCurrent = testLifespanGroup == ii & testAgesRelRound == uniqueAgesRelRound(jj);
    
    % get data
    predMeanAgeRel(ii,jj) = nanmean(predValues(indexCurrent));
    predStdAgeRel(ii,jj) = nanstd(predValues(indexCurrent));
    predSeAgeRel(ii,jj) = predStdAgeRel(ii,jj) / sqrt(sum(indexCurrent));
    
    end

end


%% plot results with standard error

% set colors for plotting
myColors = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840];

% plot prognosis over age
figure;
% loop through lifespan groups to plot mean
for ii = 1:5
    plot(uniqueAges,predMeanAge(ii,:),'Color',myColors(ii,:),'LineWidth',2);
    hold on
end
% loop through lifespan groups to plot standard error
for ii = 1:5
    
    myAges = uniqueAges(~isnan(predMeanAge(ii,:)));
    myHI = predMeanAge(ii,:);
    myHI = myHI(~isnan(myHI));
    mySE = predSeAge(ii,:);
    mySE = mySE(~isnan(mySE));
    patch([myAges;flipud(myAges)], ...
        [myHI + mySE,fliplr(myHI - mySE)], ...
        myColors(ii,:),'FaceAlpha', 0.1, 'EdgeColor', 'none');
end
xlabel('Age (days)','Fontsize',16);
ylabel('Prognosis (days)','Fontsize',16);
xlim([0 25])
hold off

% plot prognosis over relative age
figure;
% loop through lifespan groups to plot mean
for ii = 1:5
    plot(uniqueAgesRelRound,predMeanAgeRel(ii,:),'Color',myColors(ii,:),'LineWidth',2);
    hold on
end
% loop through lifespan groups to plot standard error
for ii = 1:5
    
    myAges = uniqueAgesRelRound(~isnan(predMeanAgeRel(ii,:)));
    myHI = predMeanAgeRel(ii,:);
    myHI = myHI(~isnan(myHI));
    mySE = predSeAgeRel(ii,:);
    mySE = mySE(~isnan(mySE));
    patch([myAges;flipud(myAges)], ...
        [myHI + mySE,fliplr(myHI - mySE)], ...
        myColors(ii,:),'FaceAlpha', 0.1, 'EdgeColor', 'none');
end
xlabel('Relative age','Fontsize',16);
ylabel('Prognosis (days)','Fontsize',16);
xlim([0 1])
hold off


%% get healthspan and gerospan

% get unique test names
uniqueTestNames = unique(testNames);

% initialise variables to store results
age50 = NaN(numel(uniqueTestNames),1);
age50Rel = NaN(numel(uniqueTestNames),1);
wormLifespanGroup = NaN(numel(uniqueTestNames),1);

% loop through worms
for ii = 1:numel(uniqueTestNames)
    
    % get data
    myAges = testAges(ismember(testNames,uniqueTestNames{ii}));
    myAgesRel = testAgesRel(ismember(testNames,uniqueTestNames{ii}));
    myPred = predValues(ismember(testNames,uniqueTestNames{ii}));
    myPredSmooth = smooth(myPred);
    wormLifespanGroup(ii) = unique(testLifespanGroup(ismember(testNames,uniqueTestNames{ii})));
 
    % drop worms that miss the L4 data
    if min(myAges) == 0
    
    % get initial prognosis
    progInitAge = myPred(myAges == 0);
    progInitAgeRel = myPred(myAgesRel == 0);
    
    % get 50% of starting prognosis
    prog50Age = myPred(myAges == 0) / 2;
    prog50AgeRel = myPred(myAgesRel == 0) / 2;
    
    % get age at speed50 by linear interpolation
    age50(ii) = interp1(myPredSmooth,myAges,prog50Age);
    % B = interp1(myPredSmooth,myAges,prog50Age)
    age50Rel(ii) = interp1(myPredSmooth,myAgesRel,prog50AgeRel);
    
    else
        continue
        
    end
    
end


%% sort results per lifespan group

% initialise variables to store results
age50Sort = NaN(numel(uniqueTestNames),5);
age50RelSort = NaN(numel(uniqueTestNames),5);

% loop through lifespan groups
for ii = 1:numel(uniqueLifespanGroups)
    
    % get data
    myAge50 = age50(wormLifespanGroup == uniqueLifespanGroups(ii));
    myAge50Rel = age50Rel(wormLifespanGroup == uniqueLifespanGroups(ii));
    
    % assign data
    age50Sort(1:numel(myAge50),ii) = myAge50;
    age50RelSort(1:numel(myAge50Rel),ii) = myAge50Rel;

end