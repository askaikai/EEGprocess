function artifactRemovalSteps_woMuscle(studyDir)

% these are steps to follow to remove artifact (eye movements and jump
% artifacts) in continuous data.
% output is segmented time-series that are artifact-free
%
% preprocess steps
% 1. preprocess_EEG_v2
% 2. artifactRemovalSteps(_woMuscle) (this)
% 2.1 addSTCongAndIncong
% 3. splitCleanFile
%
% inputs:
% studyDir: string. path to the study dir, (e.g. '/user/Experiment/studyDir')
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set directory & parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global topDir
topDir = studyDir;

cd(topDir)

cfg = [];
cfg.method = 'initSub';
out = artifactRemoveStep(cfg);
dataName = out.dataName;
masterTime = out.masterTime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOG: ICA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

content = who('-file', dataName);
if ~any(ismember(content, 'dummy'))
    load(dataName)
    
    cfg = [];
    cfg.data = datacomp;
    cfg.method = 'visualize_ICA';
    artifactRemoveStep(cfg);
    
    prompt = 'componets to look at ([xxx]): ';
    comp2view = input(prompt);
    cfg = [];
    cfg.method = 'visualize_artifact';
    cfg.comp2view = comp2view;
    cfg.datacomp = datacomp;
    artifactRemoveStep(cfg);
    
    
    prompt = 'componets to remove ([xxx]): ';
    comp2remove = input(prompt);
    cfg=[];
    cfg.component = [comp2remove];
    dummy = ft_rejectcomponent(cfg, datacomp);
    save(dataName,'dummy','-append')
    close all
else
    load(dataName,'dummy','datacomp')
end

namePiece  = tokenize(dataName,'.','rep');
dataName = ['..' namePiece{1} '_woMuscleArtRemoval.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% jump artifact. Just save the time points for now
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.method = 'jumpArtifact';
cfg.dummy = dummy;
out = artifactRemoveStep(cfg);

cfg_jump = out.cfg_jump;
artifact_jump = out.artifact_jump;


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % muscle artifact. Just save the time points for now
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg = [];
% cfg.method = 'muscleArtifact';
% cfg.dummy = dummy;
% out = artifactRemoveStep(cfg);
%
% cfg_muscle = out.cfg_muscle;
% artifact_muscle = out.artifact_muscle;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% split data into each trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(masterTime)
    start = (masterTime(i).startTime)*dummy.fsample;
    finish = (masterTime(i).endTime)*dummy.fsample;
    d1.trial{i} = dummy.trial{1}(:,start:finish);
    d1.time{i} = dummy.time{1}(:,start:finish);
    d1.sampleinfo(i,1) = start;
    d1.sampleinfo(i,2) = finish;
end
d1.label = dummy.label;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now reject artifact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg=[];
cfg.artfctdef.reject = 'partial';
cfg.artfctdef.jump.artifact = artifact_jump;
%cfg.artfctdef.muscle.artifact = artifact_muscle;
data_clean = ft_rejectartifact(cfg,d1);
data_clean.elec = datacomp.elec;

save(dataName,'data_clean')


