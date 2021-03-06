function nTrials = getNumTrials(trialType, group)

% this fxn calculates the mean and sd of number of trials, depending on
% what phase and group you want to analyze
%
% inputs:
% trialType: string. name of a trial type you want to get numbers on (e.g. 
%   'Baseline');
% group: string. name of a group. (e.g. 'preC'; for 'pre' intervention, 
%   'Control'group. 'postE'; for 'post' intervention,'Exercise' group)
%
% history
% 09/06/14: ai wrote it

% get subject and pre/post, control/exercise info
topDir = '/Volumes/Data/AES_EEG_06072012/';
cd(topDir)
load condAssignment

if strfind(group,'pre')
    phase = 'pre';
elseif strfind(group,'post')
    phase = 'post';
end

if strfind(group,'C')
    subNum = control;
elseif strfind(group,'E')
    subNum = exercise;
end

cd([topDir 'preprocessed_' phase])
pwd

% now get nTrials
nTrials = [];
for i=1:length(subNum)
    if subNum(i) < 10
        sub{i} = ['0' num2str(subNum(i))];
    else
        sub{i} = num2str(subNum(i));
    end
    
    try
        load(['sub' sub{i} '/' trialType '.mat'])
        nTrials = [nTrials, length(ft_data_chopped.trial)];
    catch
        fprintf('%s does not exists in sub %s. Entering 0 \n', trialType, sub{i})
        nTrials = [nTrials, 0];
    end
end

mTrials = mean(nTrials);
sd = std(nTrials);
fprintf('%s: %d trials (sd=%d)\n', trialType, mTrials, sd)