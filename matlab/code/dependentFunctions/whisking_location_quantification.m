function [tuneStruct] = whisking_location_quantification(uberarray,selectedCells,hilbert_feature)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this function is used to plot a heat map of location (angle at touch)
%tuning for selectedCells. Specifically, use touch cells. 
%
%inputs: 
%uberarray - packaged uber array with all recorded units
%selectedCells - indices of units in uberarray that are touch cells
%
%outputs:
%heatmap for object location tuning across time
%object location tuning in touch response window as defined from
%defTouchResponse.m function
%is_tuned = vector showing whether neuron is tuned to hilbert_feature at
%touch
%tc_xy = tuning curves showing x(stim) and y(responses); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%function parameters
numWhiskSamplesPerBin = 3000; %number of touches to assign in each bin for quantification. 
alpha_value = .05; %p-value threshold to determine whether a cell is OL tuned or not
smoothing_param = 10; %smoothing parameter for smooth f(x) in shadedErrorBar
min_bins = 5; %minimum number of angle bins to consider quantifying 


%dependent function to id all touches and pre/post decision touches
preDecisionTouches = preDecisionTouchMat(uberarray(selectedCells));
rc = numSubplots(numel(selectedCells));

%populating struct for tuning quantification
tuneStruct = cell(1,length(uberarray));
for i = 1:length(uberarray)
    tuneStruct{i}.is_tuned = nan;
end

all_masks = cellfun(@maskBuilder,uberarray(selectedCells)); %build masks

for rec = 1:length(selectedCells)
    array = uberarray{selectedCells(rec)};
    curr_mask = all_masks(rec);
    whisking_mask = curr_mask.whisking .*curr_mask.touch;
    spikes = squeeze(array.R_ntk); 
    
    if strcmp(hilbert_feature,'angle')
        conversion_feature = array.S_ctk(:,1);
    elseif strcmp(hilbert_feature,'amplitude')
        conversion_feature = array.S_ctk(:,3);
    elseif strcmp(hilbert_feature,'midpoint')
        conversion_feature = array.S_ctk(:,4);
    elseif strcmp(hilbert_feature,'phase')
        conversion_feature = array.S_ctk(:,5);
    elseif strcmp(hilbert_feature,'curvature')
        conversion_feature = array.S_ctk(:,6);
    elseif strcmp(hilbert_feature,'pole')
        viewWindow = -25:50;
        [tVar] = atTouch_sorter(array,viewWindow,preDecisionTouches{rec});
        pole_at_touch = normalize_var(tVar.allTouches.S_ctk(:,end),-1,1);
        angle_at_touch = tVar.allTouches.S_ctk(:,1);
        
        [s,sby] = binslin(pole_at_touch,angle_at_touch,'equalN',12); %bin responses based on pole positions
        cleaned = cell2mat(cellfun(@(x,y) rmoutliers([x y]),s,sby,'uniformoutput',0)); %remove outliers using median 
        cleaned(sum(isnan(cleaned),2)>0,:) = [];
        clean_aat = cleaned(:,1);
        clean_pat = cleaned(:,2);
        p = polyfit(clean_aat,clean_pat,2); %use polyfit to convert angle to pole position
        
        angle = squeeze(array.S_ctk(1,:,:));
        conversion_feature = polyval(p,angle);
    end
    
    current_feature = conversion_feature(whisking_mask==1);
    filtered_spikes =spikes(whisking_mask==1);
    
    numBins = round(sum(~isnan(current_feature(:)))./numWhiskSamplesPerBin);
    
    %% Tuning in touch response window 
    if strcmp(hilbert_feature,'phase')
        [sorted, sortedBy] = binslin(current_feature,filtered_spikes*1000,'equalE',13,-pi,pi);
    else
        [sorted, sortedBy] = binslin(current_feature,filtered_spikes*1000,'equalN',numBins);
    end
    
    quant_ol_p = anova1(cell2nanmat(sorted),[],'off');
    
    SEM = cellfun(@(x) std(x) ./ sqrt(numel(x)),sorted);
    tscore = cellfun(@(x) tinv(.95,numel(x)-1),sorted);
    CI = SEM.*tscore;
    
    if numel(sortedBy)>min_bins
        figure(23);subplot(rc(1),rc(2),rec)
        shadedErrorBar(cellfun(@median, sortedBy), smooth(cellfun(@mean,sorted),smoothing_param),smooth(CI,smoothing_param),'k')

        if quant_ol_p < alpha_value
            %plot smoothed response first
            smooth_response = smooth(cellfun(@mean,sorted),smoothing_param);
            
            [maxResponse,idx] = max(smooth_response);
            
            %plot scatter of first sig diff from max
            sd_p = nan(length(sorted),1);
            pThresh = .05;
            for g = 1:numel(sorted)
                [~,sd_p(g)] = ttest2(sorted{idx},sorted{g});
            end
            all_idx = find(sd_p < pThresh); %all points sig diff from max
            [~,sd_idx_tmp] = min(abs(idx - all_idx));
            sd_idx = all_idx(sd_idx_tmp);
            
            if ~isempty(sd_idx) && ~isempty(idx)
                hold on; scatter(median(sortedBy{idx}),maxResponse,'b','filled');
                hold on; scatter(median(sortedBy{sd_idx}),smooth_response(sd_idx),'b','filled');
            end
            
          
            tuneStruct{selectedCells(rec)}.is_tuned = 1; 
        end
        
        if strcmp(hilbert_feature,'phase')
            set(gca,'xlim',[-pi pi],'xtick',-pi:pi:pi,'xticklabel',{'-\pi','0','\pi'})
        elseif strcmp(hilbert_feature,'pole')
             set(gca,'xlim',[-1 1],'xtick',-1:1:1,'xdir','reverse')
        else
            set(gca,'xlim',[min(cellfun(@median, sortedBy)) max(cellfun(@median, sortedBy))])
        end
        
         tuneStruct{selectedCells(rec)}.stim_response.varNames = {'median S_ctk','mean R_ntk','std R_ntk'};
         tuneStruct{selectedCells(rec)}.stim_response.values = [cellfun(@median, sortedBy) smooth(cellfun(@mean,sorted),smoothing_param) smooth(cellfun(@std,sorted),smoothing_param)];
         
    else
        tuneStruct{selectedCells(rec)}.is_tuned  = .5;  %not enough samples 
    end
end   