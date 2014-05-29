function masterTime = makeTimeStamp(eventInfo) 

% this fxn first organizes events into a standadized format and finds the
% corresponding times.
% 
% history:
% 05/01/14: ai wrote it
%

eventTime = eventInfo{1};
event = eventInfo{5};

trialNames = {'aseline','HVLT','ST','SDM','COWAT','TM','WTAR','DS','HVLT delay','MOD'};

% find start/end point of each experiment
for i = 1:length(trialNames)
    tmp = strfind(event,trialNames{i});
    eventIndex{i} = zeros(1,length(tmp));
    eventIndex{i}(~isemptycell(tmp))=cell2num(tmp(~isemptycell(tmp)));
    clear tmp
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% need to visit each trial type to verify so we could assign time points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Baseline
baselineInfo = getBaselineInfo(eventIndex, eventTime, event)

% 2. HVLT-1
HVLT1Info = getHVLT1Info(eventIndex, eventTime, event)

% 3. ST
STInfo = getSTInfo(eventIndex, eventTime, event)

% 4. SDM
SDMInfo = getSDMInfo(eventIndex, eventTime, event)

% 5. COWAT
COWATInfo = getCOWATInfo(eventIndex, eventTime, event)

% 6. TM
TMInfo = getTMInfo(eventIndex, eventTime, event)

% 7. WTAR
WTARInfo = getWTARInfo(eventIndex, eventTime, event)

% 8. DS
DSInfo = getDSInfo(eventIndex, eventTime, event)

% 9. HVLT-2
HVLT2Info = getHVLT2Info(eventIndex, eventTime, event)

% 10. MOD
MODInfo = getMODInfo(eventIndex, eventTime, event)

