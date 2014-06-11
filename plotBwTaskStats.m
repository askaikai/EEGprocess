function plotBwTaskStats(topDir, freq)

warning off

% freq = [8 13]; % [30 60] %[80 110] %[8 13] %[4 8]
% topDir = '/Volumes/Data/AES_EEG_06072012/';

if freq(1) < 30
    cd([topDir 'TFR/lowFreq/stats'])
elseif freq(1) >=30
    cd([topDir 'TFR/highFreq/stats'])
end

topDir=pwd;
load('../../../preprocessed/sub01_1.mat','masterTime')
for i=1:length(masterTime)
    task{i}=masterTime(i).name;
end

for j=2:length(task)
    
    load([task{j} 'VsBaseline_' num2str(freq(1)) 'to' num2str(freq(2)) 'Hz_400to4600msec.mat'] ,'stat')
    
    plotStats(stat);
    
    fprintf('comparing %s and Baseline \n', task{j});
    pause;
    close all
    
    if j < length(task)
        for k = (j+1):length(task)
            load([task{j} 'Vs' task{k} '_' num2str(freq(1)) 'to' num2str(freq(2)) 'Hz_400to4600msec.mat'] ,'stat')
            
            plotStats(stat);
            
            fprintf('comparing %s and %s \n', task{j}, task{k});
            pause;
            close all
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotStats(stat)

if (isfield(stat,'posclusters') && ~isempty(stat.posclusters) && stat.posclusters(1).prob <= .2) || ...
        (isfield(stat,'negclusters') && ~isempty(stat.negclusters) && stat.negclusters(1).prob <= .2)
    % plot (if there is sig cluster to plots)
    cfg = [];
    cfg.alpha  = 0.2;
    cfg.zparam = 'stat';
    cfg.zlim   = [-3 3];
    cfg.colorbar = 'yes';
    ft_clusterplot(cfg, stat);
else
    figure;
    cfg = [];
    cfg.zparam = 'stat';
    cfg.zlim   = [-3 3];
    cfg.colorbar = 'yes';
    cfg.marker = 'off';
    ft_topoplotTFR(cfg,stat)
end
