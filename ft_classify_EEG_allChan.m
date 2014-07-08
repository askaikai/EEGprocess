function ft_classify_EEG_allChan(topDir, subNum, cond1, cond2, testFreq, testTime, windowSize)

% this fxn runs pattern classification between 2 conditions based on power
% in all channels.
% after running this fxn for all subjects, create GA, and run group-level
% permutation t-test (against chance = .5) to deterine subset of electrode
% that dissociate trial types
%
% inputs:
% topDir: string. study directory (e.g. '/Volumes/Data/AES_EEG_06072012/')
% subNum: double. subject ID (e.g. 1)
% cond1: string. name of the condition in a single quote (e.g. 'STIncong')
% cond2: string. name of the condition in a single quote (e.g. 'STCong')
% testFreq: double. range of freq to test (e.g. [4:0.5:8])
% testTime: double. range of time to test (e.g. [.4:.1:4.6])
% windowSize: double. represents how many of that frequency you wanna fit (e.g. 3 or .25)
%
% history
% 05/13/14: ai wrote it based on ft_classify_EEG.m. change is that the fxn loops
% 	through all channels and stores accuracy at each channels as data points.
% 06/11/14: ai modified so it ignores time inputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first set up the environment and load neccessary data

warning 'off'


if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

cd([topDir 'preprocessed/sub' subID])
!mkdir -p classification
cd classification
pwd

type2bsaved = ...
    [cond1 '_' cond2 '_allChan_' num2str(testFreq(1)) 'to' num2str(testFreq(end)) '.mat'];

% load in data and quality check
T1 = load(['../' cond1 '.mat'], 'ft_data_chopped');
T2 = load(['../' cond2 '.mat'], 'ft_data_chopped');

for i = 1:length(T1.ft_data_chopped.trial)
    t1(i) = sum(T1.ft_data_chopped.trial{i}(:));
end

if sum(isnan(t1)) ~= 0
    error('entry needs to be all real numbers');
end

T1.ft_data_chopped = standardizeElec(topDir, T1.ft_data_chopped);

for i = 1:length(T2.ft_data_chopped.trial)
    t2(i) = sum(T2.ft_data_chopped.trial{i}(:));
end

if sum(isnan(t2)) ~= 0
    error('entry needs to be all real numbers');
end

T2.ft_data_chopped = standardizeElec(topDir, T2.ft_data_chopped);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% prep data sets
if testFreq(1) < 30
    cfg = [];
    cfg.channel    = 'all';
    cfg.output     = 'pow';
    cfg.method     = 'mtmconvol';
    cfg.taper      = 'hanning';
    cfg.keeptrials = 'yes';
    cfg.toi        =  testTime;
    cfg.foi        =  testFreq;
    cfg.t_ftimwin  =  windowSize./cfg.foi;
    
elseif testFreq(1) >= 30
    cfg = [];
    cfg.channel    = 'all';
    cfg.output     = 'pow';
    cfg.method     = 'mtmconvol';
    cfg.taper      = 'dpss';
    cfg.foi        = testFreq;
    cfg.toi        = testTime;
    cfg.t_ftimwin  = windowSize * ones(1,length(cfg.foi));
    cfg.tapsmofrq  = 12 * ones(1,length(cfg.foi)); % +/-12 Hz smoothing for all freqs. 
    cfg.keeptrials = 'yes';
end
TFRcond1 = ft_freqanalysis(cfg,T1.ft_data_chopped);
TFRcond2 = ft_freqanalysis(cfg,T2.ft_data_chopped);

% prep output data structure
out = TFRcond1;
out.dimord = 'chan_freq_time';
out.powspctrm = [];
out = rmfield(out,'trialinfo');
out.freq = mean(testFreq);
out.time = mean(TFRcond1.time);
out.powspctrm = zeros(length(out.label),length(out.freq),length(out.time));

% run SVM
for chan=1:size(T1.ft_data_chopped.label,1)
    cfg=[]; % peform classification on the two TFRs
    cfg.channel = T1.ft_data_chopped.label{chan};
    cfg.frequency = [testFreq(1) testFreq(end)];
    cfg.latency = [testTime(1) testTime(end)];
    cfg.method='crossvalidate';
    cfg.design=[ones(size(TFRcond1.powspctrm,1), 1); 2.*ones(size(TFRcond2.powspctrm,1), 1)]';
    cfg.statistic = {'accuracy' 'binomial' 'contingency'};
    
    % if sample sizes are really different, re-sample and down-sample the
    % less- and more-frequent trials (one trial more than 1.5x as many)
    if min(size(TFRcond1.powspctrm,1), size(TFRcond2.powspctrm,1))*1.5 <= ...
            max(size(TFRcond1.powspctrm,1), size(TFRcond2.powspctrm,1))
        cfg.mva = {dml.standardizer() dml.svm()};
        cfg.resample = true;
    end
    
    stat=ft_freqstatistics(cfg, TFRcond1, TFRcond2);
    out.powspctrm(chan,1,1)=stat.statistic.accuracy;
    out.binomial(chan,1,1)=stat.statistic.binomial;
end

ft_data = out;
ft_data.elec = T1.ft_data_chopped.elec;

cfg = [];
cfg.colorbar = 'yes';
cfg.zlim = [.3 .7];
figure;
ft_topoplotTFR(cfg, ft_data);
title(['sub' subID '_' cond1 'vs' cond2])

save(type2bsaved, 'ft_data')
