function ft_data = calcMSCohere(topDir, subNum, task, seed)

% this fxn sets the input electrode as seed and calculate magnitude-squared
% coherence between it and all elecs, including itself.
%
% inputs:
% topDir: string. study directory (e.g. '/Volumes/Data/AES_EEG_06072012/')
% subNum: double. subject ID (e.g. 1)
% task: string. name of the task you want to examine (e.g. 'Baseline')
% seed: string. name of the electrode used as a seed (e.g. 'F8')

warning off

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

cd ([topDir 'preprocessed/sub' subID '/'])
load([task '.mat'],'ft_data_chopped')
ft_data_chopped = standardizeElec(topDir, ft_data_chopped);
!mkdir -p MSCohere
cd MSCohere

data2bsaved = ['seed' seed];

seedIdx = 0;
for i = 1:length(ft_data_chopped.label)
    if strcmp(ft_data_chopped.label(i),seed)
        seedIdx = i;
        break
    end
end

if seedIdx == 0
    error('task %s does not exist for sub %d \n', task, subNum)
end

windowInSec = 2; % I want to look at 2sec window
windowsize = windowInSec * ft_data_chopped.fsample; % convert to number of data points
overlap = windowsize/2; % half-overlap in terms of number of data points

% to loop through each elec and calculate mscohere 
for chan = 1:length(ft_data_chopped.label) % channel
    for i = 1:length(ft_data_chopped.trial) % trial
              [powspctrm(i,chan,:) freq] = ...
                     mscohere(ft_data_chopped.trial{i}(seedIdx,:),ft_data_chopped.trial{i}(chan,:),...
                     hanning(windowsize), overlap, windowsize,ft_data_chopped.fsample);
     end
end

% organize output & save
outData.powspctrm = powspctrm;
outData.freq = freq;
outData.label = ft_data_chopped.label;
outData.dimord = 'rpt_chan_freq';
outData.elec = ft_data_chopped.elec;
outData.trialinfo = ft_data_chopped.trialinfo;
outData.ref = seed;

ft_data = outData;
save(data2bsaved, 'ft_data')

% plot
desc = ft_freqdescriptives([], ft_data);
desc.elec = ft_data.elec;

cfg = [];
cfg.colorbar = 'yes';
cfg.interactive     = 'yes';
cfg.zlim = [0 1];
cfg.channel = {'all',['-' seed]};
figure; ft_topoplotTFR(cfg, desc)
title(['MSCohere with ' seed])


