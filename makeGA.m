function makeGA(topDir, freq, subNum)

% this fxn is a prep for between-trials t-test. follow this with
% compare_tasks.m to plot average TMI and permutation t-test.
%
% input:
% topDir: string. path to the study directory (e.g '/Volumes/Data/AES_EEG_06072012/')
% freq: string. either "low" (~30Hz) or "high" (30+Hz) that corresponds to
% individual's TFR that was processed with TFR_hanning
% subNum: 1xN array of subject numbers to be GAed. (e.g. [1:80])
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

cd([topDir 'TFR/' freq 'Freq'])
pwd

load([topDir 'preprocessed/sub01_1_woMuscleArtRemoval.mat'],'masterTime')
for i=1:length(masterTime)
    task{i}=masterTime(i).name;
end

%%% now loop through subs to get descriptive stats

for j=1:length(task)
    count = 0;
    for i=1:length(sub)
        try
            load([topDir,'preprocessed/sub' sub{i} '/TFR/' freq 'Freq/' task{j} '_TFR.mat'],'TFR')
            count = count + 1;
            
            cfg=[];
            %cfg.jackknife     = 'yes';
            cfg.variance = 'yes';
            TFRdesc{count} = ft_freqdescriptives(cfg, TFR);
            TFRdesc{count}.elec = TFR.elec;
            TFRdesc{count}.cfg.subNum = i;
        catch
            fprintf('no %s for sub %s. skipping... \n', task{j}, sub{i})
        end
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

