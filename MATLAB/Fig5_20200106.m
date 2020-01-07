
% Fig5

% Reproduces Fifure 5a and 5b
% Get data for figure 5c

% Load data
% Do PCA analysis
% Plot PC1 over age and over relative age for each lifespan group
% Get an approximation of ageing speed (mean of the first derivative) for
% each worm, sorted by lifespan group 


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
inputAgesRelRound = inputAgesRelRound(indexS);
inputLifespans = inputLifespans(indexS);
inputNames = inputNames(indexS);

% get unique data
uniqueAges = unique(inputAges);
uniqueAgesRelRound = unique(inputAgesRelRound);
[uniqueNames,indexUnique] = unique(inputNames);


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


%% Get PC1 over age and relative age

% initialise variables
meanAge = NaN(5,numel(uniqueAges));
stdAge = NaN(5,numel(uniqueAges));
seAge = NaN(5,numel(uniqueAges));
meanAgeRel = NaN(5,numel(uniqueAgesRelRound));
stdAgeRel = NaN(5,numel(uniqueAgesRelRound));
seAgeRel = NaN(5,numel(uniqueAgesRelRound));

% loop through lifespan groups
for ii = 1:5
    
    % loop through ages
    for jj = 1:numel(uniqueAges)
    
    % get index
    indexCurrent = inputLifespanGroup == ii & inputAges == uniqueAges(jj);
    
    % get data
    meanAge(ii,jj) = nanmean(PCAscore(indexCurrent,1));
    stdAge(ii,jj) = nanstd(PCAscore(indexCurrent,1));
    seAge(ii,jj) = stdAge(ii,jj) / sum(indexCurrent);
    
    end

end

% loop through lifespan groups
for ii = 1:5
    
    % loop through ages
    for jj = 1:numel(uniqueAgesRelRound)
    
    % get index
    indexCurrent = inputLifespanGroup == ii & inputAgesRelRound == uniqueAgesRelRound(jj);
    
    % get data
    meanAgeRel(ii,jj) = nanmean(PCAscore(indexCurrent,1));
    stdAgeRel(ii,jj) = nanstd(PCAscore(indexCurrent,1));
    seAgeRel(ii,jj) = stdAgeRel(ii,jj) / sum(indexCurrent);
    
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

% plot PC1 over age
figure;
% loop through lifespan groups to plot mean
for ii = 1:5
    plot(uniqueAges,meanAge(ii,:),'Color',myColors(ii,:),'LineWidth',2);
    hold on
end
% loop through lifespan groups to plot standard error
for ii = 1:5
    
    myAges = uniqueAges(~isnan(meanAge(ii,:)));
    myHI = meanAge(ii,:);
    myHI = myHI(~isnan(myHI));
    mySE = seAge(ii,:);
    mySE = mySE(~isnan(mySE));
    patch([myAges;flipud(myAges)], ...
        [myHI + mySE,fliplr(myHI - mySE)], ...
        myColors(ii,:),'FaceAlpha', 0.1, 'EdgeColor', 'none');
end
xlabel('Age (days)','Fontsize',16);
ylabel('PC1','Fontsize',16);
xlim([0 25])
hold off

% plot PC1 over relative age
figure;
% loop through lifespan groups to plot mean
for ii = 1:5
    plot(uniqueAgesRelRound,meanAgeRel(ii,:),'Color',myColors(ii,:),'LineWidth',2);
    hold on
end
% loop through lifespan groups to plot standard error
for ii = 1:5
    
    myAges = uniqueAgesRelRound(~isnan(meanAgeRel(ii,:)));
    myHI = meanAgeRel(ii,:);
    myHI = myHI(~isnan(myHI));
    mySE = seAgeRel(ii,:);
    mySE = mySE(~isnan(mySE));
    patch([myAges;flipud(myAges)], ...
        [myHI + mySE,fliplr(myHI - mySE)], ...
        myColors(ii,:),'FaceAlpha', 0.1, 'EdgeColor', 'none');
end

xlabel('Relative age','Fontsize',16);
ylabel('PC1','Fontsize',16);
xlim([0 1])
hold off


%% get ageing speed per lifespan group (PC1 over age)

% make an approximation of the mean speed from the first derivative

% get unique ID for worms
uniqueNames = unique(inputNames);

% initialise variable to store data
ageingSpeed = NaN(numel(uniqueNames),1);

% loop through worms
for ii = 1:numel(uniqueNames)
    
    % get index
    indexCurrent = ismember(inputNames,uniqueNames{ii});
    
    % get data
    myData = PCAscore(indexCurrent,1);
    myAges = inputAges(indexCurrent);
    
    % get first derrivative
    ageingSpeed(ii) = nanmean(diff(myData));
    
end

% get mean speed and std and se per lifespan group
% initialise variable to store data
ageingSpeedSorted = NaN(150,5);
% loop through lifespan groups
for ii = 1:5
    
    % get index
    indexCurrent = wormLifespanGroup == uniqueLifespanGroups(ii);
    
    % get data sorted by lifespan group > DATA TO PLOT IN Prism
    myData = ageingSpeed(indexCurrent);
    ageingSpeedSorted(1:numel(myData),ii) = myData;

end




    
