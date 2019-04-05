load('C:\Users\jacheung\Documents\GitHub\L5bLocationCode\matlab\datastructs\U.mat')

%% Top level definitions
touchWindow = [-25:50]; %window for analyses around touch
numInterpPts = 24; %used for stretching or shrinking tuning curves to within the same bounds for 
% GLM model parameters
glmnetOpt = glmnetSet;
glmnetOpt.standardize = 0; %set to 0 b/c already standardized
glmnetOpt.alpha = 0.95;
glmnetOpt.xfoldCV = 5;
glmnetOpt.numIterations = 10;


%% Structure for quantifying tuning 
popV = touchFeatureBinned(U,touchWindow);
touchCells = touchCell(U);
selectedCells = find(touchCells==1);

%% Plotter for feature tuning around touch window
gaussFilt = 1; %smoothing function for tuning plots
fieldsList = fields(popV{1});
touchFeatureBinned_plotter(U,popV,selectedCells,fieldsList(1),touchWindow,gaussFilt)

%% Plotter for object location tuning
fieldsList = fields(popV{1});
tunedCellsIdx = tuningQuantification(U,popV,selectedCells,fieldsList(1),touchWindow);

%optional raster of FRs for tuned cells. 
for d = 1
    figure(8);clf
    allSpks = squeeze(U{tunedCellsIdx(d)}.R_ntk);
    [~,idx] = sort(U{tunedCellsIdx(d)}.meta.motorPosition);
    allSpks = allSpks(:,idx);
    for k = 1:size(allSpks,2)
        st = find(allSpks(:,k)==1);
        if ~isempty(st)
        figure(8);hold on
        scatter(st,ones(length(st),1).*k,[],'.k')
        end
    end
end

%% Builder for decoding
fieldsList = fields(popV{1});
[DmatX,DmatY] = designMatrixBuilder_touchFeature(U,popV,selectedCells,fieldsList{1},touchWindow,numInterpPts);

mdl.io.X = DmatX;
mdl.io.Y = DmatY; 

mdl = multinomialModel(mdl,DmatX,DmatY.normal,glmnetOpt); %normalizing all model tuning to within x num interpolation points
decoderPerformance(mdl)

mdl = multinomialModel(mdl,DmatX,DmatY.shuffled,glmnetOpt); %shuffled outcomes to define baseline
decoderPerformance(mdl)

predProb = mdl.gof.confusionMatrix ./ sum(mdl.gof.confusionMatrix); 
figure;imagesc(predProb)
caxis([0 max(predProb(:))])
colorbar
axis square
