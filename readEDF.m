function [hdr, data] = readEDF(fileIn)

% this fxn reads in the specified EDF file from EEG recording.
% 
% input:
% fileIn: string. name of the EEG file to be preprocessed (e.g.
% 'EEG01R1.edf')
% 
% outputs:
% hdr: struct. info on the recording, such as participant's name, file size
%       and electrode names
% data: double. 2D (nElectrodes x sample) EEG data file
%
% history:
% 04/30/14 ai wrote it

[hdr, data] = edfread(fileIn);