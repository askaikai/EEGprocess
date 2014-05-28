function makeGA(freq, subNum)

% this fxn is a prep for between-trials t-test. follow this with
% compare_tasks.m to plot average TMI and permutation t-test.
% run this fxn from study/TFR/low(high)Freq
%
% input:
% freq: string. either "low" (~30Hz) or "high" (30+Hz) that corresponds to
% individual's TFR that was processed with TFR_hanning
% subNum: 1xN array of subject numbers to be GAed. (e.g. [1:3, 6,10])
%
% history
% 05/20/14: ai wrote it

% init
for i=1:length(subNum)
    if subNum(i) < 10
        subID = ['0' num2str(subNum(i))];
    else
        subID = num2str(subNum(i));
    end
    sub{i} = subID;
end

warning off
studyDir='/Users/akiko/Experiments/WendyEEG/AES_EEG_06072012/';

cd([studyDir 'TFR/' freq 'Freq'])
pwd

load([studyDir 'preprocessed/sub01_1.mat'],'masterTime')
for i=1:length(masterTime)
    task{i}=masterTime(i).name;
end

%%% now loop through subs to get descriptive stats

for j=1:length(task)
    for i=1:length(sub)
        load([studyDir,'preprocessed/sub' sub{i} '/TFR/' freq 'Freq/' task{j} '_TFR.mat'],'TFR')
        
        cfg=[];
        cfg.jackknife     = 'yes';
        cfg.variance = 'yes';
        TFRdesc{i} = ft_freqdescriptives(cfg, TFR);
        TFRdesc{i}.elec = TFR.elec;
    end
    
    outname = [task{j} '_GA.mat'];
    save(outname, 'TFRdesc')
    clear TFRdesc
end


% %%% plot average
% cfg = [];
% cfg.keepindividual = 'no';
% GA = ft_freqgrandaverage(cfg, itemAMI{:});
% GA.elec = itemAMI{1}.elec;
%
% cfg = [];
% cfg.zparam = 'powspctrm';
% cfg.zlim = [-.1 .1];
% cfg.interactive     = 'yes';
% cfg.colorbar = 'yes';
% figure; ft_topoplotTFR(cfg, GA);
%

