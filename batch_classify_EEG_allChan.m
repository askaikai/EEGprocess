function batch_classify_EEG_allChan

%%% make sure these params are correct
condlist = {'item','rel'};
testFreq = [8:0.5:13];
testTime = [-.7:0.1:-.2];
mtmcycle = 5;
%%%

warning off

subID = {'01','02','03','04','05','07','08','09','10','11','12','13','14','16','17','18'};
studyDir = ['/Users/akiko/Experiments/EEGItemRel/Data/'];

for i = 1:length(subID)
    tic
    thisSub = [studyDir 'sub' subID{i}];
    cd(thisSub)
    !mkdir -p classification
    cd classification
    pwd

    cond1 = condlist{1};
    cond2 = condlist{2};

    %addpath(genpath('/Volumes/courtney/Users/Akiko/FilesFromAkikoComputer/MatlabFolder/EEGprocess/'))
    ft_classify_EEG_allChan(cond1, cond2, testFreq, testTime, mtmcycle)
   
    toc
    newDir = ['classification_allChan_' num2str(testTime(1)*1000) 'to' num2str(testTime(end)*1000) 'sec'];
    mkdir(newDir)
    movefile('*.mat',newDir)
end

