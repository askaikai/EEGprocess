function ft_classify_EEG_orig(cond1, cond2, testFreq, testTime, mtmcycle, band, Chan)

% this fxn runs pattern classification between 2 conditions based on power
% in selected channels
%
% e.g. 
% cond1 = 'itemL';
% cond2 = 'itemR';
% testFreq = [8:0.5:13];
% testTime = [2:0.1:2.5];
% mtmcycle = 5; % how many of that frequency do you wanna fit?
% band = 'alpha';
% Chan = 'L'; % 'R'; or 'B' for both
%
% L/R chan in studyname/LRchan.mat
% run this fxn from /subID/classification
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% first set up the environment and load neccessary data
addpath(genpath('/Users/akiko/matlab/fieldtrip-20121022/'))
addpath(genpath('/Users/akiko/matlab/EEGprocess/DMLT/')) % need this package to run crossvalidation
studyDir = '/Users/akiko/Experiments/EEGItemRel/spatial_pilotEEG/';

load([studyDir 'LRchan_posterior10.mat'])
if strcmp(Chan, 'L')
    selectedChan = Lchan;
elseif strcmp(Chan, 'R')
    selectedChan = Rchan;
elseif strcmp(Chan, 'B')
    selectedChan = [Lchan, Rchan];
elseif strcmp(Chan, 'C')
    selectedChan = Cchan;
end

type2bsaved = ...
    [cond1 '_' cond2 '_' band '_' Chan 'chan' num2str(testTime(1)*1000) 'to' num2str(testTime(end)*1000) '.mat'];

T1 = load(['../../preprocessed/' cond1 'correct_SCDspline.mat']);
T2 = load(['../../preprocessed/' cond2 'correct_SCDspline.mat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cfg = [];
cfg.channel= selectedChan;
cfg.output = 'pow';
cfg.method ='mtmconvol';
cfg.taper  = 'hanning';
cfg.keeptrials      = 'yes';
cfg.foi        =  testFreq;
cfg.t_ftimwin   =  mtmcycle./cfg.foi;
cfg.toi= testTime;
TFRcond1 = ft_freqanalysis(cfg,T1.ft_data);
TFRcond2 = ft_freqanalysis(cfg,T2.ft_data);


cfg=[]; % peform classification on the two TFRs
cfg.method='crossvalidate';
cfg.avgovertime = 'yes';
cfg.avgoverfreq = 'yes';
cfg.design=[ones(size(TFRcond1.powspctrm,1), 1); 2.*ones(size(TFRcond2.powspctrm,1), 1)]';
%cfg.nfolds = folds(i); defualt = 5 (80% training, 20% test)
stat=ft_freqstatistics(cfg, TFRcond1, TFRcond2);

save(type2bsaved, 'stat', 'selectedChan')