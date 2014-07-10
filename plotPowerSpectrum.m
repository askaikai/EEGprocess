function plotPowerSpectrum(topDir, subNum)

cd(topDir)

if subNum < 10
    subID = ['0' num2str(subNum)];
else
    subID = num2str(subNum);
end

load(['preprocessed/sub' subID '_1.mat'],'ft_data','masterTime')

% find Baseline period and divide data into Baseline and task
time = ft_data.time{1};
[xxx,baselineEnd] = min(abs(time-masterTime(1).endTime));
for chan = 1:length(ft_data.label)
    
    x = ft_data.trial{1}(chan,:);
    baseline.data = x(1:baselineEnd);
    baseline.time = time(1:baselineEnd);
    task.data = x(baselineEnd+1:end);
    task.time = time(baselineEnd+1:end);
    
    
    [f,p] = calcFFT(baseline.data,ft_data);
    f2 = f(1:1050:length(f)/2);
    p2 = p(1:1050:length(f)/2);
    p3 = p2/sum(p2);
    
    subplot(4,4,chan)
    plot(f2,p3,'b'); hold on
    
    [f,p] = calcFFT(task.data,ft_data);
    f2 = f(1:1050:length(f)/2);
    p2 = p(1:1050:length(f)/2);
    p3 = p2/sum(p2);
    plot(f2,p3,'r');
    
    xlim([0 125]); ylim([0 .3])
    set(gca,'XTick',[0 50 100],'YTick',[0 .1 .2]);
    title(ft_data.label(chan))
    if chan == 1
        xlabel('Frequency (Hz)')
        ylabel('Relative Power')
        legend('Baseline','Task','Location','NorthEast')
    end
end


function [f,p] = calcFFT(x,ft_data)
m = length(x);
n = pow2(nextpow2(m));
y = fft(x,n);
f = (0:n-1)*(ft_data.fsample/n);
p = y.*conj(y)/n;
