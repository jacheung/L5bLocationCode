% view traces with whisking, spikes, and touch responses

for k = 29
    currentCell = U{k};
    motors = currentCell.meta.motorPosition;
    lows = find(motors<prctile(motors,35));
    highs = find(motors>prctile(motors,65));
    mids = setdiff(1:currentCell.k,[lows highs])
    
    %     trialSample = [datasample(lows,1) datasample(mids,1) datasample(highs,1)];
    
    trialSample = [ 37 36 92]; %great example for clel 29 or 37 36 92
    figure(2310);clf
    for g = 1:length(trialSample)
        
        whisk = currentCell.S_ctk(1,:,trialSample(g));
        amp = currentCell.S_ctk(3,:,trialSample(g));
        amp_whisk = whisk;
        amp_whisk(amp<5) = nan;
        touchesOn = [find(currentCell.S_ctk(9,:,trialSample(g))==1) find(currentCell.S_ctk(12,:,trialSample(g))==1)];
        touchesOff = [find(currentCell.S_ctk(10,:,trialSample(g))==1) find(currentCell.S_ctk(13,:,trialSample(g))==1)];
        
        spikes = find(currentCell.R_ntk(1,:,trialSample(g))==1);
        figure(2310);
        subplot(3,1,g)
        if ~isempty(touchesOn) && ~isempty(spikes)
            plot(1:currentCell.t,whisk,'k')
            hold on;plot(1:currentCell.t,amp_whisk,'c')
            for f = 1:length(touchesOn)
                tp = touchesOn(f):touchesOff(f);
                hold on; plot(tp,whisk(tp),'r');
            end
            hold on; scatter(spikes,ones(length(spikes),1)*mean(whisk),'ko','filled')
        end
        title(['cell num ' num2str(k) ' at trial num ' num2str(trialSample(g))])
        set(gca,'ylim',[-20 60])
    end
    
    %     saveDir = 'C:\Users\jacheung\Dropbox\LocationCode\Figures\Parts\Fig1\';
    %     fn = 'example_traces.eps';
    %     export_fig([saveDir, fn], '-depsc', '-painters', '-r1200', '-transparent')
    %     fix_eps_fonts([saveDir, fn])
end

%%

for k = 20
    currentCell = U{k};
    motors = currentCell.meta.motorPosition;
    lows = find(motors<prctile(motors,35));
    highs = find(motors>prctile(motors,65));
    mids = setdiff(1:currentCell.k,[lows highs])
    
     trialSample = [datasample(1:currentCell.k,5)];
%         trialSample = [99 136 datasample(1:currentCell.k,3)]; %% CELL 22
%         trialSample = [119 datasample(1:currentCell.k,2)]; %% CELL 33 EXAMPLE 119 SO GOOD!CELL TUNED TO ANGLE 10 . Dam, it's also phase tuned. LULz
%         trialSample = [60 1 datasample(1:currentCell.k,1)]; %% CELL 74 maybe 96 too
    figure(2310);clf
    for g = 1:length(trialSample)
        
        whisk = currentCell.S_ctk(1,:,trialSample(g));
        midpoint = currentCell.S_ctk(4,:,trialSample(g)); 
        amp = currentCell.S_ctk(3,:,trialSample(g));
        amp_whisk = whisk;
        amp_whisk(amp<5) = nan;
        touchesOn = [find(currentCell.S_ctk(9,:,trialSample(g))==1) find(currentCell.S_ctk(12,:,trialSample(g))==1)];
        touchesOff = [find(currentCell.S_ctk(10,:,trialSample(g))==1) find(currentCell.S_ctk(13,:,trialSample(g))==1)];

        if ~isempty(touchesOn)
            for p = 1:numel(touchesOn)
                amp_whisk(touchesOn(p):touchesOff(p)+30) = nan;
            end
        end
        
        spikes = find(currentCell.R_ntk(1,:,trialSample(g))==1);
        figure(2310);
        subplot(length(trialSample),1,g)
        plot(1:currentCell.t,whisk,'k')
        hold on;plot(1:currentCell.t,amp_whisk,'c')
        
        hold on; scatter(spikes,whisk(spikes),'ko','filled','markerfacecolor',[.8 .8 .8])
        hold on; scatter(spikes,amp_whisk(spikes),'ko','filled')
%         hold on; scatter(spikes,ones(length(spikes),1)*mean(whisk),'ko','filled')
        
        if ~isempty(touchesOn) && ~isempty(spikes)
            
            for f = 1:length(touchesOn)
                tp = touchesOn(f):touchesOff(f);
                hold on; plot(tp,whisk(tp),'r');
            end
            
        end
        
        title(['cell num ' num2str(k) ' at trial num ' num2str(trialSample(g))])
        set(gca,'ylim',[-40 60])
    end
    
%         saveDir = 'C:\Users\jacheung\Dropbox\LocationCode\Figures\Parts\Fig4\';
%         fn = 'example_traces_TOP .eps';
%         export_fig([saveDir, fn], '-depsc', '-painters', '-r1200', '-transparent')
%         fix_eps_fonts([saveDir, fn])
end
