%% QUANTIFICATION OF MODEL PARAMETERS
touchWindow = [-25:50]; %window for analyses around touch
popV = touchFeatureBinned(U,touchWindow);
touchOrderFields = fields(popV{1});
whichTouches = 1; 

% Defining touch response
U = defTouchResponse(U,.99);

%%
for i = 1:length(glmModel)
    
    array = U{glmModel{i}.meta};
    BI = glmModel{i}.modelParams.buildIndices;
    touchResp = array.meta.responseWindow;
    
    %PLOTTING BASIS FUNCTIONS
    %     figure(480);clf
    %     subplot(2,1,1)
    %     plot(glmModel{i}.modelParams.buildIndices,glmModel{1}.basisFunctions.touch,'k')
    %     subplot(2,1,2)
    %     plot(glmModel{i}.modelParams.buildIndices,glmModel{1}.basisFunctions.features,'k')
    %
    %PLOTTING FOR time from touch onset
    %     figure(800);subplot(5,6,i)
    
    figure(5480);clf
    subplot(3,3,[2 3])
    hold on;plot(BI,smooth(mean(glmModel{i}.predicted.spikeTestRaw *1000,1),glmModel{i}.modelParams.bf.bfwidth),'k','linewidth',2)
    hold on;plot(BI,mean(glmModel{i}.predicted.spikeProb *1000,1),'r','linewidth',2)
    ylabel('firing rate (hz)')
    title(['original(black) | modeled(red). Touch response. Rsqd = ' num2str(corr(smooth(mean(glmModel{i}.predicted.spikeTestRaw *1000,1)'),mean(glmModel{i}.predicted.spikeProb *1000,1)').^2)]);
    set(gca,'xtick',[])
    
    %     figure(484);subplot(2,1,2);
    %     hold on;
    %     plot(BI,smooth(std(glmModel{i}.predicted.spikeTestRaw )*1000,length(basisFunction)),'k')
    %     plot(BI,std(glmModel{i}.predicted.spikeProb )*1000,'b')
    %     title('variance of real(black) vs model(blue)')
    %     xlabel('time from touch onset')
    %
    
    %plotting of original heatmap
    %toss touches out that are >10 degree difference from nearest bin.
    
    gaussFilt = 2;
    sampledAngles = glmModel{i}.heat.angle;
    anglePlotSpacing = 3;
    tuningPrctile = 99;
    countsThresh = 10;
    
    
    selThetaBins = popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.range(popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.counts>=countsThresh);
    selectedBins = ismember(glmModel{i}.heat.angle,selThetaBins)    ;
    selRawMat = glmModel{i}.heat.matrixRaw([min(find(selectedBins)):max(find(selectedBins))],:);
    selMdlMat = glmModel{i}.heat.matrix([min(find(selectedBins)):max(find(selectedBins))],:);
    
    rawThetaIdx = ismember(popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.range,selThetaBins);
    rawTheta = popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.range(rawThetaIdx);
    rawMap= popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.spikes;
    
    subplot(3,3,1)
    imagesc(imgaussfilt(rawMap(rawThetaIdx,:),gaussFilt,'padding','replicate'));
    hold on;plot([find(BI==0)-1 find(BI==0)-1],[size(glmModel{i}.heat.matrixRaw,1) 0],'w:')
    set(gca,'ytick',1:anglePlotSpacing:length(rawTheta),'yticklabel', rawTheta(1:anglePlotSpacing:length(rawTheta)),'ydir','normal',...
        'xtick',(0:25:length(BI)),'xticklabel',[min(BI):25:max(BI)],'xlim',[0 length(BI)])
    ylabel('angle at touch')
    title('original tuning curve')
    
    subplot(3,3,4)
    imagesc(imgaussfilt(selRawMat,gaussFilt,'padding','replicate'));
    %     caxis([0 prctile(selRawMat(:),99)])
    hold on;plot([find(BI==0)-1 find(BI==0)-1],[size(glmModel{i}.heat.matrixRaw,1) 0],'w:')
    set(gca,'ytick',1:anglePlotSpacing:length(selThetaBins),'yticklabel', selThetaBins(1:anglePlotSpacing:length(selThetaBins)),'ydir','normal',...
        'xtick',(0:25:length(BI)),'xticklabel',[min(BI):25:max(BI)],'xlim',[0 length(BI)])
    ylabel('angle at touch')
    title('training tuning curve')
    hold on; plot([find(BI==touchResp(1)) find(BI==touchResp(1))],[0 length(selThetaBins)+1],'r-.')
    hold on; plot([find(BI==touchResp(2)) find(BI==touchResp(2))],[0 length(selThetaBins)+1],'r-.')
    
    subplot(3,3,7)
    imagesc(imgaussfilt(selMdlMat,gaussFilt,'padding','replicate'));
    caxis([0 prctile(selMdlMat(:),tuningPrctile)]) %cap limit at 99th percentile in case of outliers in predictions
    hold on;plot([find(BI==0)-1 find(BI==0)-1],[size(glmModel{i}.heat.matrixRaw,1) 0],'w:')
    set(gca,'ytick',1:anglePlotSpacing:length(selThetaBins),'yticklabel', selThetaBins(1:anglePlotSpacing:length(selThetaBins)),'ydir','normal',...
        'xtick',(0:25:length(BI)),'xticklabel',[min(BI):25:max(BI)],'xlim',[0 length(BI)])
    xlabel('time from touch onset (ms)')
    ylabel('angle at touch')
    title('modeled tuning curve')
    hold on; plot([find(BI==touchResp(1)) find(BI==touchResp(1))],[0 length(selThetaBins)+1],'r-.')
    hold on; plot([find(BI==touchResp(2)) find(BI==touchResp(2))],[0 length(selThetaBins)+1],'r-.')
    
    %     hold on; plot([selIdx(1) selIdx(1)],[0 30],'-.w')
    %     hold on; plot([selIdx(end) selIdx(end)],[0 30],'-.w')
    %
    
    %PLOTTING LOCATION TUNING CURVE
    
    colors = {'k','b','r'};
    
    tangles = [];
    for g = 1:length(popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.range)
        tangles = [tangles ; repmat(popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.range(g),popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.counts(g),1)];
    end
    
    
    spikesGroup = {glmModel{i}.raw.spikes, cell2mat(popV{glmModel{i}.meta}.(touchOrderFields{whichTouches}).theta.raw) , glmModel{i}.predicted.spikeProb};
    angleGroup = {glmModel{i}.raw.trimmedAngle, tangles, glmModel{i}.predicted.angles};
    
    
    thetabounds = [-100:2:100];
    
    for d = 1:length(spikesGroup)
        
        allspks = spikesGroup{d};
        angleatT = angleGroup{d};
        
        bl = allspks(:,1:find(BI==0));
        %         response = allspks(:,find(BI==touchResp(1)):find(BI==touchResp(2)));
        response = allspks(:,find(BI==3):find(BI==15));
        
        meanbase =  mean(mean(bl,2));
        stdbase = std(mean(bl,2));
        meanresp = mean(response,2);
        zscore = (meanresp - meanbase) ./ stdbase;
        
        [sorted,~,~] = binslin(angleatT,zscore,'equalE',numel(thetabounds),thetabounds(1),thetabounds(end));
        
        samps = cellfun(@numel,sorted);
        selBins = find(samps>sum(samps)./100);
        
        zraw = nan(length(sorted),1000);
        for b = 1:length(sorted)
            if sum(b == selBins)>0
                currvals = sorted{b};
                if ~isempty(sorted{b})
                    zraw(b,1:length(currvals)) = currvals';
                end
            end
        end
        
        [p,~,stats]=anova1(zraw',[],'off');
        vals =multcompare(stats,[],'off');
        x=cellfun(@str2num,stats.gnames);
        
        %CI BINS
        cibins = nan(size(x,1),1);
        
        SEMg = nanstd(zraw,[],2) ./ sqrt(sum(~isnan(zraw),2));
        for p = 1:length(x)
            rawx = zraw(x(p),:);
            SEM = SEMg(x(p));
            ts = tinv(.95,sum(~isnan(rawx),2)-1);      % T-Score
            cibins(p,:) = ts.*SEM;   %confidence intervals
        end
        
        SEM = SEMg(x);
        y = stats.means;
        x=thetabounds(x)';
        
        xy = [x y'];
        
        hold on;subplot(3,3,[5 6])
        shadedErrorBar(xy(:,1),xy(:,2),cibins,['-' colors{d}]);
        hold on;
        set(gca,'xlim',[min(xy(:,1)) max(xy(:,1))],'xtick',-20:20:60)
        
        zresp{d} = xy;
    end
    
    tmp = cell2mat(zresp');
    set(gca,'ylim',[min(tmp(:,2))*.5 max(tmp(:,2))*1.5])
    %
    %     [~,interIdx ] = intersect(zresp{1}(:,1),zresp{2}(:,1));
    %     [~,interIdx2 ] = intersect(zresp{2}(:,1),zresp{1}(:,1));
    
    [raw,~ ] = intersect(zresp{1}(:,1),selThetaBins);
    [modeled,~ ] = intersect(zresp{2}(:,1),selThetaBins);
    
    interIdx = ismember(zresp{1}(:,1),modeled);
    interIdx2 = ismember(zresp{2}(:,1),raw);
    
    xlabel('angle at touch');ylabel('z-scored response')
    title(['original(black) | training(blue) | modeled(red). expVar=' num2str(corr(zresp{1}(interIdx,2),zresp{2}(interIdx2,2)).^2)])
    
    [zresp{1}(interIdx,1) zresp{2}(interIdx2,1)]
    
    expVar(i) = corr(zresp{1}(interIdx,2),zresp{2}(interIdx2,2)).^2;
    
    
    hold on;subplot(3,3,[8 9])
    coeffsToPlot = fields(glmModel{i}.coeffs);
    for u = 2:length(coeffsToPlot)
        coeffsToPlotName = coeffsToPlot{u};
        if strcmp(coeffsToPlotName,'touch') || strcmp(coeffsToPlotName,'touchDur')
            hold on; plot(BI,sum(glmModel{i}.coeffs.(coeffsToPlotName)'.*glmModel{i}.basisFunctions.touch,2))
        else
            hold on; plot(BI,sum(glmModel{i}.coeffs.(coeffsToPlotName)'.*glmModel{i}.basisFunctions.features,2))
        end
    end
    ylabel('kernel weight')
    xlabel('time from touch onset (ms)')
    legend(coeffsToPlot(2:end))
    
    dir = ['C:\Users\jacheung\Dropbox\LocationCode\Figures\hilbertCode\' glmModel{i}.name];
    if ~exist(dir,'dir')
        mkdir(dir)
    end
    
    print(['C:\Users\jacheung\Dropbox\LocationCode\Figures\hilbertCode\' glmModel{i}.name '\hilbert_' num2str(i)],'-dpng')
end