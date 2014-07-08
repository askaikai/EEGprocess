function [stat, badSub] = runGroupStatsClassification(topDir, subNum, task1, task2, freqTarget, method)

% this fxn runs one-sample t-test against chance on classification data.
% input data are data from ft_classify_EEG_allchan
%
% inputs
% topDir: string. path to the study directory (e.g '/Volumes/Data/AES_EEG_06072012/')
% subNum: 1xn of potential subject list (e.g. [1:80];)
% task1: string. (e.g. 'STIncong';)
% task2: string. (e.g. 'STCong';)
% freqTarget: 1x2 double of the lowest and the highest freq range. (e.g. [4 8])
% method: string. 'dependentSampleT' to perform dependent-sample t-test
%   with Monte-Carlo correction. 'binomial' to perform binomial test
%
% history
% 06/30/14 ai wrote it
%

if freqTarget(1) < 30
    cd([topDir 'classification/lowFreq'])
else
    cd([topDir 'classification/highFreq'])
end

file2bsaved = [task1 'Vs' task2 '_' num2str(freqTarget(1)) 'to' num2str(freqTarget(2)) 'Hz_' method '.mat'];

for i=1:length(subNum)
    if subNum(i) < 10
        subID = ['0' num2str(subNum(i))];
    else
        subID = num2str(subNum(i));
    end
    sub{i} = subID;
end

count = 0;
badSub = [];
for i = 1:length(sub)
    try
        load([topDir '/preprocessed/sub' sub{i} '/classification/' task1 '_' task2 '_allChan_' num2str(freqTarget(1)) 'to' num2str(freqTarget(2)) '.mat']);
        ft_data = standardizeElec(topDir, ft_data);
        count = count + 1;
        allSub{count} = ft_data;
        allSub{count}.elec = ft_data.elec;
        allSub{count}.cfg.subNum = i;
    catch
        badSub = [badSub,i];
        
    end
end

switch method
    case 'dependentSampleT'
        null = allSub;
        for i=1:length(allSub)
            null{i}.powspctrm=ones(size(allSub{i}.powspctrm))*.5;
        end
        
        % cfg = [];
        % cfg.channel          = 'all';
        % cfg.latency          = 'all';
        % cfg.avgovertime      = 'yes';
        % cfg.avgoverfreq      = 'yes';
        % cfg.frequency        = 'all';
        % cfg.method      = 'montecarlo';
        % cfg.statistic   = 'ft_statfun_depsamplesT';
        % cfg.alpha       = 0.05;
        % cfg.correctm    = 'no';
        % cfg.correcttail = 'prob';
        % cfg.numrandomization = 5000;
        %
        % subj = length(allSub);
        % design = zeros(2,2*subj);
        % for i = 1:subj
        %     design(1,i) = i;
        % end
        % for i = 1:subj
        %     design(1,subj+i) = i;
        % end
        % design(2,1:subj)        = 1;
        % design(2,subj+1:2*subj) = 2;
        %
        % cfg.design   = design;
        % cfg.uvar     = 1;
        % cfg.ivar     = 2;
        %
        %[stat] = ft_freqstatistics(cfg, allSub{:}, null{:});
        timeTarget = 'all';
        freqTarget = 'all';
        stat = run_depsamplesT(allSub, null, timeTarget, freqTarget);
        zlim = [-3 3];
        
    case 'binomial'
        alpha = .05;
        stat = test1(allSub, alpha);
        zlim = [-.3 .7];
end
stat.elec = allSub{1}.elec;
stat.elec.pos=stat.elec.chanpos;
save(file2bsaved, 'stat')

cfg = [];
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.highlightsize      = 12;
cfg.comment   = 'no';
cfg.zparam = 'stat';
cfg.zlim   = zlim;
cfg.colorbar = 'yes';
figure; ft_topoplotER(cfg, stat)
title(['stat map of ' task1 'vs. ' task2 ': ' method '-corrected'])