% now concat
masterTime(1) = baselineInfo;
masterTime(2) = HVLT1Info;
masterTime(3) = STInfo;
masterTime(4) = SDMInfo;
masterTime(5) = COWATInfo;
masterTime(6) = TMInfo;
masterTime(7) = WTARInfo;
masterTime(8) = DSInfo;
masterTime(9) = HVLT2Info;
masterTime(10) = MODInfo;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions used
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MODInfo = getMODInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{10};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SM')==2 || sum(event{tmp(1,1)}(1:2)=='sM')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='EM')==2 || sum(event{tmp(2,1)}(1:2)=='eM')==2)) ...
            && tmp(2,2)-tmp(1,2)<1500
        % if naming seems correct, and the duration is not too long (>1500sec)
        MODInfo.name = 'MOD';
        MODInfo.startTime = tmp(1,2);
        MODInfo.endTime = tmp(2,2);
    else
        MODInfo.name = 'MOD';
        MODInfo.startTime = [];
        MODInfo.endTime = [];
        fprintf('Warning: MOD name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S'
        MODInfo.name = 'MOD';
        MODInfo.startTime = tmp(1,2);
        MODInfo.endTime = [];
        fprintf('Warning: MOD name is not right. check manually! \n')
    else
        MODInfo.name = 'MOD';
        MODInfo.startTime = [];
        MODInfo.endTime = [];
        fprintf('Warning: MOD name is not right. check manually! \n')
    end
else
    MODInfo.name = 'MOD';
        MODInfo.startTime = [];
        MODInfo.endTime = [];
        fprintf('Warning: MOD name is not right. check manually! \n')
end
        
clear tmp thisEvent    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HVLT2Info = getHVLT2Info(eventIndex, eventTime, event)

thisEvent = eventIndex{9};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SH')==2 || sum(event{tmp(1,1)}(1:2)=='sH')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='EH')==2 || sum(event{tmp(2,1)}(1:2)=='eH')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        % if naming seems correct, and the duration is not too long (>500sec)
        HVLT2Info.name = 'HVLT2';
        HVLT2Info.startTime = tmp(1,2);
        HVLT2Info.endTime = tmp(2,2);
    else
        HVLT2Info.name = 'HVLT2';
        HVLT2Info.startTime = [];
        HVLT2Info.endTime = [];
        fprintf('Warning: HVLT2 name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{10},1)},'SMOD')
        HVLT2Info.name = 'HVLT2';
        HVLT2Info.startTime = tmp(1,2);
        HVLT2Info.endTime = str2num(eventTime{find(eventIndex{10},1)});
    else
        HVLT2Info.name = 'HVLT2';
        HVLT2Info.startTime = [];
        HVLT2Info.endTime = [];
        fprintf('Warning: HVLT2 name is not right. check manually! \n')
    end
else
    HVLT2Info.name = 'HVLT2';
        HVLT2Info.startTime = [];
        HVLT2Info.endTime = [];
        fprintf('Warning: HVLT2 name is not right. check manually! \n')
end
        
clear tmp thisEvent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DSInfo = getDSInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{8};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SD')==2 || sum(event{tmp(1,1)}(1:2)=='sD')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='ED')==2 || sum(event{tmp(2,1)}(1:2)=='eD')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        % if naming seems correct, and the duration is not too long (>500sec)
        DSInfo.name = 'DS';
        DSInfo.startTime = tmp(1,2);
        DSInfo.endTime = tmp(2,2);
    else
        DSInfo.name = 'DS';
        DSInfo.startTime = [];
        DSInfo.endTime = [];
        fprintf('Warning: DS name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{9},1)},'SHVLT delay/recog')
        DSInfo.name = 'DS';
        DSInfo.startTime = tmp(1,2);
        DSInfo.endTime = str2num(eventTime{find(eventIndex{9},1)});
    else
        DSInfo.name = 'DS';
        DSInfo.startTime = [];
        DSInfo.endTime = [];
        fprintf('Warning: DS name is not right. check manually! \n')
    end
else 
    DSInfo.name = 'DS';
        DSInfo.startTime = [];
        DSInfo.endTime = [];
        fprintf('Warning: DS name is not right. check manually! \n')
end

clear tmp thisEvent 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WTARInfo = getWTARInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{7};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SW')==2 || sum(event{tmp(1,1)}(1:2)=='sW')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='EW')==2 || sum(event{tmp(2,1)}(1:2)=='eW')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        % if naming seems correct, and the duration is not too long (>500sec)
        WTARInfo.name = 'WTAR';
        WTARInfo.startTime = tmp(1,2);
        WTARInfo.endTime = tmp(2,2);
    else
        WTARInfo.name = 'WTAR';
        WTARInfo.startTime = [];
        WTARInfo.endTime = [];
        fprintf('Warning: WTAR name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{8},1)},'SDS')
        WTARInfo.name = 'WTAR';
        WTARInfo.startTime = tmp(1,2);
        WTARInfo.endTime = str2num(eventTime{find(eventIndex{8},1)});
    else
        WTARInfo.name = 'WTAR';
        WTARInfo.startTime = [];
        WTARInfo.endTime = [];
        fprintf('Warning: WTAR name is not right. check manually! \n')
    end
else
    WTARInfo.name = 'WTAR';
        WTARInfo.startTime = [];
        WTARInfo.endTime = [];
        fprintf('Warning: WTAR name is not right. check manually! \n')
end
        
clear tmp thisEvent 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TMInfo = getTMInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{6};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='ST')==2 || sum(event{tmp(1,1)}(1:2)=='sT')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='ET')==2 || sum(event{tmp(2,1)}(1:2)=='eT')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        
        % if naming seems correct, and the duration is not too long (>500sec)
        TMInfo.name = 'TM';
        TMInfo.startTime = tmp(1,2);
        TMInfo.endTime = tmp(2,2);
    else
        TMInfo.name = 'TM';
        TMInfo.startTime = [];
        TMInfo.endTime = [];
        fprintf('Warning: TM name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{7},1)},'SWTAR')
        TMInfo.name = 'TM';
        TMInfo.startTime = tmp(1,2);
        TMInfo.endTime = str2num(eventTime{find(eventIndex{7},1)});
    else
        TMInfo.name = 'TM';
        TMInfo.startTime = [];
        TMInfo.endTime = [];
        fprintf('Warning: TM name is not right. check manually! \n')
    end
else 
     TMInfo.name = 'TM';
        TMInfo.startTime = [];
        TMInfo.endTime = [];
        fprintf('Warning: TM name is not right. check manually! \n')
end
        
clear tmp thisEvent


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function COWATInfo = getCOWATInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{5};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SC')==2 || sum(event{tmp(1,1)}(1:2)=='sC')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='EC')==2 || sum(event{tmp(2,1)}(1:2)=='eC')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        % if naming seems correct, and the duration is not too long (>500sec)
        COWATInfo.name = 'COWAT';
        COWATInfo.startTime = tmp(1,2);
        COWATInfo.endTime = tmp(2,2);
    else
        COWATInfo.name = 'COWAT';
        COWATInfo.startTime = [];
        COWATInfo.endTime = [];
        fprintf('Warning: COWAT name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{6},1)},'STM')
        COWATInfo.name = 'COWAT';
        COWATInfo.startTime = tmp(1,2);
        COWATInfo.endTime = str2num(eventTime{find(eventIndex{6},1)});
    else
        COWATInfo.name = 'COWAT';
        COWATInfo.startTime = [];
        COWATInfo.endTime = [];
        fprintf('Warning: COWAT name is not right. check manually! \n')
    end
else 
    COWATInfo.name = 'COWAT';
        COWATInfo.startTime = [];
        COWATInfo.endTime = [];
        fprintf('Warning: COWAT name is not right. check manually! \n')
end

clear tmp thisEvent    
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SDMInfo = getSDMInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{4};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)==2
    if ((sum(event{tmp(1,1)}(1:2)=='SS')==2 || sum(event{tmp(1,1)}(1:2)=='sS')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='ES')==2 || sum(event{tmp(2,1)}(1:2)=='eS')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        
        % if naming seems correct, and the duration is not too long (>500sec)
        SDMInfo.name = 'SDM';
        SDMInfo.startTime = tmp(1,2);
        SDMInfo.endTime = tmp(2,2);
    else
        SDMInfo.name = 'SDM';
        SDMInfo.startTime = [];
        SDMInfo.endTime = [];
        fprintf('Warning: SDM name is not right. check manually! \n')
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{5},1)},'SCOWAT')
        SDMInfo.name = 'SDM';
        SDMInfo.startTime = tmp(1,2);
        SDMInfo.endTime = str2num(eventTime{find(eventIndex{5},1)});
    else 
        SDMInfo.name = 'SDM';
        SDMInfo.startTime = [];
        SDMInfo.endTime = [];
        fprintf('Warning: SDM name is not right. check manually! \n')
    end
else 
    SDMInfo.name = 'SDM';
        SDMInfo.startTime = [];
        SDMInfo.endTime = [];
        fprintf('Warning: SDM name is not right. check manually! \n')
end
    
clear tmp thisEvent


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function STInfo = getSTInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{3};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries
if size(tmp,1)>=2
    if ((sum(event{tmp(1,1)}(1:2)=='SS')==2 || sum(event{tmp(1,1)}(1:2)=='sS')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='ES')==2 || sum(event{tmp(2,1)}(1:2)=='eS')==2)) ...
            && tmp(2,2)-tmp(1,2)<500
        
        % if naming seems correct, and the duration is not too long (>500sec)
        STInfo.name = 'ST';
        STInfo.startTime = tmp(1,2);
        STInfo.endTime = tmp(2,2);
    elseif event{tmp(1,1)}(1)=='S' && strcmp(event{find(eventIndex{4},1)},'SSDM')
        STInfo.name = 'ST';
        STInfo.startTime = tmp(1,2);
        STInfo.endTime = str2num(eventTime{find(eventIndex{4},1)});
    end
