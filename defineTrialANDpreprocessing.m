function [data] = defineTrialANDpreprocessing(subID, sessionID, dataIn)

global topDir

cfg = [];
cfg.hpfilter                = 'yes';
cfg.hpfreq                  = 1;
cfg.dftfreq                 = [60 120];
cfg.continuous              = 'yes';
cfg.trialdef.eventtype      = '?';
cfg.trialfun                = 'ft_trialfun_general';
cfg.headerfile              =[topDir '/rawdata/EEG' subID sessionID '.edf'];
cfg 						= ft_definetrial(cfg);
cfg.channel                 = 1:16;
cfg.trl                     = [1 length(dataIn.time{1}) 0];
data                     = ft_preprocessing(cfg, dataIn);

elecTmp = read_asa_elc_AI('standard_1020.elc');
[xxx, elecsel] = match_str(data.label,elecTmp.label);
elec.label = data.label;
elec.dhk = [];
elec.pnt = elecTmp.elecpos(elecsel,:);
data.elec = elec;