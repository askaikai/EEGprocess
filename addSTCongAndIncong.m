function addSTCongAndIncong(studyDir, subNum, sessionNum)

% this fxn splits ST (Stroop) into congruent or incongruent trials, AND
% REMOVES ST (from masterTime). 
% this fxn assumes that artifact rejection W/O muscle artifact rejection
% routine has been performed on the dataset. in the future, this has to be
% integrated into preprocess_EEG_vxx file.
%
% history
% 06/26/14 ai wrote it


global topDir
topDir = studyDir;

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);

outData = ['sub' subID '_' sessionID '_woMuscleArtRemoval.mat'];
cd([topDir '/preprocessed'])

% load masterTime with ST (no STcong/incong)
load(['sub' subID '_' sessionID '.mat'],'masterTime')
%load(outData,'masterTime')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in lay file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recordingInfo = readLay([topDir '/rawdata/EEG' subID sessionID '.lay']);

% first, work on ST 
for i=1:length(masterTime)
    task{i}=masterTime(i).name;
end

STidx = find(ismember(task,'ST'));

STstart = find(strcmp(recordingInfo{1},num2str(masterTime(STidx).startTime)));
STend = find(strcmp(recordingInfo{1},num2str(masterTime(STidx).endTime)));
STperiod = STstart:STend;
recordingInfo{5} = regexprep(recordingInfo{5}, ' ', '');
sSpe = regexpi(recordingInfo{5}(STperiod), 'sspe');
eSpe = regexpi(recordingInfo{5}(STperiod), 'espe');

sSpeTime = [];
for k = 1:length(sSpe)
    if ~isempty(sSpe{k})
        sSpeTime = [sSpeTime, str2num(recordingInfo{1}{STperiod(k)})];
    end
end

eSpeTime = [];
for k = 1:length(sSpe)
    if ~isempty(eSpe{k})
        eSpeTime = [eSpeTime, str2num(recordingInfo{1}{STperiod(k)})];
    end
end

if length(sSpeTime) == 3 && length(eSpeTime) == 3
    STCong1Info.name = 'STCong1';
    STCong1Info.startTime = sSpeTime(1);
    STCong1Info.endTime = eSpeTime(1);
    
    STCong2Info.name = 'STCong2';
    STCong2Info.startTime = sSpeTime(2);
    STCong2Info.endTime = eSpeTime(2);
    
    STIncongInfo.name = 'STIncong';
    STIncongInfo.startTime = sSpeTime(3);
    STIncongInfo.endTime = eSpeTime(3);
    
else
    STCong1Info.name = 'STCong1';
    STCong1Info.startTime = [];
    STCong1Info.endTime = [];
    
    STCong2Info.name = 'STCong2';
    STCong2Info.startTime = [];
    STCong2Info.endTime = [];
    
    STIncongInfo.name = 'STIncong';
    STIncongInfo.startTime = [];
    STIncongInfo.endTime = [];
  
    fprintf('Warning: ST cong/incong is not right. check manually! \n')
    
end

masterTime(end+1:end+3) = [STCong1Info, STCong2Info, STIncongInfo];
masterTime(STidx)=[];


% Then TM
for i=1:length(masterTime)
    task{i}=masterTime(i).name; % have to re-run this step since masterTime has changed
end
TMidx = find(ismember(task,'TM'));

TMstart = find(strcmp(recordingInfo{1},num2str(masterTime(TMidx).startTime)));
TMend = find(strcmp(recordingInfo{1},num2str(masterTime(TMidx).endTime)));
TMperiod = TMstart:TMend;
sSpe = regexpi(recordingInfo{5}(TMperiod), 'swri');
eSpe = regexpi(recordingInfo{5}(TMperiod), 'ewri');

sSpeTime = [];
for k = 1:length(sSpe)
    if ~isempty(sSpe{k})
        sSpeTime = [sSpeTime, str2num(recordingInfo{1}{TMperiod(k)})];
    end
end

eSpeTime = [];
for k = 1:length(sSpe)
    if ~isempty(eSpe{k})
        eSpeTime = [eSpeTime, str2num(recordingInfo{1}{TMperiod(k)})];
    end
end

if length(sSpeTime) == 4 && length(eSpeTime) == 4
    TMsimpleInfo.name = 'TMsimple';
    TMsimpleInfo.startTime = sSpeTime(2);
    TMsimpleInfo.endTime = eSpeTime(2);
    
    TMcomplexInfo.name = 'TMcomplex';
    TMcomplexInfo.startTime = sSpeTime(4);
    TMcomplexInfo.endTime = eSpeTime(4);
    
elseif length(sSpeTime) == 2 && length(eSpeTime) == 2
    TMsimpleInfo.name = 'TMsimple';
    TMsimpleInfo.startTime = sSpeTime(1);
    TMsimpleInfo.endTime = eSpeTime(1);
    
    TMcomplexInfo.name = 'TMcomplex';
    TMcomplexInfo.startTime = sSpeTime(2);
    TMcomplexInfo.endTime = eSpeTime(2);
    
else
    TMsimpleInfo.name = 'TMsimple';
    TMsimpleInfo.startTime = [];
    TMsimpleInfo.endTime = [];
    
    TMcomplexInfo.name = 'TMcomplex';
    TMcomplexInfo.startTime = [];
    TMcomplexInfo.endTime = [];
  
    fprintf('Warning: TM cong/incong is not right. check manually! \n')
    
end

masterTime(end+1:end+2) = [TMsimpleInfo, TMcomplexInfo];
masterTime(TMidx)=[];

% now make sure all fields are filled
resp='n';
while strcmp(resp, 'n')
    for i = 1:length(masterTime)
        masterTime(i)
    end
    fprintf('showing sub %s \n',subID)
    prompt = 'OK to move on? (y)es/(n)o: ';
    resp = input(prompt,'s');
    if strcmp(resp, 'n')
        masterTime = correctTimeStamp(masterTime);    
    end
end

save(outData, 'masterTime','-append')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% catch up with artifact rejection (assume jump artifacts already identified

load(['sub' subID '_' sessionID '.mat'],'dummy','datacomp')
load(outData, 'data_clean_wST')
data_clean_wST_wTM = data_clean_wST;

for i = 1:length(masterTime)
    start = (masterTime(i).startTime)*dummy.fsample;
    finish = (masterTime(i).endTime)*dummy.fsample;
    d1.trial{i} = dummy.trial{1}(:,start:finish);
    d1.time{i} = dummy.time{1}(:,start:finish);
    d1.sampleinfo(i,1) = start;
    d1.sampleinfo(i,2) = finish;
end
d1.label = dummy.label;

cfg=[];
cfg.artfctdef.reject = 'partial';
cfg.artfctdef.jump.artifact = data_clean_wST.cfg.artfctdef.jump.artifact;
data_clean = ft_rejectartifact(cfg,d1);
data_clean.elec = datacomp.elec;

save(outData,'data_clean_wST_wTM','data_clean','-append')




