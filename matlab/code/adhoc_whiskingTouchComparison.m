%Load whisking and neural time series struct
clear
load('C:\Users\jacheung\Dropbox\LocationCode\DataStructs\excitatory.mat') %L5b excitatory cells
% load('C:\Users\jacheung\Dropbox\LocationCode\DataStructs\interneurons.mat') %L5b inhibitory cells
%% Top level parameters and definitions
touchWindow = [-25:50]; %window for analyses around touch

touchCells = touchCell(U,'off');
selectedCells = find(touchCells==1);

% Structure for quantifying tuning and evaluating decoding
popV = touchFeatureBinned(U,touchWindow);

% Defining touch response
U = defTouchResponse(U,.99,'off');

%% Quantifying object location tuning
whichTouches = fields(popV{1});
fieldsList = fields(popV{1}.allTouches);
tuneStruct = tuningQuantification(U,popV,selectedCells,fieldsList([ 1 3 4 5]),whichTouches,touchWindow,'off');

%% Quantifying whisking tuning
whisking = whisking_general(U,'off');

hilbertWhisking = whisking_hilbert(U,popV,'off');

%% comparison adHoc
fieldsToCompare = fields(tuneStruct.R_ntk.allTouches);
selectedCells = find(touchCells==1); %look at only touch cells because those are the only ones w/ OL tuning

for g = 1:4
    
    currTArray = tuneStruct.R_ntk.allTouches.(fieldsToCompare{g});
    currWArray = hilbertWhisking.R_ntk.(fieldsToCompare{g});
    stimulus = hilbertWhisking.S_ctk.(fieldsToCompare{g});
    
    chosenTArrays = currTArray(selectedCells);
    TouchR = cellfun(@(x) nanmean(x,2),chosenTArrays,'uniformoutput',0);
    TouchSEM = cellfun(@(x) nanstd(x,[],2) ./ sqrt(sum(~isnan(x),2)),chosenTArrays,'uniformoutput',0);
    chosenWArrays = currWArray(selectedCells);
    WhiskR = cellfun(@(x) nanmean(x,1),chosenWArrays,'uniformoutput',0);
    WhiskSEM = cellfun(@(x) nanstd(x)./sqrt(sum(~isnan(x))),chosenWArrays,'uniformoutput',0);
    
%     for i = 1:length(WhiskR)
%         figure(23+g);subplot(4,8,i)
%         shadedErrorBar(stimulus,TouchR{i}*1000,TouchSEM{i}*1000,'b')
%         hold on; shadedErrorBar(stimulus,WhiskR{i}*1000,WhiskSEM{i}*1000,'r')
%         xBounds = stimulus(~isnan(TouchR{i}*1000));
%         set(gca,'xlim',[min(xBounds) max(xBounds)])
%         
%     end
%     
%     suptitle(fieldsToCompare{g})
%     print(['C:\Users\jacheung\Dropbox\LocationCode\Figures\hilbertCode\Hilbert_whiskingTouch\' fieldsToCompare{g}],'-dpng')
%     
    
    figure(30);
    subplot(2,2,g)
    scatter(cell2mat(WhiskR)*1000,cell2mat(TouchR')*1000,'k')
    allMat = [(cell2mat(WhiskR)*1000)' ; cell2mat(TouchR')*1000];
    minMax(1) = min(allMat)
    minMax(2) = prctile(allMat,99); 
    hold on; plot(minMax,minMax,'-.k')
    set(gca,'xlim',minMax,'ylim',minMax)
    axis square
    title(fieldsToCompare{g})
    
end
%% comparison
naiveVSexpert = cellfun(@(x) strcmp(x.meta.layer,'BVL5b'),U);

wEXCOL = numel(intersect(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1),find(whisking.matrix(1,:) == 1))) ./ numel(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1)) ;
wINHOL = numel(intersect(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1),find(whisking.matrix(1,:) == -1))) ./ numel(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1));
nsOL = numel(intersect(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1),find(whisking.matrix(1,:) == 0))) ./ numel(find(tuneStruct.populationQuant.theta.matrix(1,:) == 1));



wEXCexpert = numel(intersect(find(naiveVSexpert==1),find(whisking.matrix(1,:) == 1))) ./ sum(naiveVSexpert==1);
wEXCnaive = numel(intersect(find(naiveVSexpert==0),find(whisking.matrix(1,:) == 1))) ./ sum(naiveVSexpert==0);

wINHexpert = numel(intersect(find(naiveVSexpert==1),find(whisking.matrix(1,:) == -1))) ./ sum(naiveVSexpert==1);
wINHnaive = numel(intersect(find(naiveVSexpert==0),find(whisking.matrix(1,:) == -1))) ./ sum(naiveVSexpert==0);

nsexpert = numel(intersect(find(naiveVSexpert==1),find(whisking.matrix(1,:) == 0))) ./ sum(naiveVSexpert==1);
nsnaive = numel(intersect(find(naiveVSexpert==0),find(whisking.matrix(1,:) == 0))) ./ sum(naiveVSexpert==0);