
% Fig6abcd

% Reproduces Figure 6 a,b,c,d

% Load data
% train lasso regularization
% predict age from the model


%% load data

% set directory
directory = 'G:\Ageing datasets\';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputAgesLeftInterpDrop']);
load ([directory 'inputAgesRelInterpDrop']);
inputAgesRelRound = round(inputAgesRel*10)/10;
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
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

% get unique data
uniqueAges = unique(inputAges);
uniqueAgesRelRound = unique(inputAgesRelRound);


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

% dataset is split indpendently of individuals or ages

% set rng for reproducibility
rng = 3454;

% number to train (80%)
numberTrain = round(numel(inputAges)*0.8);

% get index for train and test sets
indexTrain = randperm(numel(inputAges),numberTrain);
indexTest = 1:numel(inputAges);
indexTest = setdiff(indexTest,indexTrain);

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
    predSeAge(ii,jj) = predStdAge(ii,jj) / sum(indexCurrent);
    
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
    predSeAgeRel(ii,jj) = predStdAgeRel(ii,jj) / sum(indexCurrent);
    
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

% get 50% of starting prognosis for each group
speed50Age = predMeanAge(:,1) / 2;
speed50AgeRel = predMeanAgeRel(:,1) /2;

% initialise variables to store healthspans
age50 = NaN(1,5);
ageRel50 = NaN(1,5);

% get healthspan
% loop through lifespan groups
for ii = 1:5
    
    % get mean prognosis and ages
    mySpeed = predMeanAge(ii,:);
    mySpeed = mySpeed(~isnan(mySpeed));
    myAges = uniqueAges(~isnan(mySpeed));
    
    mySpeedRel = predMeanAgeRel(ii,:);
    mySpeedRel = mySpeedRel(~isnan(mySpeedRel));    
    myAgesRel = uniqueAgesRelRound(~isnan(mySpeedRel));
    
    % get age at speed50 by linear interpolation
    age50(ii) = interp1(mySpeed,myAges,speed50Age(ii));
    ageRel50(ii) = interp1(mySpeedRel,myAgesRel,speed50AgeRel(ii));

end

