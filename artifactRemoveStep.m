function out = artifactRemoveStep(cfg)

if strcmp(cfg.method,'initSub')
    out = initSub;
    
elseif strcmp(cfg.method, 'run_ICA')
    ft_data = cfg.ft_data;
    dataName = cfg.dataName;
    out = run_ICA(ft_data, dataName);
    
elseif strcmp(cfg.method, 'visualize_artifact')
    datacomp = cfg.datacomp;
    comp2view = cfg.comp2view;
    visualize_artifact(datacomp, comp2view);
    
elseif strcmp(cfg.method, 'jumpArtifact')
    dummy = cfg.dummy;
    clear cfg
    out = jumpArtifact(dummy);
    
elseif strcmp(cfg.method, 'muscleArtifact')
    dummy = cfg.dummy;
    clear cfg
    out = muscleArtifact(dummy);

    
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = initSub

global topDir

prompt = 'Enter subject number: ';
subNum = input(prompt);

cd([topDir '/preprocessed/'])
warning off

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

dataName = ['sub' subID '_1.mat'];
load(dataName)
mkdir(['sub' subID])
cd(['sub' subID])
pwd
dataName = ['../sub' subID '_1.mat'];

out.dataName = dataName;
out.ft_data = ft_data;
out.masterTime = masterTime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = run_ICA(ft_data, dataName)
cfg = [];
cfg.method  = 'runica';
cfg.runica.sphering = 'off';
cfg.numcomponent = 16;
datacomp = ft_componentanalysis(cfg, ft_data);
datacomp.elec = ft_data.elec;
datacomp.dimord = 'chan_comp';

save(dataName, 'datacomp','-append')

out.datacomp = datacomp;

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
    cfg.layout = datacomp.elec;
    subplot(row, column,k);
    ft_topoplotER(cfg, datacomp);
    title(icomp);
    k = k+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function visualize_artifact(datacomp, comp2view)

%%% visualize artifact components. Identify components that represents
%%% blink

cfg = [];
cfg.channel = datacomp.label(comp2view); % components to be plotted
cfg.layout = datacomp.elec;
cfg.viewmode = 'vertical';
artifact_eye = ft_databrowser(cfg, datacomp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = jumpArtifact(dummy)

cfg = [];
cfg.continuous = 'yes';
cfg.artfctdef.zvalue.channel    = 'all';
cfg.artfctdef.zvalue.cutoff     = 20;
cfg.artfctdef.zvalue.trlpadding = 0;
cfg.artfctdef.zvalue.artpadding = 0;
cfg.artfctdef.zvalue.fltpadding = 0;
% algorithmic parameters
cfg.artfctdef.zvalue.cumulative    = 'yes';
cfg.artfctdef.zvalue.medianfilter  = 'yes';
cfg.artfctdef.zvalue.medianfiltord = 9;
cfg.artfctdef.zvalue.absdiff       = 'yes';
% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';

[cfg_jump, artifact_jump] = ft_artifact_zvalue(cfg, dummy);
out.cfg_jump = cfg_jump;
out.artifact_jump = artifact_jump;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = muscleArtifact(dummy)

cfg            = [];
cfg.continuous = 'yes';

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel = 'all';
cfg.artfctdef.zvalue.cutoff      = 4;
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0; %0.1;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [110 122]; % changed the upper limit from the default (140)
cfg.artfctdef.zvalue.bpfiltord   = 7; %changed this from the default (9);
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;

% make the process interactive
cfg.artfctdef.zvalue.interactive = 'yes';
[cfg_muscle, artifact_muscle] = ft_artifact_zvalue(cfg, dummy);

out.cfg_muscle=cfg_muscle;
out.artifact_muscle = artifact_muscle;


