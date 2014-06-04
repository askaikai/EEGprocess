function TFR_hanning(trialType, testFreq, windowsize)

% this fxn reads in preprocessed individual sub's EEG data and runs
% time-frquency analysis.
% for the lower band (theta-beta), hanning taper is used, and for the
% higher band (gamma), multi-taper is used.
% run this fxn after preprocess_EEG_v2 > artifactRemovalSteps >
% splitCleanFile.m
% run this fxn from where preprocessed data are stored. output will be
% stored either in "TFR/lowFreq" or "TFR/highFreq" folder.
%
% inputs:
% trialType: string. name of the condition to analyze (e.g. 'item');
% testFreq: 1xN double array. specify freq range of interest (e.g. [1:.5:30]
%    [30:5:125];) 
% windowsize: double. how many of that freq cycle should be fit? best is 3
%   for low freq, and .25 for high freq
%
% history
% 07/26/13: ai wrote it for ItemRel_temporalExtend (based on original
% ItemRel_EEG)
% 05/19/14: ai adjusted specifically for AES 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure where the matIn comes from is correct

dataIn = [trialType '.mat'];
type2bsaved = [trialType '_TFR.mat'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off
load(dataIn,'ft_data_chopped')
ft_data = ft_data_chopped;
clear ft_data_chopped

% cfg=[]; % going to chop it into uniform 3-sec segments
% cfg.length=3;
% cfg.overlap=0;
% ft_data_chopped = ft_redefinetrial(cfg, ft_data);
% clear ft_data
% ft_data=ft_data_chopped;

for i = 1:length(ft_data.time)
    trialDur(i) = size(ft_data.time{i}, 2);
end
[xxx,trl] = max(trialDur);

if testFreq(1) < 30 % low freq
    !mkdir -p TFR/lowFreq
    type2bsaved = ['TFR/lowfreq/' type2bsaved];
    
% below are settings used in van Dijk et al., 2010.
    cfg                 = [];
    cfg.feedback        = 'textbar';
    cfg.detrend         = 'no';
    cfg.output          = 'pow';
    cfg.method          = 'mtmconvol';
    cfg.toi             = [0:.1:ft_data.time{trl}(end)]; 
    cfg.foi             = testFreq;  % [1:0.5:30]
    cfg.t_ftimwin       = zeros(1,length(cfg.foi));
    cfg.t_ftimwin(:)    = windowsize./cfg.foi;
    cfg.taper           = 'hanning';
    cfg.keeptrials      = 'yes';
    cfg.pad             = 'maxperlen';
    
elseif testFreq(1) >= 30 %high freq
    !mkdir -p TFR/highFreq
    type2bsaved = ['TFR/highfreq/' type2bsaved];
    
    % after Pascal Fries' post:
    % http://mailman.science.ru.nl/pipermail/fieldtrip/2007-August/001327.html
    cfg = [];
    cfg.output     = 'pow';
    cfg.method     = 'mtmconvol';
    cfg.taper      = 'dpss';
    cfg.toi        = [0:.1:ft_data.time{trl}(end)];
    cfg.foi        = testFreq; 
    cfg.t_ftimwin  = windowsize * ones(1,length(cfg.foi));
    cfg.tapsmofrq  = 12 * ones(1,length(cfg.foi)); % +/-12 Hz smoothing for all freqs. 
    cfg.keeptrials      = 'yes';
    cfg.pad             = 'maxperlen';
end
TFR = ft_freqanalysis(cfg, ft_data);
TFR.time = cfg.toi; % need these lines to make axis linear... FT needs to fix this
TFR.freq = cfg.foi;

save(type2bsaved,'TFR');

clear ft_data

