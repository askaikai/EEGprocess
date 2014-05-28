function addChoppedData

task = {'Baseline','DS','HVLT2','SDM','WTAR','COWAT','HVLT1','MOD','ST','TM'};

sub={'01','02','03','04','05'};

topDir=pwd;

for i=1:length(sub)
    cd([topDir '/sub' sub{i}])
    pwd
    
    for j=1:length(task)
        
        thisTaskMat = [task{j} '.mat']
        
        load(thisTaskMat)
        
        cfg=[]; 
        cfg.length=3;
        cfg.overlap=0;
        ft_data_chopped = ft_redefinetrial(cfg, ft_data);
        for i=1:length(ft_data_chopped.time)
            ft_data_chopped.time{i}=ft_data_chopped.time{i}-ft_data_chopped.time{i}(1);
        end
        save(thisTaskMat, 'ft_data_chopped','-append')
        
        clear ft_data ft_data_chopped
        
    end
    cd(topDir)
end
    
