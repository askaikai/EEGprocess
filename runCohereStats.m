function runCohereStats(studyDir, phase, subNum, refChan, cond1, cond2, band)

% this function first calculates coherence (specfied in 'cfg.method') for
% each of conditions, tranforms coherence to arctangent, and finaly runs
% dependent sample T-test, corrected for multiple comparisons.
% this is written for EEGItemRel
%
% inputs
% studyDir: string. study directory (e.g. '/Volumes/Data/AES_EEG_06072012/')
% phase: string. Either 'pre' or 'post' to specify whether the data came
% from pre- or post-intervention, respectively
% subNum: 1xN array of doubles to specify subjects to analyze
% refChan: string. Name of a reference electrode (e.g. 'Fp1')
% cond1: string. Name of one of the conditions (e.g. 'STIncong';)
% cond2: string. Name of the other condition (e.g. 'Baseline';)
% band: string. Either 'alpha' or 'gamma'. Adjust accordingly
%
% history
% 09/01/2014: ai copied from eRITE_cohere_stats

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% book keeping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off

for i=1:length(subNum)
    if subNum(i) < 10
        subID{i} = ['0' num2str(subNum(i))];
    else
        subID{i} = num2str(subNum(i));
    end
end

cd(studyDir)
!mkdir -p Cohere
cd Cohere
pwd
file2bsaved = ['plv_' band '_' phase cond1 '_' phase cond2 '_ref' refChan '.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% data prep: indiv sub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(strcmp(band, 'alpha'))
    freqTarget = [8 13];
    timeTarget = [.4:0.1:4.6];
%     smooth = 2.5;
%     foilim = [8 13];
%     nTaper1 = 8; % change depending on data
%     nTaper2 = 8;
else % gamma
    freqTarget = [30 80];
%     smooth = 10;
%     foilim = [70 90];
%     nTaper1 = 33; % change depending on data
%     nTaper2 = 33;
end

for m = 1:length(subID)
    
    data1 = load([studyDir '/preprocessed_' phase '/sub' subID{m} '/' cond1 '.mat']);
    data2 = load([studyDir '/preprocessed_' phase '/sub' subID{m} '/' cond2 '.mat']);
    
    data1.ft_data_chopped = standardizeElec(studyDir, data1.ft_data_chopped);
    data2.ft_data_chopped = standardizeElec(studyDir, data2.ft_data_chopped);
    
    cfg                 = [];
    cfg.feedback        = 'textbar';
    cfg.detrend         = 'no';
    cfg.output          = 'fourier';
    cfg.method          = 'mtmconvol';
    cfg.toi             = timeTarget;
    cfg.foi             = [1:0.5:30];
    cfg.t_ftimwin       = zeros(1,length(cfg.foi));
    cfg.t_ftimwin(:)    = 5./cfg.foi; % at alpha (testFreq)
    cfg.taper           = 'hanning';
    cfg.keeptrials      = 'yes';
    
    freq1          = ft_freqanalysis(cfg, data1.ft_data_chopped);
    freq2          = ft_freqanalysis(cfg, data2.ft_data_chopped);
    
    cfg           = [];
    cfg.method    = 'plv'; % could be 'coh' for spectral coherence
    cfg.channelcmb = {refChan 'all'};
    coh1          = ft_connectivityanalysis(cfg, freq1);
    coh2          = ft_connectivityanalysis(cfg, freq2);
    
    for i =1:size(coh1.labelcmb,1)
        coh1.label{i} = [coh1.labelcmb{i, 2}];
    end
    coh1 = rmfield(coh1, 'labelcmb');
    coh1.powspctrm = coh1.plvspctrm;
    coh1 = rmfield(coh1, 'plvspctrm');
    
    for i =1:size(coh2.labelcmb,1)
        coh2.label{i} = [coh2.labelcmb{i, 2}];
    end
    coh2 = rmfield(coh2, 'labelcmb');
    coh2.powspctrm = coh2.plvspctrm;
    coh2 = rmfield(coh2, 'plvspctrm');
    
    cohdiff{m} = coh1;
    cohnull{m} = coh1;
%     cohdiff{m}.plvspctrm = ((atanh(coh1.plvspctrm)-1/(2*nTaper1-2))-(atanh(coh2.plvspctrm)-1/(2*nTaper2-2))) / ...
%         sqrt((1/(2*nTaper1-2))+(1/(2*nTaper2-2)));
    cohdiff{m}.powspctrm = atanh(coh1.powspctrm)- atanh(coh2.powspctrm);
    cohnull{m}.powspctrm(:) = 0;
    
    clear *data *freq item*
end

save(file2bsaved,'cohdiff', 'cohnull');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run group stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freqIn = cohdiff{1}.freq;
[xxx, array_position(1)] = min(abs(freqIn - freqTarget(1)));
[xxx, array_position(2)] = min(abs(freqIn - freqTarget(2)));

freqTarget = [freqIn(array_position(1)), freqIn(array_position(2))];
tTarget = [timeTarget(1), timeTarget(end)];
stat = run_depsamplesT(cohdiff, cohnull, tTarget, freqTarget);
stat.elec = cohdiff{1}.elec;
stat.elec.pos=stat.elec.chanpos;
stat.dimord = 'chan';
save(file2bsaved, 'stat', '-append')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make sure elements in stat are all column vectors
stat.prob = stat.prob(:);
stat.cirange = stat.cirange(:);
stat.mask = stat.mask(:);
stat.stat = stat.stat(:);
stat.ref = stat.ref(:);

cfg = [];
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.highlightsize      = 12;
cfg.comment   = 'no';
cfg.zparam = 'stat';
cfg.zlim   = [-3 3];
cfg.colorbar = 'yes';
figure; ft_topoplotER(cfg, stat)
title(['stat map of ' cond1 ' vs. ' cond2 ': montecarlo-corrected'])
