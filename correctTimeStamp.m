function correctedMasterTime = correctTimeStamp(masterTime)

% this fxn is called if manual correction of time stamp is required during
% preprocessing
%
% history
% 05/29/14 ai wrote it

for i = 1:length(masterTime)
    prompt = {'start time:','end time:'};
    dlg_title = masterTime(i).name;
    num_lines = 1;
    def = {num2str(masterTime(i).startTime),num2str(masterTime(i).endTime)};
    correctTime = inputdlg(prompt,dlg_title,num_lines,def);
    
    correctedMasterTime(i).name = masterTime(i).name;
    correctedMasterTime(i).startTime=str2double(correctTime(1));
    correctedMasterTime(i).endTime=str2double(correctTime(2));
end