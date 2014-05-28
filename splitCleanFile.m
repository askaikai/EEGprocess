function splitCleanFile(subNum, sessionNum, minDur)

% step 3 of the EEG preprocessing for AES.
% this fxn selects trials that are longer than minimum length (e.g. 5sec),
% and rejects trials shorter than this duration. then it chops trials into
% shorter, but uniform length segments (e.g. 5 sec for all segments). this
% procedure will make it easirt to compare across tasks later.
%
% preprocess steps
% 1. preprocess_EEG_v2
% 2. artifactRemovalSteps
% 3. splitCleanFile (this)
%
% inputs:
% subNum: double. unique sub ID (e.g. 1)
% sessionNum: double. unique session ID that's in the file name.
% minDur: double: minimumn duration in seconds that will be included in the
% further analysis (e.g. 5)
%
% history
% 05/15/14 ai wrote it
% 05/19/14 ai added chopping process using ft_redefinetrials

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);


cd(['~/Experiments/WendyEEG/AES_EEG_06072012/preprocessed/sub' subID])
pwd
warning off

dataName = ['../sub' subID '_' sessionID '.mat'];
load(dataName, 'data_clean','masterTime')

%trlNum.dataset = 0;
try
    for i=1:length(masterTime)
        
        trlNum.task = 0;
        ft_data = data_clean;
        ft_data.trial = [];
        ft_data.time = [];
        ft_data.sampleinfo = [];
        [xxx,trlfirst] = min(abs(data_clean.sampleinfo(:,1)-masterTime(i).startTime*data_clean.fsample));
        [xxx, trllast] = min(abs(data_clean.sampleinfo(:,2)-masterTime(i).endTime*data_clean.fsample));
        %trlfirst = find(data_clean.sampleinfo(:,1)>=masterTime(i).startTime*data_clean.fsample,1);
        %trllast = find(data_clean.sampleinfo(:,2)<=masterTime(i).endTime*data_clean.fsample,1,'last');
        
        % pick trials with min length
        for j = trlfirst:trllast
            
            durTest = (data_clean.sampleinfo(j,2)-data_clean.sampleinfo(j,1))>minDur*data_clean.fsample;
            if durTest
                trlNum.task = trlNum.task + 1;
                ft_data.trial{trlNum.task} = data_clean.trial{j};
                ft_data.sampleinfo(trlNum.task,:) = data_clean.sampleinfo(j,:);
                ft_data.time{trlNum.task} = ...
                    0:1/data_clean.fsample:(data_clean.time{j}(end)-data_clean.time{j}(1));
            end
        end
        
        if isempty(ft_data.trial)
            fprintf('no %s trials for sub %d\n', masterTime(i).name, subNum)
        end
        
        % chop data into the uniform length trials
        cfg=[];
        cfg.length=minDur;
        cfg.overlap=0;
        ft_data_chopped = ft_redefinetrial(cfg, ft_data);
        for k=1:length(ft_data_chopped.time)
            ft_data_chopped.time{k}=ft_data_chopped.time{k}-ft_data_chopped.time{k}(1);
        end
        
        % save with experiment name
        outData = [masterTime(i).name '.mat'];
        save(outData, 'ft_data','ft_data_chopped')
        clear ft_data
    end
catch
    fprintf('problem at %s, trial %d\n',masterTime(i).name, j)
    dbstop if error
end

