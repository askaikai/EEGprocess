function stat = run_depsamplesT(data1, data2, timeTarget, freqTarget)

cfg = [];
cfg.channel          = 'all';
cfg.latency          = timeTarget;
cfg.avgovertime      = 'yes';
cfg.avgoverfreq      = 'yes';
cfg.frequency        = freqTarget;
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'no';
cfg.correcttail = 'prob';
cfg.numrandomization = 5000;

subj = length(data1);
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

[stat] = ft_freqstatistics(cfg, data1{:}, data2{:});
stat.elec = data1{1}.elec;
stat.elec.pos=stat.elec.chanpos;
%save(file2bsaved, 'stat', '-append')

% cfg = [];
% cfg.highlight = 'on';
% cfg.highlightchannel = find(stat.mask);
% cfg.highlightsize      = 12;
% cfg.comment   = 'no';
% cfg.zparam = 'stat';
% cfg.zlim   = [-3 3];
% cfg.colorbar = 'yes';
% figure; ft_topoplotER(cfg, stat)
% title(['stat map of ' task1 ' vs. ' task2 ': montecarlo-corrected'])