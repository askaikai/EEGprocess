function preprocess_EEG(subID, CNT, ELEC)

% this fxn runs preprocessing of spatial EEG study. run this fxn from where
% raw data are stored. 
% e.g. preprocess_EEG('01','20111206_WM.cnt','../Anat/elec/GP_012012.dat')
% follow this w do_ICA_EEG.m

%%%%% vars common across subs
nTrial = 40; % number of trials per run
%%%%%

cfg = [];
cfg.dataset = CNT;

cfg.hpfilter                = 'yes';
cfg.hpfreq                  = 1;
cfg.dftfreq                 = [60 120 180];
cfg.continuous              = 'yes';
cfg.trialdef.prestim        = 2;
cfg.trialdef.poststim       = 3;
cfg.trialdef.trigchannel    = '3'; % onset of sample
cfg.trialfun                = 'akiko_trialfun_EEG';   
cfg 						= ft_definetrial(cfg);
cfg.channel                 = 1:128;
ft_data                        = ft_preprocessing(cfg);

[e.label, e.xxx, e.coord(:,1), e.coord(:,2), e.coord(:,3)] = ...
    textread(ELEC,'%s%s%f%f%f');
temp = e.coord;
e.coord(:,1) = temp(:,2);
e.coord(:,2) = -temp(:,1);
e.label{74} = 'Lm';
e.label{131} = 'Rm';

[origsel, elecsel] = match_str(ft_data.label,e.label);

elec.label = ft_data.label;
elec.dhk = [];
elec.pnt = e.coord(elecsel,:);
ft_data.elec = elec;


% cfg = [];
% cfg.elecfile                = ELEC;
% layout                      = ft_prepare_layout(cfg, ft_data);

% need to add behav data
run = 0;
master = [];
for i = 1:5
    run = run+1;
    item = load(['../behav/sub' subID 'SpatialItem_run0' num2str(run) '.mat']);
    rel = load(['../behav/sub' subID 'SpatialRel_run0' num2str(run) '.mat']);

    if mod(str2double(subID),2) % odd number sub (Item first)
        perform(:,2) = 1:nTrial;
        perform(:,3) = [item.task.trialseq(1,:) + 100]';
        perform(:,4) = item.task.response;
        perform(:,5) = item.task.keyRT;

        perform(nTrial+1:nTrial*2,2) = 1:nTrial;
        perform(nTrial+1:nTrial*2,3) = [rel.task.trialseq(1,:) + 500]';
        perform(nTrial+1:nTrial*2,4) = rel.task.response;
        perform(nTrial+1:nTrial*2,5) = rel.task.keyRT;

        perform(:,1) = run;

        master = [master; perform];
        clear perform item rel
    else
        perform(:,2) = 1:nTrial;
        perform(:,3) = [rel.task.trialseq(1,:) + 500]';
        perform(:,4) = rel.task.response;
        perform(:,5) = rel.task.keyRT;

        perform(nTrial+1:nTrial*2,2) = 1:nTrial;
        perform(nTrial+1:nTrial*2,3) = [item.task.trialseq(1,:) + 100]';
        perform(nTrial+1:nTrial*2,4) = item.task.response;
        perform(nTrial+1:nTrial*2,5) = item.task.keyRT;

        perform(:,1) = run;

        master = [master; perform];
        clear perform item rel
    end
end
   
ft_data.trialinfo = master;
 
!mkdir -p ../preprocessed
cd ../preprocessed/
save ALL.mat ft_data %layout

%do_ICA_EEG
