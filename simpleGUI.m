%function selectedElec = simpleGUI(ft_data)
function selectionOn = simpleGUI

warning off

% hFig = figure('Visible','off', 'Menu','none', 'Name','Select Electrodes to View', 'Resize','off', 'Position',[100 100 400 200]);
% movegui(hFig,'center')          %# Move the GUI to the center of the screen
% 
% hBtnGrp = uibuttongroup('Position',[0 0 1 1], 'Units','Normalized');
% 
% loc =   [[10 150]; [10 120]; [10 90]; [10 60];
%     [110 150]; [110 120]; [110 90]; [110 60];
%     [210 150]; [210 120]; [210 90]; [210 60];
%     [310 150]; [310 120]; [310 90]; [310 60]];
%     
% for i = 1:length(ft_data.label)
%     h_checkbox(i) = uicontrol('Style','checkbox', 'Parent',hBtnGrp, 'HandleVisibility','off', ...
%         'Position',[loc(i,1), loc(i,2), 70 30],'value',1,...
%         'String',[num2str(i) ': ' ft_data.label{i}]);
% end
%   
%    uicontrol('Style','pushbutton', 'String', 'Select', 'Position',[160 30 60 25], 'Callback',{@pushbutton1_Callback, h_checkbox});
%    set(hFig, 'Visible','on')        %# Make the GUI visible
%    uiwait
%    
%    global choice
%    selectedElec = choice;
% 
% 
% function pushbutton1_Callback(hObject,eventdata,h_checkbox)
% 
% global choice
% choice = get(h_checkbox, 'Value');
% 
% close(gcf);

hFig = figure('Visible','off', 'Menu','none', 'Name','Continue Viewing?', 'Resize','off', 'Position',[100 100 400 200]);
movegui(hFig,'center')          %# Move the GUI to the center of the screen

hBtnGrp = uibuttongroup('Position',[0 0 1 1], 'Units','Normalized');

handles.radio(1) = uicontrol('Style', 'radiobutton',... 
                           'Parent', hBtnGrp,...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [60, 90, 70, 30], ...
                           'String',   'Yes', ...
                           'Value',    1);
handles.radio(2) = uicontrol('Style', 'radiobutton', ...
                           'Parent',hBtnGrp,...
                           'Callback', @myRadio, ...
                           'Units',    'pixels', ...
                           'Position', [210, 90, 70, 30], ...
                           'String',   'No', ...
                           'Value',    0);
                       
uicontrol('Style','pushbutton', 'String', 'Select', ...
    'Position',[160 30 60 25], ...
    'Callback',{@pushbutton2_Callback, handles});

set(hFig, 'Visible','on')        %# Make the GUI visible
uiwait

global repeat
selectionOn = repeat;

function pushbutton2_Callback(hObject,eventdata,handles)

decision = get(handles.radio,'Value');
global repeat
if decision{1} == 1
    repeat = 1;
else
    repeat = 0;
end

close(gcf);
