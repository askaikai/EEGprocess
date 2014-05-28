function ft_classify_EEG_allChan(cond1, cond2, testFreq, testTime, mtmcycle)

% this fxn runs pattern classification between 2 conditions based on power
% in all channels.
%
% inputs:
% cond1: string. name of the condition in a single quote (e.g. 'item')
% cond2: string. name of the condition in a single quote (e.g. 'rel')
% testFreq: double. range of freq to test (e.g. [8:0.5:13])
% testTime: double. range of time to test (e.g. [2:0.1:2.5])
% mtmcycle: double. represents how many of that frequency you wanna fit (e.g. 5)
%
% history
% 05/13/14: ai wrote it based on ft_classify_EEG.m. change is that the fxn loops 
% 	through all channels and stores accuracy at each channels as data points.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first set up the environment and load neccessary data

warning 'off'

type2bsaved = ...
    [cond1 '_' cond2 '_allChan_' num2str(testTime(1)*1000) 'to' num2str(testTime(end)*1000) '.mat'];

T1 = load(['../' cond1 'correct_noSCD.mat']);
T2 = load(['../' cond2 'correct_noSCD.mat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prep data sets
cfg = [];
cfg.channel= 'all';
cfg.output = 'pow';
cfg.method ='mtmconvol';
cfg.taper  = 'hanning';
cfg.keeptrials      = 'yes';
cfg.foi        =  testFreq;
cfg.t_ftimwin   =  mtmcycle./cfg.foi;
cfg.toi= testTime;
TFRcond1 = ft_freqanalysis(cfg,T1.ft_data);
TFRcond2 = ft_freqanalysis(cfg,T2.ft_data);

% make sure data sets to compare are the same structure
if size(TFRcond1.trialinfo,2) > 5
    TFRcond1.trialinfo = TFRcond1.trialinfo(:,1:5);
end

if size(TFRcond2.trialinfo,2) > 5
    TFRcond2.trialinfo = TFRcond2.trialinfo(:,1:5);
end

% prep output data structure
out = TFRcond1;
out.dimord = 'chan_freq_time';
out.powspctrm = [];
out = rmfield(out,'trialinfo');
out.freq = mean(testFreq);
out.time = mean(testTime);
out.powspctrm = zeros(length(out.label),length(out.freq),length(out.time));

% run SVM
for chan=1:size(T1.ft_data.label,1)
    cfg=[]; % peform classification on the two TFRs
    cfg.channel = T1.ft_data.label{chan};
    cfg.frequency = [testFreq(1) testFreq(end)];
    cfg.latency = [testTime(1) testTime(end)];
    cfg.method='crossvalidate';
    cfg.design=[ones(size(TFRcond1.powspctrm,1), 1); 2.*ones(size(TFRcond2.powspctrm,1), 1)]';
    %cfg.nfolds = folds(i); defualt = 5 (80% training, 20% test)
    stat=ft_freqstatistics(cfg, TFRcond1, TFRcond2);
    out.powspctrm(chan,1,1)=stat.statistic.accuracy; 
end


ft_data = out;

save(type2bsaved, 'ft_data')