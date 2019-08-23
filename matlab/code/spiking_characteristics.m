%Load whisking and neural time series struct 
clear
load('C:\Users\jacheung\Dropbox\LocationCode\DataStructs\excitatory_all.mat') %L5b excitatory cells
% load('C:\Users\jacheung\Dropbox\LocationCode\DataStructs\interneurons.mat') %L5b inhibitory cells

%% Top level parameters and definitions 
% U = defTouchResponse(U,.95,'off');

%% Quantification of all units and their response properties
masks = cellfun(@(x) maskBuilder(x),U,'uniformoutput',0);

spks_in_touch = cellfun(@(x,y) nansum(nansum(squeeze(x.R_ntk).*(isnan(y.touch)))),U,masks);
spks_in_whisking = cellfun(@(x,y) nansum(nansum(squeeze(x.R_ntk).*y.whisking .*y.touch)),U,masks);
whisking_tp = cellfun(@(x,y) nansum(nansum(y.whisking .*y.touch)),U,masks);
quiet_tp = cellfun(@(x,y) nansum(nansum(y.quiet .*y.touch)),U,masks);
spks_in_all = cellfun(@(x) nansum(squeeze(x.R_ntk(:))),U);

mean_fr = cellfun(@(x) mean(squeeze(x.R_ntk(:))),U)*1000; %mean firing rate of all units 
whisking_fr = (spks_in_whisking./whisking_tp)*1000; %whisking firing rate
non_whisking_fr = ((spks_in_all-spks_in_touch-spks_in_whisking)./quiet_tp)*1000; %non whisking firing rate 
prop_touch = spks_in_touch./spks_in_all; %proportion of spikes attributed to touch 
prop_whisking_touch = (spks_in_touch+spks_in_whisking)./spks_in_all;%proportion of spikes attributed to whisking + touch 



all_properties = {whisking_fr,non_whisking_fr,prop_touch,prop_whisking_touch,onset_latency,resp_window_length,touch_response_spks,pResponse_touch};
mean_all = [cellfun(@mean, all(~cellfun(@isempty,all))) nan(1,4)]';
std_all = [cellfun(@std, all(~cellfun(@isempty,all))) nan(1,4)]';
median_all= [cellfun(@median, all(~cellfun(@isempty,all))) nan(1,4)]';
[range_all(:,1)] = [cellfun(@min, all(~cellfun(@isempty,all))) nan(1,4)]';
[range_all(:,2)] = [cellfun(@max, all(~cellfun(@isempty,all))) nan(1,4)]';

%% Quantification of touch excited units and their response properties 
touchUnits = find(cellfun(@(x) strcmp(x.meta.touchProperties.responseType,'excited'),U)~=0);
%BUILD parameters for GLM to quantify touch units 
glmnetOpt.buildIndices = [-25:50]; %Indices around touch
glmnetOpt.touchDirection = 'protraction';
glmModel = [];
[glmModel] = designMatrixBlocks_simplified(U(touchUnits),glmnetOpt,glmModel);
excitThresh =  num2cell(cellfun(@(x) x.meta.touchProperties.baseline(1),U(touchUnits)));

%touch properties and definitions 
onset_latency = cellfun(@(x) x.meta.touchProperties.responseWindow(1),U(touchUnits)); % time of touch onset 
resp_window_length = cellfun(@(x) range(x.meta.touchProperties.responseWindow),U(touchUnits)); % length of touch response
touch_response_spks = cellfun(@(x,y) mean(x.io.DmatY),glmModel); %average number of spikes in touch response window 
pResponse_touch = cellfun(@(x,y) mean((x.io.DmatY*1000)>y),glmModel,excitThresh); %probability of generating spiking response > baseline + 95%CI

whisking_fr(touchUnits);%whisking firing rate
non_whisking_fr(touchUnits); %non whisking firing rate 
prop_touch(touchUnits); %proportion of spikes in touch window
prop_whisking_touch(touchUnits); %proportion of spikes in whisking+touch window 

touch_properties = {whisking_fr(touchUnits),non_whisking_fr(touchUnits),prop_touch(touchUnits),prop_whisking_touch(touchUnits),onset_latency,resp_window_length,touch_response_spks,pResponse_touch};
mean_touch = [cellfun(@mean, touch_properties) ]';
std_touch = [cellfun(@std, touch_properties) ]';
median_touch = [cellfun(@median, touch_properties) ]';
range_touch(:,1) = [cellfun(@min, touch_properties) ]';
range_touch(:,2) = [cellfun(@max, touch_properties) ]';

% final_table = table({'whisking (hz)','quiet (hz)','touch evoked','touch+w evoked','onset latency','response window','touch response spks','p(response'}'...
%     ,mean_all_properties',std_all_properties',median_all_properties',range_all_properties'...
%     ,mean_touch_properties',std_touch_properties',median_touch_properties',range_touch_properties')

final_table = table(mean_all,std_all,median_all,range_all... 
    ,mean_touch,std_touch,median_touch,range_touch);

id_properties = {'whisking (hz)','quiet (hz)','touch evoked','touch+w evoked','onset latency','response window','touch response spks','p(response'}; 
final_table.Properties.RowNames = id_properties;

filename = 'spiking_characteristics.xlsx';
writetable(final_table,filename)