elseif size(tmp,1)==1
    if event{tmp(1,1)}(1)=='S' && (tmp(1,2) < str2num(eventTime{find(eventIndex{4},1)}))
        % if only the start was recorded, and the start time is smaller
        % than the beginning of the next experiment (sanity check)
        STInfo.name = 'ST';
        STInfo.startTime = tmp(1,2);
        STInfo.endTime = str2num(eventTime{find(eventIndex{4},1)});
    elseif event{tmp(1,1)}(1)=='E' 
        % if only the end was recorded
        STInfo.name = 'ST';
        STInfo.startTime = [];
        STInfo.endTime = [];
        fprintf('Warning: ST only end was recorded. check manually! \n')
    end
else
    % otherwise, manually check
        STInfo.name = 'ST';
        STInfo.startTime = [];
        STInfo.endTime = [];
        fprintf('Warning: ST only end was recorded. check manually! \n')
end

clear tmp thisEvent
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HVLT1Info = getHVLT1Info(eventIndex, eventTime, event)

thisEvent = eventIndex{2};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 4 entries (S/EHVLT and S/EHVLT-recall), but only the first 
% 2 matters
if size(tmp,1)==4
    if ((sum(event{tmp(1,1)}(1:2)=='SH')==2 || sum(event{tmp(1,1)}(1:2)=='sH')==2) && ...
            (sum(event{tmp(2,1)}(1:2)=='EH')==2 || sum(event{tmp(2,1)}(1:2)=='eH')==2)) ...
            && tmp(2,2)-tmp(1,2)<300
        % if naming seems correct, and the duration is not too long (>300sec)
        HVLT1Info.name = 'HVLT1';
        HVLT1Info.startTime = tmp(1,2);
        HVLT1Info.endTime = tmp(2,2);
    else
        HVLT1Info.name = 'HVLT1';
        HVLT1Info.startTime = [];
        HVLT1Info.endTime = [];
        fprintf('Warning: HVLT1 naming is not right. check event name manually! \n')
    end
