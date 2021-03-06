function dataOut = standardizeElec(studyDir, dataIn)

% this fxn reorders .elec and data so all subjects' data would have the
% same electrode order. this function is only neccessary when keepsubject =
% 'no'. otherwide each sub's elec is stored, and could be analyzed
% accordingly.

%studyDir = '/Volumes/Data/AES_EEG_06072012/';
load([studyDir 'preprocessed_pre/sub01_1.mat'],'ft_data');
standardLabel = ft_data.elec.label;
clear ft_data

% determine the new order of presentation
[xxx, elecsel] = match_str(standardLabel,dataIn.elec.label); 
if all(xxx == elecsel) % if structures are the same as standard, no need to continue
    dataOut = dataIn;
    return
end

% determine the type of input data
% this can be raw, freq, timelock, comp, spike, source, volume, dip
israw           = ft_datatype(dataIn, 'raw');
isfreq          = ft_datatype(dataIn, 'freq');
istimelock      = ft_datatype(dataIn, 'timelock');
iscomp          = ft_datatype(dataIn, 'comp');
isspike         = ft_datatype(dataIn, 'spike');
isvolume        = ft_datatype(dataIn, 'volume');
issegmentation  = ft_datatype(dataIn, 'segmentation');
isparcellation  = ft_datatype(dataIn, 'parcellation');
issource        = ft_datatype(dataIn, 'source');
isdip           = ft_datatype(dataIn, 'dip');
ismvar          = ft_datatype(dataIn, 'mvar');
isfreqmvar      = ft_datatype(dataIn, 'freqmvar');
ischan          = ft_datatype(dataIn, 'chan');

if isfreq && isfield(dataIn, 'dimord'),
    dimtok = tokenize(dataIn.dimord, '_');
end

if isfreq && ~ismember('chan',dimtok)
    error('need chan info to run this fxn');
end

if israw && (~isfield(dataIn,'label') || ~isfield(dataIn,'elec'))
    error('need chan info to run this fxn');
end

% elec data
dataIn.elec.label = dataIn.elec.label(elecsel);
dataIn.label = dataIn.label(elecsel);

if isfield(dataIn.elec,'chanpos')
    dataIn.elec.chanpos = dataIn.elec.chanpos(elecsel,:);
end

if isfield(dataIn.elec,'pos')
    dataIn.elec.pos = dataIn.elec.pos(elecsel,:);
end

if isfield(dataIn.elec,'elecpos')
    dataIn.elec.elecpos = dataIn.elec.elecpos(elecsel,:);
end

% freq data
if isfreq
    if ~isfield(dataIn, 'powspctrm')
        error('definitely need powspectrm');
    end
    
    dataIn.powspctrm = dataIn.powspctrm(elecsel,:,:);
    
    if isfield(dataIn, 'powspctrmsem')
        dataIn.powspctrmsem = dataIn.powspctrmsem(elecsel,:,:);
    end   
end

% raw data
if israw
    if ~isfield(dataIn, 'trial')
        error('definitely need trial');
    end
    
    for i = 1:length(dataIn.trial)
        dataIn.trial{i} = dataIn.trial{i}(elecsel,:);
    end
end

% other data type: need to grow this fxn as the need comes up
if istimelock||iscomp||isspike||isvolume||issegmentation||...
        isparcellation||issource||isdip||ismvar||isfreqmvar||ischan
    
    error('YO! need to write a new code here to accomodate a new file type!');
end

dataOut = dataIn;
    
    
   

