
% Fig3ab

% Reproduces Figure 3a and Figure 3b

% Load data
% Get two sets of features: selected sequentially or selected individually
% For the two sets, make predictions for 1 to 100 features and get MSE
% Plot MSE over the number of features for the two sets
% Predict age from the model and plot results


%% load data

% set directory
% directory = 'F:\Ageing datasets\';
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info;
load ([directory 'inputAgesLeftInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
load ([directory 'inputNamesInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulation data
inputData = inputData(indexS,:);
inputAgesLeft = inputAgesLeft(indexS);
inputNames = inputNames(indexS);

% get unique data
uniqueAgesLeft = unique(inputAgesLeft);
uniqueNames = unique(inputNames);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);


%% split dataset into train and test sets

% Here, dataset is split according to individuals

% set rng for reproducibility
rng = 3455;

% number to train (80%)
numberTrain = round(numel(uniqueNames)*0.8);
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
trainAgesLeft = inputAgesLeft(indexTrain);
testData = normData(indexTest,:);
testAgesLeft = inputAgesLeft(indexTest);
testNames = inputNames(indexTest);


%% test different number of features

% Select features sequentially to obtain the best combination of features
% for prediction

% get number of features to test
nbFeat = 1:100;

% initialise variables to store prediction RMSE and features
predMSE = NaN(numel(nbFeat),1);
myFeatCum = NaN(numel(nbFeat),1);

% set features
myFeatures = 1:numel(inputFeatNames);
myFeatTest = [];

% loop through number of features to test
for ii = 1:numel(nbFeat)
    
    % initialise variable to store prediction RMSE
    myPredMSE = NaN(numel(myFeatures),1);
    
    % loop through all remaining features
    for jj = 1:numel(myFeatures)
        
        disp([ii jj])
        
        % select next feature
        myFeat = myFeatures(jj);
        myFeatTest = [myFeatCum;myFeat];
        myFeatTest = myFeatTest(~isnan(myFeatTest));
        
        % train SVM
        myModel = fitrsvm(trainData(:,myFeatTest),trainAgesLeft);
        
        % predict
        predValues = predict(myModel,testData(:,myFeatTest));
        
        % get predMSE
        myPredMSE(jj) = sqrt(nanmean((testAgesLeft - predValues).^2));
        
    end
    
    % identify best MSE and feature
    [bestMSE,indexBest] = min(myPredMSE);
    bestFeat = myFeatures(indexBest);
        
    % store info and update variables  
    predMSE(ii) = bestMSE;
    myFeatCum(ii) = bestFeat;
    myFeatures = setdiff(myFeatures,myFeatCum);
    
end


%% make prediction from each individual feature

% initialise variable to store MSE
predMSE2 = NaN(numel(inputFeatNames),1);

% loop through features
for ii = 1:numel(inputFeatNames)
    
    disp(ii)
    
    % train svm
    myModel = fitrsvm(trainData(:,ii),trainAgesLeft);
    
    % predict
    predValues = predict(myModel,testData(:,ii));
    
    % get predMSE
    predMSE2(ii) = sqrt(nanmean((testAgesLeft - predValues).^2));
    
end
 

%% sort individual features by predMSE and make predictions from best features

% sort features
[~,indexSort] = sort(predMSE2);
sortedFeat = inputFeatNames(indexSort);

% initialise variable to store MSE
predMSEind = NaN(100,1);

% predict for 1 to 100 features
for ii = 1:100
    
    disp(ii)
    
    % select features
    myFeat = indexSort(1:ii);

    % train svm
    myModel = fitrsvm(trainData(:,myFeat),trainAgesLeft);
    
    % predict
    predValues = predict(myModel,testData(:,myFeat));
    
    % get predMSE
    predMSEind(ii) = sqrt(nanmean((testAgesLeft - predValues).^2));
    
end


%% make predictions again with the best iterative features

% initialise variable to store MSE
predMSEcum = NaN(100,1);

% predict for 1 to 100 features
for ii = 1:100
    
    disp(ii)
    
    % select features
    myFeat = myFeatCum(1:ii);

    % train svm
    myModel = fitrsvm(trainData(:,myFeat),trainAgesLeft);
    
    % predict
    predValues = predict(myModel,testData(:,myFeat));
    
    % get predMSE
    predMSEcum(ii) = sqrt(nanmean((testAgesLeft - predValues).^2));
    
end


%% plot results

plot(1:100,predMSEind,'Linewidth',2);
hold on;
plot(1:100,predMSEcum,'Linewidth',2);
hold off;
xlabel('Number of features','Fontsize',16);
ylabel('RMSE (days)','Fontsize',16);
title('Prognosis prediction','Fontsize',18);
legend('Individual features','Iteration')


%% Make prediction with 100 best features selected sequentially

% train SVM
myModel = fitrsvm(trainData(:,myFeatCum),trainAgesLeft);

% predict
predValues = predict(myModel,testData(:,myFeatCum));

% get RMSE
predRMSE = sqrt(nanmean((testAgesLeft - predValues).^2));
        
% plot
figure;
scatter(testAgesLeft,predValues);
hold on;
plot(testAgesLeft,testAgesLeft,'Linewidth',2);
hold off;
xlabel('Real remaining days (days)','Fontsize',16)
ylabel('Predicted values (days)','Fontsize',16)


%% Get R2

[fitobject,gof] = fit(testAgesLeft,predValues,'poly1');


%% Make prediction with all features

% train SVM
myModel = fitrsvm(trainData,trainAgesLeft);

% predict
predValues = predict(myModel,testData);

% get RMSE
predRMSEall = sqrt(nanmean((testAgesLeft - predValues).^2));
