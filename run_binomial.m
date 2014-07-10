function stat = run_binomial(task1, alpha)

for i = 1:length(task1{1}.label)
    sigNum = 0;
    for j = 1:length(task1)
        if task1{j}.binomial(i) < alpha;
            sigNum = sigNum + 1;
        end
    end
    if sigNum==0
        out.p(i) = 1;
    else
        out.p(i) = 1 - binocdf(sigNum,length(task1),.5);
    end
end

stat = ft_freqgrandaverage([], task1{:});
stat.elec = task1{1}.elec;
stat.stat = stat.powspctrm;
stat = rmfield(stat,'powspctrm');
stat.mask = out.p < alpha/length(task1{1}.label);
stat.prob = out.p;
stat.dimord = 'chan';

