function addSTCongAndIncong(studyDir, subNum, sessionNum)


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in lay file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recordingInfo = readLay([topDir '/rawdata/EEG' subID sessionID '.lay']);

% identify when ST started and ended
STstart = find(strcmp(recordingInfo{1},num2str(masterTime(3).startTime)));
STend = find(strcmp(recordingInfo{1},num2str(masterTime(3).endTime)));
STperiod = STstart:STend;
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
masterTime(3)=[];

resp='n';
while strcmp(resp, 'n')
    for i = 1:length(masterTime)
        masterTime(i)
    end
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
load(outData, 'data_clean')
data_clean_wST = data_clean;

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
cfg.artfctdef.jump.artifact = data_clean.cfg.artfctdef.jump.artifact;
data_clean = ft_rejectartifact(cfg,d1);
data_clean.elec = datacomp.elec;

save(outData,'data_clean_wST','data_clean','-append')




