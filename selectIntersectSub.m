function [Task1, Task2] = selectIntersectSub(Task1, Task2)

% in order to run dependent-sample T-test, we have to make sure to analyze
% only those who have data in both trial types.

task1Sub = [];
task2Sub = [];

if isfield(Task1,'TFRdesc')
    for i = 1:length(Task1.TFRdesc)
        task1Sub = [task1Sub; Task1.TFRdesc{i}.cfg.subNum];
    end

    for i = 1:length(Task2.TFRdesc)
        task2Sub = [task2Sub; Task2.TFRdesc{i}.cfg.subNum];
    end
    [eraseMe1,eraseMe2] = findSub2Erase(task1Sub,task2Sub);
    Task1.TFRdesc(eraseMe1)=[];
    Task2.TFRdesc(eraseMe2)=[];
end




function [eraseMe1,eraseMe2] = findSub2Erase(task1Sub,task2Sub)
commonSub = intersect(task1Sub, task2Sub);
eraseMe1 = find(ismember(task1Sub,commonSub)~=1);
eraseMe2 = find(ismember(task2Sub,commonSub)~=1);