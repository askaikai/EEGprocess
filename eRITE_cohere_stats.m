function eRITE_cohere_stats(refchan, cond1, cond2, band)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% change here

% refchan = 'RD7'; % LC3/RA2/LL11/RD7
% cond1 = 'item';
% cond2 = 'rel';
% band = 'alpha';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off

type2bsaved = ['plv_' band '_' cond1 '_' cond2 '_ref' refchan '.mat'];

%addpath(genpath('/Users/akiko/matlab/fieldtrip-20120103/'))
subID = {'01','02', '03', '04', '05', '06', '08', '11', '12', '16', '17', '18', '19', '22', '23', '24', '25', '27'}; % excluded Ps who lost >30% of trials
%subID = {'01'};
studyDir = ['/Volumes/KaraData2T/eRITE/'];
testTime = [4.2 5.7];

if(strcmp(band, 'alpha'))
    freqTarget = [10.5 10.5];
    smooth = 2.5;
    foilim = [8 13];
    nTaper1 = 8; % change depending on data
    nTaper2 = 8;
else % gamma
    freqTarget = [80 80];
    smooth = 10;
    foilim = [70 90];
    nTaper1 = 33; % change depending on data
    nTaper2 = 33;
end

for m = 1:length(subID)
    
    data1 = load([studyDir subID{m} 'EEGTempExtend/preprocessed/' cond1 'correct_noSCD.mat']);
    data2 = load([studyDir subID{m} 'EEGTempExtend/preprocessed/' cond2 'correct_noSCD.mat']);
    
    cfg                 = [];
    cfg.feedback        = 'textbar';
    cfg.detrend         = 'no';
    cfg.output          = 'fourier';
    cfg.method          = 'mtmconvol';
    cfg.toi             = [-2:0.1:9]; 
    cfg.foi             = [1:0.5:30];
    cfg.t_ftimwin       = zeros(1,length(cfg.foi));
    cfg.t_ftimwin(:)    = 5./cfg.foi; % at alpha (testFreq)
    cfg.taper           = 'hanning';
    cfg.keeptrials      = 'yes';
    
    freq1          = ft_freqanalysis(cfg, data1.ft_data);
    freq2          = ft_freqanalysis(cfg, data2.ft_data);
    
    cfg           = [];
    cfg.method    = 'plv'; % was 'plv' when akiko last used it, could be 'coh' for spectral coherence
    cfg.channelcmb = {refchan 'all'};
    coh1          = ft_connectivityanalysis(cfg, freq1);
    coh2          = ft_connectivityanalysis(cfg, freq2);
    
    for i =1:size(coh1.labelcmb,1)
        coh1.label{i} = [coh1.labelcmb{i, 2}];
    end
    coh1 = rmfield(coh1, 'labelcmb');
    
    for i =1:size(coh2.labelcmb,1)
        coh2.label{i} = [coh2.labelcmb{i, 2}];
    end
    coh2 = rmfield(coh2, 'labelcmb');
    
    cohdiff{m} = coh1;
    cohnull{m} = coh1;
     cohdiff{m}.plvspctrm = ((atanh(coh1.plvspctrm)-1/(2*nTaper1-2))-(atanh(coh2.plvspctrm)-1/(2*nTaper2-2))) / ...
         sqrt((1/(2*nTaper1-2))+(1/(2*nTaper2-2))); 
    %cohdiff{m}.cohspctrm = atanh(coh1.cohspctrm)- atanh(coh2.cohspctrm);    
    cohnull{m}.plvspctrm(:) = 0;
    
    clear *data *freq item*
end

save(type2bsaved,'cohdiff', 'cohnull', 'coh1', 'coh2');

% stats
freqIn = cohnull{1}.freq;
[xxx, array_position(1)] = min(abs(freqIn - freqTarget(1)));
[xxx, array_position(2)] = min(abs(freqIn - freqTarget(2)));

warning off
cfg = [];
cfg.latency          = [4.2 5.7]; % i added this 
cfg.avgovertime      = 'yes'; % i changed this from no
cfg.avgoverfreq      = 'yes';
cfg.frequency        = [freqIn(array_position(1)), freqIn(array_position(2))];
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.parameter        = 'cohspctrm';
cfg.correctm         = 'cluster';
cfg.clusterstatistic = 'maxsum';
%cfg.channel          = '-RA2';
cfg.minnbchan        = 0;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.clusteralpha     = 0.05; % control admission to a cluster
cfg.alpha            = 0.05; % FA
cfg.numrandomization = 100;
cfg_neighb.method    = 'distance';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, cohnull{1});

subj = length(cohdiff);
design = zeros(2,2*subj);
for i = 1:subj
    design(1,i) = i;
end
for i = 1:subj
    design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

[stat] = ft_freqstatistics(cfg, cohdiff{:}, cohnull{:});
stat.elec = cohnull{1}.elec;

save('stat_cohere_RC7seed.mat','stat','-append');


cfg = [];
cfg.alpha  = 0.2;
cfg.zparam = 'stat';
cfg.zlim   = [-2.5 2.5];
cfg.colorbar = 'yes';
cfg.highlight          = 'on';
cfg.highlightsymbol = '*';
cfg.highlightsize      = 10;
cfg.highlightfontsize  = 20;
%cfg.marker             = 'labels';
ft_clusterplot(cfg, stat);

