function preprocess_EEG(subNum, sessionNum)

% this fxn prepares EEG data for analysis by running the following
% procedures;
% 1. read in .edf files
% 2. read in .lay files
%
% inputs:
% subNum: double. subject number (e.g. 1;)
% session: double. session number. 1 for pre, 2 for post exercize (e.g. 1)
%
% history:
% 04/30/14: ai copied from JHU EEG project
% 05/05/14: ai completed for sub01, pre-exercise session

dir = '/Users/akiko/Experiments/WendyEEG/AES_EEG_06072012';
cd(dir)

SF = 250; % sampleing freq in Hz. make sure this is correct for the future study
if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);

outData = ['sub' subID '_' sessionID '.mat'];

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

masterTime = makeTimeStamp(recordingInfo);

data = data(:,1:(masterTime(10).endTime+10)*SF);
save tmp hdr data masterTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% organize data based on the time stamp
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% follow this procedure:
% http://fieldtrip.fcdonders.nl/faq/how_can_i_import_my_own_dataformat
d = [];
d.label = hdr.label;
d.fsample = SF;
preDur = 2; % each epoch starts 2 sec before the trial onset
postDur = 2; % ...until 2 sec after the end of the trial
for i = 1:length(masterTime)
    start = (masterTime(i).startTime-preDur)*SF;
    finish = (masterTime(i).endTime+postDur)*SF;
    d.trial{i} = data(:,start:finish);
    d.time{i} = linspace(masterTime(i).startTime-preDur, ...
        masterTime(i).endTime+postDur, length(d.trial{i}))-masterTime(i).startTime;
end

% basic preprocessing
cfg = [];
cfg.hpfilter                = 'yes';
cfg.hpfreq                  = 1;
cfg.dftfreq                 = [60 120 180];
cfg.continuous              = 'yes';
cfg.channel                 = 1:16;
ft_data                       = ft_preprocessing(cfg, d);

% create elec layout

elecTmp = read_asa_elc_AI('standard_1020.elc');
[xxx, elecsel] = match_str(ft_data.label,elecTmp.label);
elec.label = ft_data.label;
elec.dhk = [];
elec.pnt = elecTmp.elecpos(elecsel,:);
ft_data.elec = elec;

% cfg = [];
% cfg.channel  = ft_data.label;
% %cfg.layout   = 'elec1020.lay';
% cfg.layout   = 'standard_1020.elc';
% cfg.feedback = 'yes';
% lay = ft_prepare_layout(cfg);
% ft_data.lay = lay;

% timing check
for i=1:10
    if ft_data.time{i}(end) - ft_data.time{i}(1) ~= ...
            (masterTime(i).endTime - masterTime(i).startTime)+4
        fprintf('check timing in the trial %d \n',i);
    else
        fprintf('trial %d time OK \n',i);
    end
end

% save file
!rm tmp.mat
!mkdir -p preprocessed
cd preprocessed
save(outData, 'ft_data','masterTime')

% %%%% demonstration
% cfg = [];
% cfg.xlim=[0 .5];
% cfg.channel = {'all','-O2'};
% cfg.showlabels    = 'yes';
% ft_multiplotER(cfg,ft_data)


