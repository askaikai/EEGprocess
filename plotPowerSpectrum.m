function plotPowerSpectrum(topDir, subNum, sessionNum)

% this fxn reads in raw-data and plots power spectrum for Baseline and
% tasks, for each electrode.
%
% inputs:
% topDir: string. study directory (e.g. '/Volumes/Data/AES_EEG_06072012/')
% subNum: double. subject ID (e.g. 1)
% sessionNum: double. unique session ID that's in the file name.
%   pre-exercise is 1, post is 2.
%
% history
% 07/10/14: ai wrote it
% 07/11/14: ai added standardize elec step, session number, and cleaned up

warning off
cd(topDir)

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

sessionID = num2str(sessionNum);

load(['preprocessed/sub' subID '_' sessionID '.mat'],'ft_data','masterTime')
ft_data = standardizeElec(topDir, ft_data);

% find Baseline period and divide data into Baseline and task
time = ft_data.time{1};
for i = 1:length(masterTime)
    if strcmp(masterTime(i).name,'Baseline')
        break
    end
end

baselineIdx = i;
[xxx,baselineBegin] = min(abs(time-masterTime(baselineIdx).startTime));
[xxx,baselineEnd] = min(abs(time-masterTime(baselineIdx).endTime));

% now spectral analysis and plot

for chan = 1:length(ft_data.label)
    
    x = ft_data.trial{1}(chan,:);
    if sessionNum == 1 % pre (Baseline is at the beginning)
        baseline.data = x(1:baselineEnd);
        baseline.time = time(1:baselineEnd);
        task.data = x(baselineEnd+1:end);
        task.time = time(baselineEnd+1:end);
    elseif sessionNum == 2 % post (Baseline is at the end)
        baseline.data = x(baselineBegin:end);
        baseline.time = time(baselineBegin:end);
        task.data = x(1:baselineBegin-1);
        task.time = time(1:baselineBegin-1);
    end
    
    subplot(4,4,chan)
    % Baseline
    [f,p] = calcFFT(baseline.data,ft_data);
    [freq, pow] = sampleFreqAndPower(f,p,ft_data);
    plot(freq,pow,'b'); hold on
    
    % task
    [f,p] = calcFFT(task.data,ft_data);
    [freq, pow] = sampleFreqAndPower(f,p,ft_data);
    plot(freq,pow,'r');
    
    xlim([0 ft_data.fsample/2]); ylim([0 .3])
    set(gca,'XTick',[0 50 100],'YTick',[0 .1 .2]);
    title(ft_data.label(chan))
    if chan == 1
        xlabel('Frequency (Hz)')
        ylabel('Relative Power')
        legend('Baseline','Task','Location','NorthEast')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f,p] = calcFFT(x,ft_data)
m = length(x);
n = pow2(nextpow2(m));
y = fft(x,n);
f = (0:n-1)*(ft_data.fsample/n);
p = y.*conj(y)/n;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f2, p3] = sampleFreqAndPower(f,p,ft_data)
fInterval = 0:1:ft_data.fsample/2;
for j = 1:length(fInterval)
    [xxx,fIdx(j)] = min(abs(fInterval(j) - f));
end
f2 = f(fIdx);
p2 = p(fIdx);
p3 = p2/sum(p2); % convert to relative power


