% selectedCells = find(cellfun(@(x) isfield(x.meta.touchProperties,'responseWindow'),U)~=0);

%% 
hilbertVar = 'pole';

selectedCells = find(cellfun(@(x) strcmp(x.meta.touchProperties.responseType,'excited'),U));
defTouchResponse(U(selectedCells),.95,'on')
    saveDir = 'C:\Users\jacheung\Dropbox\LocationCode\Figures\Parts\Fig2\';
    fn = 'touch_all.eps';
    export_fig([saveDir, fn], '-depsc', '-painters', '-r1200', '-transparent')
    fix_eps_fonts([saveDir, fn])



tStruct = object_location_quantification(U,selectedCells,hilbertVar,'on');

%     saveDir = 'C:\Users\jacheung\Dropbox\LocationCode\Figures\Parts\Fig2\';
%     fn = 'touch_location_all.eps';
%     export_fig([saveDir, fn], '-depsc', '-painters', '-r1200', '-transparent')
%     fix_eps_fonts([saveDir, fn])





wStruct = whisking_location_quantification(U,selectedCells,hilbertVar,'off');

if strcmp(hilbertVar,'pole')
    population_heatmap_builder(tStruct,wStruct,hilbertVar)
    
    saveDir = 'C:\Users\jacheung\Dropbox\LocationCode\Figures\Parts\Fig2\';
    fn = 'population_location.eps';
    export_fig([saveDir, fn], '-depsc', '-painters', '-r1200', '-transparent')
    fix_eps_fonts([saveDir, fn])
else
    disp('not building out population heatmaps. function not optimized for other variables')
end
%% scatter of tuning preference of whisk and touch

tUnits = cellfun(@(x) isfield(x.calculations,'tune_peak'),tStruct);
wUnits = cellfun(@(x) isfield(x.calculations,'tune_peak'),wStruct);

[~,touch_ix_idx] = intersect(find(tUnits),find(wUnits));
[~,whisk_ix_idx] = intersect(find(wUnits),find(tUnits));

touch_nonIX_idx = setdiff(1:sum(tUnits),touch_ix_idx);
whisk_nonIX_idx = setdiff(1:sum(wUnits),whisk_ix_idx);

