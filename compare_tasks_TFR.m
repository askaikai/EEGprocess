function compare_tasks_TFR(studyDir, task1, task2, timeTarget, freqTarget)

% this fxn runs a few ways to visualize difference between tasks. first, it
% simply averages TMI. second, it runs between-trial t-stats to identify
% electrodes that are significantly different between 2 tasks.
% run this fxn from where GA are stored, which are created using makeGA.m
% (e.g. studyDir/TFR/lowFreq)
%
% inputs:
% task1: string. name of a task. if comparing with baseline, this is the
%   "task" (e.g. 'HVLT1')
% task2: string. name of a task. if comparing with baseline, this is the
%   "baseline"
% timeTarget: 1xN double. time of interest (e.g. [.4 4.6] for both high & 
%   low);
% freqTarget: 1xN double. frequency of interest (e.g. [8 13] for low, 
%   [30 60] or [80 110] for high)
% 
% history
% 05/20/14: ai worte it based on run_ttest.m to adjust to AES
% 06/25/14: ai changed to Montecarlo to correct for multiple comparison
% instead os cluster statistics (neighbors are too far & some electrodes
% are too noisy)

warning off

!mkdir -p stats

file2bsaved = ['stats/' task1 'Vs' task2 '_' ...
    num2str(freqTarget(1)) 'to' num2str(freqTarget(2)) 'Hz_' ...
    num2str(timeTarget(1)*1000) 'to' num2str(timeTarget(2)*1000) 'msec.mat'];

Task1=load([task1 '_GA.mat']);
Task2=load([task2 '_GA.mat']);

[Task1, Task2] = selectIntersectSub(Task1, Task2); 

TMI=Task1.TFRdesc;

for i=1:length(TMI)
    Task1.TFRdesc{i} = standardizeElec(studyDir, Task1.TFRdesc{i});
    Task2.TFRdesc{i} = standardizeElec(studyDir, Task2.TFRdesc{i});
    
    TMI{i}.powspctrm = (Task1.TFRdesc{i}.powspctrm - Task2.TFRdesc{i}.powspctrm)./(Task1.TFRdesc{i}.powspctrm + Task2.TFRdesc{i}.powspctrm);
    TMI{i} = standardizeElec(studyDir, TMI{i});
    
    if sum(sum(sum(~isnan(TMI{i}.powspctrm(:,:,:)),1),2),3) == 0
        error('%dth sub is all NaN! \n', i)
    end
end

save(file2bsaved, 'TMI')

% first, plot the raw average TMI
cfg = [];
cfg.keepindividual = 'no';
GA = ft_freqgrandaverage(cfg, TMI{:});
GA.elec = TMI{1}.elec;

cfg = [];
cfg.zparam = 'powspctrm';
cfg.xlim = timeTarget;
cfg.zlim = [-.5 .5];
cfg.ylim = freqTarget;
cfg.interactive     = 'yes';
cfg.colorbar = 'yes';
figure; ft_topoplotTFR(cfg, GA);

% prepare for t-test
null = TMI;
for i=1:length(TMI)
    null{i}.powspctrm=zeros(size(TMI{i}.powspctrm));
end

% run dependent-sample T-test with Monte-Carlo
stat = run_depsamplesT(TMI, null, timeTarget, freqTarget);
stat.elec = TMI{1}.elec;
stat.elec.pos=stat.elec.chanpos;
save(file2bsaved, 'stat', '-append')

% plot
cfg = [];
cfg.highlight = 'on';
cfg.highlightchannel = find(stat.mask);
cfg.highlightsize      = 12;
cfg.comment   = 'no';
cfg.zparam = 'stat';
cfg.zlim   = [-3 3];
cfg.colorbar = 'yes';
figure; ft_topoplotER(cfg, stat)
title(['stat map of ' task1 ' vs. ' task2 ': montecarlo-corrected'])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Task1, Task2] = selectIntersectSub(Task1, Task2)

% in order to run dependent-sample T-test, we have to make sure to analyze
% only those who have data in both trial types.

task1Sub = [];
task2Sub = [];
for i = 1:length(Task1.TFRdesc)
    task1Sub = [task1Sub; Task1.TFRdesc{i}.cfg.subNum];
end

for i = 1:length(Task2.TFRdesc)
    task2Sub = [task2Sub; Task2.TFRdesc{i}.cfg.subNum];
end

commonSub = intersect(task1Sub, task2Sub);
eraseMe1 = find(ismember(task1Sub,commonSub)~=1);
Task1.TFRdesc(eraseMe1)=[];

eraseMe2 = find(ismember(task2Sub,commonSub)~=1);
Task2.TFRdesc(eraseMe2)=[];



