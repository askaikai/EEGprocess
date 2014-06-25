function addSTCongAndIncong(studyDir, subNum, sessionNum)


global topDir
topDir = studyDir;

SF = 250; % sampleing freq in Hz. make sure this is correct for the future study
if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);

outData = ['sub' subID '_' sessionID '_woMuscleArtRemoval.mat'];
cd([topDir '/preprocessed'])
load(['sub' subID '_' sessionID '.mat'],'masterTime')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in lay file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recordingInfo = readLay([topDir '/rawdata/EEG' subID sessionID '.lay']);


% identify when ST started and ended
STstart = find(strcmp(recordingInfo{1},num2str(masterTime(3).startTime)));
STend = find(strcmp(recordingInfo{1},num2str(masterTime(3).endTime)));

sSpe = regexpi(recordingInfo{5}(STstart:STend), 'sspe');
eSpe = regexpi(recordingInfo{5}(STstart:STend), 'espe');
 


    
    
    











