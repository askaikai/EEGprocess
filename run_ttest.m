function run_ttest(matIn1, matIn2, band, cond1, cond2, blc, latency)

% e.g. 
% matIn1 = 'alpha_GA.mat';
% matIn2 = matIn1; or 'alpha_GA_bl.mat';... if dat1&2 are from different mat 
% band = 'alpha';
% cond1 = 'itemAMI'; cond2 = 'null'; or
% cond1 = 'itemL'; cond2 = 'itemR';
% blc = 1;
% latency = [1 2.5]; % delay

warning off
addpath(genpath('/Users/akiko/matlab/fieldtrip-20121022/'))

if(strcmp(band, 'alpha'))
    freqTarget = [8 13];
elseif(strcmp(band, 'theta'))
    freqTarget = [5 7];
else % gamma
    freqTarget = [70 90];
end

if blc
    file2bsaved = ['stat_' cond1 'vs' cond2 '_' band '_blc.mat'];
else
    file2bsaved = ['stat_' cond1 'vs' cond2 '_' band '_BLperiod.mat'];
end

dat = load(matIn1, cond1);
dat1 = getfield(dat, cond1);
dat = load(matIn2, cond2);
dat2 = getfield(dat, cond2);

% freqIn = dat1{1}.freq;
% [xxx, array_position(1)] = min(abs(freqIn - freqTarget(1)));
% [xxx, array_position(2)] = min(abs(freqIn - freqTarget(2)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning off
cfg = [];
cfg.channel          = 'all';
cfg.latency          = latency;
cfg.avgovertime      = 'yes';
cfg.avgoverfreq      = 'yes';
cfg.frequency        = freqTarget;
cfg.method           = 'montecarlo';
cfg.statistic        = 'depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 0;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 500;
cfg_neighb.method    = 'distance';
cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, dat1{1});

subj = length(dat1);
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

[stat] = ft_freqstatistics(cfg, dat1{:}, dat2{:});
stat.elec = dat1{1}.elec;
save(file2bsaved, 'stat')

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
    cfg.xlim = [1 2.5];
    cfg.zlim   = [-3 3];
    cfg.colorbar = 'yes';
    cfg.marker = 'off';
    ft_topoplotTFR(cfg,stat)
end
