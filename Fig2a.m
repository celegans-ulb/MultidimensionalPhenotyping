
% Fig 2a

% Reproduces Figure 2a

% Load data
% Get mean feature over age for each lifespan group
% Plot results


%% load data

% set directory
directory = '/Volumes/AGEiNG/Ageing datasets/';

% load data
load ([directory 'inputDataInterpDrop']);
% load worm info
load ([directory 'inputAgesInterpDrop']);
load ([directory 'inputLifespansInterpDrop']);
load ([directory 'inputTreatmentsInterpDrop']);
% load feature info
load ([directory 'inputFeatNamesInterpDrop']);


%% drop basal data

% get index
indexS = ismember(inputTreatments,'S');

% keep only stimulated data
inputData = inputData(indexS,:);
inputAges = inputAges(indexS);
inputLifespans = inputLifespans(indexS);

% get unique data
uniqueAges = unique(inputAges);


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


%% get mean feature over age for each lifespan group

% SELECT FEATURE NUMBER
myFeature = 521;

% initialise variables
meanData = NaN(numel(uniqueLifespanGroups),numel(uniqueAges));
stdData = NaN(numel(uniqueLifespanGroups),numel(uniqueAges));
seData = NaN(numel(uniqueLifespanGroups),numel(uniqueAges));

% loop through lifespan groups
for ii = 1:numel(uniqueLifespanGroups)
    
    % loop through ages
    for jj = 1:numel(uniqueAges)
        
        % get index
        indexCurrent = inputLifespanGroup == uniqueLifespanGroups(ii) & ...
            inputAges == uniqueAges(jj);
        
        % get mean data
        meanData(ii,jj) = nanmean(inputData(indexCurrent,myFeature)); 
        stdData(ii,jj) = nanstd(inputData(indexCurrent,myFeature));
        seData(ii,jj) = stdData(ii,jj) / sqrt(sum(indexCurrent));
    
    
    end
    
end


%% plot results with standard errors

% set colors for plotting
myColors = [0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840];

figure;
% loop through lifespan groups to plot mean
for ii = 1:5
    plot(uniqueAges,meanData(ii,:),'Color',myColors(ii,:),'LineWidth',2);
    hold on
end

% loop through lifespan groups to plot standard error
for ii = 1:5
    
    myAges = uniqueAges(~isnan(meanData(ii,:)));
    myHI = meanData(ii,:);
    myHI = myHI(~isnan(myHI));
    mySE = seData(ii,:);
    mySE = mySE(~isnan(mySE));
    patch([myAges;flipud(myAges)], ...
        [myHI + mySE,fliplr(myHI - mySE)], ...
        myColors(ii,:),'FaceAlpha', 0.1, 'EdgeColor', 'none');
end

xlabel('Age (days)','Fontsize',16);
% ylabel('Length 90th (AU)','Fontsize',16);
% ylabel('Curvature midbody 90th (AU)','Fontsize',16);
% ylabel('Speed midbody 90th (AU)','Fontsize',16);
ylabel('Path density midbody 50th (AU)','Fontsize',16);
hold off


