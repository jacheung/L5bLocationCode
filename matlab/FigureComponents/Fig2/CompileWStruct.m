function whisk_struct = CompileWStruct(data_directory, feature_list)

for b = 1:numel(feature_list)
    fileName = ['whisk_' feature_list{b} '_window'];
    
    if exist([data_directory 'Whisking\' fileName '.mat'], 'file')
        disp(['Loading whisking stucture for ' feature_list{b}])
        load([data_directory 'Whisking\' fileName '.mat']);
        whisk_struct.(feature_list{b}) = wStruct;
    else
        disp('No whisking structure found. Building from scratch...')
        
        if ~exist('U')
            disp('Loading complete all neural recordings')
            load([data_directory 'Raw\excitatory_all.mat']); %L5b excitatory cells recorded by Jon and Phil
        
        end
        disp(['Building whisking structure for ' feature_list{b}])
        disp('This may take some time so consider loading pre-built structures')
        whisk_struct.(feature_list{b}) = whisking_location_quantification(U,1:length(U),feature_list{b},'off');
        
    end
end