elseif size(tmp,1)==3
    %%%% do something here when you encounter this 
    
    HVLT1Info.name = 'HVLT1';
    HVLT1Info.startTime = [];
    HVLT1Info.endTime = [];
    fprintf('Warning: HVLT1 is not right. check event name manually! \n')
    
elseif size(tmp,1)==2
    if (event{tmp(1,1)}(1)=='S' && event{tmp(2,1)}(1)=='E') && tmp(2,2)-tmp(1,2)<300
        % if naming seems correct (at least for HVLT1), and the duration is not too long (>300sec)
        HVLT1Info.name = 'HVLT1';
        HVLT1Info.startTime = tmp(1,2);
        HVLT1Info.endTime = tmp(2,2);
    elseif event{tmp(1,1)}(1)=='S' && event{tmp(2,1)}(1)=='S' % only the start of HVLT1 & HVLT-recall have been recorded
        if strcmp(event{find(eventIndex{3},1)},'SST') % if next entry is Start of ST, use that time as the end time
            HVLT1Info.name = 'HVLT1';
            HVLT1Info.startTime = tmp(1,2);
            HVLT1Info.endTime = str2num(eventTime{find(eventIndex{3},1)});
        else
            HVLT1Info.name = 'HVLT1';
            HVLT1Info.startTime = [];
            HVLT1Info.endTime = [];
            fprintf('Warning: HVLT1 is not right. check event name manually! \n')
        end
    else
        % need to do whatever neccessary 
        HVLT1Info.name = 'HVLT1';
        HVLT1Info.startTime = [];
        HVLT1Info.endTime = [];
        fprintf('Warning: HVLT1 is not right. check event name manually! \n')
    end
else
    %%%% do something here when you encounter this 
    
    HVLT1Info.name = 'HVLT1';
    HVLT1Info.startTime = [];
    HVLT1Info.endTime = [];
    fprintf('Warning: HVLT1 is not right. check event name manually! \n')
        
end

clear tmp thisEvent


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function baselineInfo = getBaselineInfo(eventIndex, eventTime, event)

thisEvent = eventIndex{1};
tmp = zeros(length(find(thisEvent)));
tmp(:,1) = find(thisEvent);
for i = 1:size(tmp,1)
    tmp(i,2) = str2num(eventTime{tmp(i,1)});
end

% there must be 2 entries, approx 600 sec apart
if size(tmp,1)<2 % if either only start or end was recorded
   if event{tmp(1,1)}(1)=='S' % only start of the baseline was recorded
       baselineInfo.name = 'Baseline';
       baselineInfo.startTime = tmp(1,2);
       baselineInfo.endTime = tmp(1,2)+600; % 10 min of baseline
   elseif event{tmp(1,1)}(1)=='E' % only start of the baseline was recorded
       baselineInfo.event = 'Baseline';
       baselineInfo.event.startTime = tmp(1,2)-600; % 10 min of baseline
       baselineInfo.event.endTime = tmp(1,2); 
   else
       baselineInfo.name = 'Baseline';
       baselineInfo.startTime = [];
       baselineInfo.endTime = [];
       fprintf('Warning: baseline naming is not right. check event name manually! \n')
   end
   
elseif size(tmp,1)==2 % if both start & end were recorded
    if abs(abs(tmp(2,2)-tmp(1,2))-660) > 60 % if start to end duration was longer than 11min, or shorter than 9min 
        fprintf('Warning: baseline duration is not right. check the duration manually! \n')
        baselineInfo.name = 'Baseline';
        baselineInfo.startTime = [];
        baselineInfo.endTime = [];
    else
        baselineInfo.name = 'Baseline';
        baselineInfo.startTime = tmp(1,2);
        baselineInfo.endTime = tmp(2,2); 
    end
else
    fprintf('Warning: baseline info is either missing or more than 2. check manually! \n')
    baselineInfo.name = 'Baseline';
    baselineInfo.startTime = [];
    baselineInfo.endTime = [];
end

clear tmp thisEvent