touch_pw = cell2mat(cellfun(@(x) [x.calculations.tune_peak x.calculations.tune_left_width x.calculations.tune_right_width],tStruct(tUnits),'uniformoutput',0)') ;
whisking_pw = cell2mat(cellfun(@(x) [x.calculations.tune_peak x.calculations.tune_left_width x.calculations.tune_right_width],wStruct(wUnits),'uniformoutput',0)'); 

%scatter of whisking (Y) vs touch (X)
figure(3850);clf
hold on; errorbar(ones(1,length(whisk_nonIX_idx))*2.5,whisking_pw(whisk_nonIX_idx,1),whisking_pw(whisk_nonIX_idx,2),whisking_pw(whisk_nonIX_idx,3),'co','vertical')%plot only whisk tuned units
hold on; errorbar(touch_pw(touch_nonIX_idx,1),ones(1,length(touch_nonIX_idx))*2.5,touch_pw(touch_nonIX_idx,2),touch_pw(touch_nonIX_idx,3),'bo','horizontal')%plot only touch tuned units
hold on; errorbar(touch_pw(touch_ix_idx,1),whisking_pw(whisk_ix_idx,1),whisking_pw(whisk_ix_idx,2),whisking_pw(whisk_ix_idx,3),touch_pw(touch_ix_idx,2),touch_pw(touch_ix_idx,3),'ko')

lm = fitlm(touch_pw(touch_ix_idx,1),whisking_pw(whisk_ix_idx,1));
predicts = lm.predict;
[s_vals,sort_idx] = sort(touch_pw(touch_ix_idx,1));
hold on; plot(s_vals,predicts(sort_idx))


set(gca,'xlim',[-3 3],'ylim',[-3 3],'xdir','reverse','ydir','reverse',...
    'xtick',-1:1:1,'ytick',-1:1:1)
hold on; plot([-1 1],[-1 1],'--k')
legend('whisk tuned only','touch tuned only','both tuned')
axis square
xlabel('touch tune peak');ylabel('whisk tune peak')
title(['whisk=' num2str(numel(whisk_nonIX_idx)) ', touch=' num2str(numel(touch_nonIX_idx)) ', both=' num2str(numel(touch_ix_idx))])

figure(3851);clf
subplot(2,1,1)
histogram(touch_pw(:,1),-3:.20:3,'facecolor','b','facealpha',1)
set(gca,'xdir','reverse','xlim',[-3 3])

subplot(2,1,2); 
histogram(whisking_pw(:,1),-3:.20:3,'facecolor','c','facealpha',1)
set(gca,'xdir','reverse','xlim',[-3 3],'ytick',0:2:6,'ylim',[0 6])

% scatter of absolute modulation values
touch_abs_mod = cell2mat(cellfun(@(x) x.calculations.mod_idx_abs,tStruct(tUnits),'uniformoutput',0)') ;
whisk_abs_mod = cell2mat(cellfun(@(x) x.calculations.mod_idx_abs,wStruct(wUnits),'uniformoutput',0)') ;

[min_bound,max_bound] = bounds([touch_abs_mod(touch_ix_idx); whisk_abs_mod(whisk_ix_idx)]);

figure(2410);clf
hold on; scatter(whisk_abs_mod(whisk_nonIX_idx),zeros(1,length(whisk_nonIX_idx)),'c');
hold on; scatter(zeros(1,length(touch_nonIX_idx)),touch_abs_mod(touch_nonIX_idx),'b');
hold on; scatter(whisk_abs_mod(whisk_ix_idx),touch_abs_mod(touch_ix_idx),'k')
hold on; plot([0,100],[0,100],'--k')
set(gca,'xlim',[0 100],'ylim',[0 100],'ytick',0:25:100,'xtick',0:25:100)
axis square
xlabel('whisk absolute modulation');
ylabel('touch absolute modulation');

figure(2411);clf
subplot(2,1,1)
histogram(touch_abs_mod,0:5:100,'facecolor','b','facealpha',1)
set(gca,'xlim',[0 100],'ylim',[0 10],'xtick',0:25:100,'ytick',0:5:10)

subplot(2,1,2)
histogram(whisk_abs_mod,0:5:100,'facecolor','c','facealpha',1)
set(gca,'xlim',[0 100],'ylim',[0 10],'xtick',0:25:100,'ytick',0:5:10)
%% intersection of whisking and touch 

touch_OL = cellfun(@(x) x.is_tuned==1,tStruct);
rc = numSubplots(sum(touch_OL)); 

sel_tstructs = tStruct(touch_OL);
sel_wstructs = wStruct(touch_OL);

figure(8);clf
figure(99);clf
whisk_touch_pair = cell(1,sum(touch_OL));
touch_diff_pair = cell(1,sum(touch_OL)); 
for g = 1:sum(touch_OL)
    curr_w = sel_wstructs{g}.stim_response.values;
    curr_t = sel_tstructs{g}.stim_response.values;
    
    curr_w = curr_w(~any(isnan(curr_w),2),:); %clean nan rows
    curr_t = curr_t(~any(isnan(curr_t),2),:); 
    
    if strcmp(hilbertVar,'pole')
        whisk_x = round(round(min(curr_w(:,1)),1):.1:round(max(curr_w(:,1)),1),1);
        touch_x = round(round(min(curr_t(:,1)),1):.1:round(max(curr_t(:,1)),1),1);
    elseif strcmp(hilbertVar,'phase')
        whisk_x = linspace(-pi,pi,21);
        touch_x = linspace(-pi,pi,21);
    else
        whisk_x = round(round(min(curr_w(:,1))):1:round(max(curr_w(:,1))));
        touch_x = round(round(min(curr_t(:,1))):1:round(max(curr_t(:,1))));
    end
    whisk_response = interp1(curr_w(:,1),curr_w(:,2),whisk_x);
    whisk_std = interp1(curr_w(:,1),curr_w(:,3),whisk_x);
    whisk_CI = interp1(curr_w(:,1),curr_w(:,4),whisk_x);
    
    touch_response = interp1(curr_t(:,1),curr_t(:,2),touch_x);
    touch_std = interp1(curr_t(:,1),curr_t(:,3),touch_x);
    touch_CI =  interp1(curr_t(:,1),curr_t(:,4),touch_x);
    
    [~,~,whisk_idx] = intersect(touch_x,whisk_x);
    [overlap_x,~,touch_idx] = intersect(whisk_x,touch_x);
    
    
    figure(99);subplot(rc(1),rc(2),g)
    shadedErrorBar(overlap_x,whisk_response(whisk_idx),whisk_CI(whisk_idx),'c')
    hold on; shadedErrorBar(overlap_x,touch_response(touch_idx),touch_CI(touch_idx),'b')
    if strcmp(hilbertVar,'pole')
        set(gca,'xlim',[-1 1],'xdir','reverse')
    elseif strcmp(hilbertVar,'phase')
        set(gca,'xlim',[-pi pi],'xtick',-pi:pi:pi,'xticklabel',{'\pi','0','\pi'})    
    end
    
    figure(100);subplot(rc(1),rc(2),g)
    scatter(whisk_response(whisk_idx),touch_response(touch_idx))
    
    
%     plot(overlap_x,whisk_response(whisk_idx),'c')
%     hold on; plot(overlap_x,touch_response(touch_idx),'b')
    all_responses = [whisk_response(whisk_idx) touch_response(touch_idx)];
%     set(gca,'xlim',[min(all_responses) max(all_responses)],'ylim',[min(all_responses) max(all_responses)])
%     hold on; plot([min(all_responses) max(all_responses)],[min(all_responses) max(all_responses)],'-.k')
    
    normed_responses = normalize_var(all_responses,0,1);
    whisk_touch_pair{g} = reshape(normed_responses,numel(normed_responses)./2,2); 
    
    %calculation of difference to quantify the effect touch has on whisking
    response_difference = touch_response(touch_idx) - whisk_response(whisk_idx);
    figure(8);subplot(rc(1),rc(2),g)
    scatter(touch_response(touch_idx),response_difference,'b')
    set(gca,'xlim',[min([all_responses response_difference]) max([all_responses response_difference])],'ylim',[min([all_responses response_difference]) max([all_responses response_difference])])
    axis square
    hold on;plot([min([all_responses response_difference]) max([all_responses response_difference])],[min([all_responses response_difference]) max([all_responses response_difference])],'-.k')
    normed_responses_tdpair = normalize_var([response_difference touch_response(touch_idx)],0,1);
    touch_diff_pair{g} =  reshape(normed_responses_tdpair,numel(normed_responses_tdpair)./2,2); 

    
end   

all_values = cell2mat(whisk_touch_pair');
figure(12);clf
scatter(all_values(:,1),all_values(:,2),'k')
hold on; plot([0 1],[0 1],'-.k')
set(gca,'xlim',[0 1],'ylim',[0 1])
ylabel('normalized touch responses')
xlabel('normalized whisk responses')
axis square

pair_mean = cell2mat(cellfun(@nanmean,whisk_touch_pair','uniformoutput',0));
pair_sem = cell2mat(cellfun(@(x) nanstd(x)./sqrt(length(x)),whisk_touch_pair,'uniformoutput',0)');
figure(15);clf
subplot(1,2,1)
for g = 1:size(pair_mean,1)
    hold on;errorbar(pair_mean(g,1),pair_mean(g,2),pair_sem(g,2),pair_sem(g,2),pair_sem(g,1),pair_sem(g,1),'ko')
end
hold on; plot([0 1],[0 1],'--k')
set(gca,'xlim',[0 1],'ylim',[0 1])
axis square
ylabel('normalized touch responses')
xlabel('normalized whisk responses')

% all_values_tdpair = cell2mat(touch_diff_pair');
% figure(13);clf
% scatter(all_values_tdpair(:,2),all_values_tdpair(:,1),'k')
% hold on; plot([0 1],[0 1],'-.k')
% set(gca,'xlim',[0 1],'ylim',[0 1])
% ylabel('normalized touch responses')
% xlabel('normalized difference (touch-whisking)')
% axis square
% lm = fitlm(all_values_tdpair(:,1),all_values_tdpair(:,2))

pair_mean = cell2mat(cellfun(@nanmean,touch_diff_pair','uniformoutput',0));
pair_sem = cell2mat(cellfun(@(x) nanstd(x)./sqrt(length(x)),touch_diff_pair,'uniformoutput',0)')
subplot(1,2,2)
for g = 1:size(pair_mean,1)
    hold on;errorbar(pair_mean(g,2),pair_mean(g,1),pair_sem(g,1),pair_sem(g,1),pair_sem(g,2),pair_sem(g,2),'ko')
end
hold on; plot([0 1],[0 1],'--k')
set(gca,'xlim',[0 1],'ylim',[0 1])
axis square
xlabel('normalized touch responses')
ylabel('normalized difference (touch-whisking)')
suptitle(hilbertVar)



    