function dataOut = readLay(fileIn)

% this fxn reads in the specified lay file from EEG recording.
% 
% input:
% fileIn: string. name of the lay file to be preprocessed (e.g.
% 'EEG01R1.lay')
% 
% outputs:
% dataOut: struct. info on the recording, such as electrode names and "time
% stamps" of the events
%
% history:
% 04/30/14 ai wrote it

filename = sprintf(fileIn);
fid = fopen(filename);
data = cat(2, repmat('%s ',1,25));
dataOut = textscan(fid, data,'Delimiter',',');
fclose(fid);