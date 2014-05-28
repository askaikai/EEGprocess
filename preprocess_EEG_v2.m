function preprocess_EEG_v2(subNum, sessionNum)

% this fxn reads in EEG data as one long continuous data to prepare for
% the artifact removal steps.
% 
% preprocess steps
% 1. preprocess_EEG_v2 (this)
% 2. artifactRemovalSteps
% 3. splitCleanFile
%
% overall road map is based on: 
% http://mailman.science.ru.nl/pipermail/fieldtrip/2010-March/002703.html
%
% inputs:
% subNum: double. unique sub ID (e.g. 1)
% sessionNum: double. unique session ID that's in the file name.
%   pre-exercise is 1, post is 2.
%
% history
% 05/13/14 ai modified it from preprocess_EEG.m

% cd /Users/akiko/Experiments/WendyEEG/AES_EEG_06072012/preprocessed
% load sub01_1.mat masterTime
% subNum=1;
% sessionNum=1;

warning off

SF = 250; % sampleing freq in Hz. make sure this is correct for the future study
if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);

outData = ['sub' subID '_' sessionID '.mat'];

dir = '/Users/akiko/Experiments/WendyEEG/AES_EEG_06072012';
cd(dir)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in edf data and extract hdr info & data points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[hdr, data] = readEDF(['rawdata/EEG' subID sessionID '.edf']);
save tmp hdr data -v7.3


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in lay file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recordingInfo = readLay(['rawdata/EEG' subID sessionID '.lay']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract time-stamp info from lay data & trim EEG data is neccessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t1 = find(strcmp(recordingInfo{1},'[Comments]'));
t1 = t1 + 1;
trialStart = str2double(recordingInfo{1}{t1});

a = find(strcmp(recordingInfo{1},'[ZDiag]'));
b = find(strcmp(recordingInfo{1},'[Interpolation]'));
t2 = min([a,b]);
%t2 = find(strcmp(recordingInfo{1},'[ZDiag]'));
t2 = t2-1;
trialEnd = str2double(recordingInfo{1}{t2});

load(['preprocessed/sub' subID '_1.mat'], 'masterTime')
if ~exist('masterTime')
    masterTime = makeTimeStamp(recordingInfo);
end

data = data(:,1:(masterTime(10).endTime+10)*SF);
save tmp hdr data masterTime

d.trial={data(1:16,:)};
d.label = hdr.label(1:16);
d.fsample = SF;
d.time{1}=1/SF:1/SF:(masterTime(10).endTime+10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial preprocessing on the continuous data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ft_data = defineTrialANDpreprocessing(subID, sessionID, d);
save(outData, 'ft_data', 'masterTime')

!rm tmp.mat
!mv *.mat preprocessed/

