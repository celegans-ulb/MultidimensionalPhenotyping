
% Fig3ab

% Reproduces Figure 3a and Figure 3b

% Load data
% Get two sets of features: selected sequntially or selected individually
% For the two sets, make predictions for 1 to 100 features and get MSE
% Plot MSE over the number of features for the two sets
% Predict age from the model and plot results


%% load data

% set directory
directory = 'F:\Ageing datasets\';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info;
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulation data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);

% get unique data
uniqueAges = unique(inputAges);


%% normalise data

% get mean and standard deviation
dataMean = nanmean(inputData,1);
dataStd = nanstd(inputData,1);

% normalise data
normData = bsxfun(@rdivide,bsxfun(@minus,inputData,dataMean),dataStd);


%% split dataset into train and test sets

% select 80% of the dataset (independently of the individuals or of the
% age) for training and use the rest for testing

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
testData = normData(indexTest,:);
testAges = inputAges(indexTest);


%% test different number of features

% Select features sequentially to obtain the best combination of features
% for prediction

% get number of features to test
nbFeat = 1:100;

% initialise variables to store prediction MSE and features
predMSE = NaN(numel(nbFeat),1);
myFeatCum = NaN(numel(nbFeat),1);

% set features
myFeatures = 1:numel(inputFeatNames);
myFeatTest = [];

% loop through number of features to test
for ii = 1:numel(nbFeat)
    
    % initialise variable to store prediction MSE
    myPredMSE = NaN(numel(myFeatures),1);
    
    % loop through all remaining features
    for jj = 1:numel(myFeatures)
        
        disp([ii jj])
        
        % select next feature
        myFeat = myFeatures(jj);
        myFeatTest = [myFeatCum;myFeat];
        myFeatTest = myFeatTest(~isnan(myFeatTest));
        
        % train SVM
        myModel = fitrsvm(trainData(:,myFeatTest),trainAges);
        
        % predict
        predValues = predict(myModel,testData(:,myFeatTest));
        
        % get predMSE
        myPredMSE(jj) = nanmean((testAges - predValues).^2);
        
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
predMSE = NaN(numel(inputFeatNames),1);

% loop through features
for ii = 1:numel(inputFeatNames)
    
    disp(ii)
    
    % train svm
    myModel = fitrsvm(trainData(:,ii),trainAges);
    
    % predict
    predValues = predict(myModel,testData(:,ii));
    
    % get predMSE
    predMSE(ii) = nanmean((testAges - predValues).^2);
    
end
 

%% sort individual features by predMSE and make predictions from best features

% sort features
[~,indexSort] = sort(predMSE);
sortedFeat = inputFeatNames(indexSort);

% initialise variable to store MSE
predMSEind = NaN(100,1);

% predict for 1 to 100 features
for ii = 1:100
    
    disp(ii)
    
    % select features
    myFeat = indexSort(1:ii);

    % train svm
    myModel = fitrsvm(trainData(:,myFeat),trainAges);
    
    % predict
    predValues = predict(myModel,testData(:,myFeat));
    
    % get predMSE
    predMSEind(ii) = nanmean((testAges - predValues).^2);
    
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
    myModel = fitrsvm(trainData(:,myFeat),trainAges);
    
    % predict
    predValues = predict(myModel,testData(:,myFeat));
    
    % get predMSE
    predMSEcum(ii) = nanmean((testAges - predValues).^2);
    
end


%% plot results

plot(1:100,predMSEind);
hold on;
plot(1:100,predMSEcum);
hold off;
xlabel('Number of features');
ylabel('MSE (days)');
title('Age prediction');
legend('Individual features','Iteration')


%% Make prediction with 100 best features selected sequentially

% train SVM
myModel = fitrsvm(trainData(:,myFeatCum),trainAges);

% predict
predValues = predict(myModel,testData(:,myFeatCum));

% get RMSE
predRMSE = sqrt(nanmean((testAges - predValues).^2));
        
% plot
figure;
scatter(testAges,predValues);
hold on;
plot(testAges,testAges);
hold off;
xlabel('Real age')
ylabel('Predicted values')

