
subNum = 1;

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end
comp2bsaved = ['sub' subID '_1_companalysis.mat'];

load(['sub' subID '_1.mat'], 'ft_data')


cfg=[];
cfg.trials = 1;
baseline = ft_selectdata(cfg, ft_data);
baseline.trial={baseline.trial{1}};

%muscle artifact: http://fieldtrip.fcdonders.nl/reference/ft_artifact_muscle?s[]=muscle&s[]=artifact
ft_data.trl = ft_data.sampleinfo;
ft_data.trl(:,3) = -ft_data.fsample*2;
if ft_data.trl(1,1) < 256
    ft_data.trl(1,1) = 256;
end
ft_data.trl(end,2) = ft_data.trl(end,2)-256;

cfg = [];
cfg.trl = ft_data.trl;
cfg.continuous = 'yes';
cfg.artfctdef.muscle.channel='all';
cfg.artfctdef.muscle.bpfreq      = [110 122];
[cfg, artifact] = ft_artifact_muscle(cfg, ft_data);

cfg=[];
cfg.artfctdef.reject = 'partial'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.muscle.artifact = artifact;
dummy = ft_rejectartifact(cfg,ft_data);
for i=1:length(dummy.time)
    dummy.time{i}=dummy.time{i}-dummy.time{i}(1);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 1: take note on potentially bad channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg          = [];
cfg.method   = 'trial';
cfg.megscale = 1;
%cfg.latency     = [.5 2.5];
ft_data2        = ft_rejectvisual(cfg,ft_data); % just go through and see 
% which channels are potentially bad

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 2: ICA to identify blinks and eye movements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% run ICA
cfg = [];
cfg.method  = 'runica';
cfg.runica.sphering = 'off';
cfg.numcomponent = 16;
datacomp = ft_componentanalysis(cfg, ft_data);
datacomp.elec = ft_data.elec;
datacomp.dimord = 'chan_comp';

save(comp2bsaved, 'datacomp')

%%% visualize ICA components. Take note on which trials contain blink
%%% and/or eye movements
figure
k=1; f=1;
row = 4;
column = 4;
for icomp=1:16
    cfg=[];
    cfg.xlim   = [icomp icomp];
    cfg.comment = 'no';

    subplot(row, column,k);
    ft_topoplotER(cfg, datacomp);
    title(icomp);
    k = k+1;
end

%%% visualize artifact components. Identify components that represents
%%% blink
cfg = [];
cfg.channel = {datacomp.label{1} datacomp.label{7:8} datacomp.label{41}}; % components to be plotted
cfg.layout = datacomp.elec;
cfg.viewmode = 'vertical';
artf = ft_databrowser(cfg, datacomp);

%%% remove blink component (usually the 1st component)
cfg=[];
cfg.component = [1]; % note the exact numbers will vary per run
dummy = ft_rejectcomponent(cfg, datacomp);
close all

%%% visualize EOG channels. Go though trials and click on segments of
%%% trials that contain eye movements
sacc = 25;
cfg = [];
cfg.lpfilter                = 'yes';
cfg.lpfreq                  = 30;
HEG                        = ft_preprocessing(cfg, dummy);
for i=1:length(HEG.trial)
    HEG.trial{i}(1,:) = HEG.trial{i}(2,:) - HEG.trial{i}(44,:); % overwrite chan 1 w/ HEOG. 2 = LE1, 44 = RE1
end

tInt = [-1.2 2.5];
[xxx, tRange(1)] = min(abs(HEG.time{1} - tInt(1)));
[xxx, tRange(2)] = min(abs(HEG.time{1} - tInt(2)));

bad = [];
for i = 1:length(HEG.trial)
    for j = tRange(1):51:tRange(2)
        test(j) = abs(mean(HEG.trial{i}(1,j-52:j)) - mean(HEG.trial{i}(1,j+1:j+1+52))) > sacc;
    end
    
    if ~isempty(find(test))
        fprintf('check trial %d, around %2.2f sec! \n', [i, HEG.time{1}(find(test,1))]);
        bad = [bad; [i, HEG.time{1}(find(test,1))]];
    end
    clear test
end

cfg = [];
cfg.channel = {'Lm','LE1','RE1'}; % Lm is now diff wave
cfg.layout = HEG.elec;
cfg.viewmode = 'vertical';
cfg.zscale = [-sacc*1.5,sacc*1.5];
artf2 = ft_databrowser(cfg, HEG);

%%% remove trials that contain eye movements
cfg=[];
cfg.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfg.artfctdef.visual.artifact = artf2.artfctdef.visual.artifact;
dummy2 = ft_rejectartifact(cfg,dummy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% STEP 3: get rid of trials that contain spikes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg          = [];
cfg.method   = 'trial';
cfg.megscale = 1;
cfg.latency     = [.5 2.5];
ft_data        = ft_rejectvisual(cfg,dummy2);

save data_clean ft_data dummy2
clear all


% run sortdata_itemrel to sort into diff conditions
