function artifactRemoveStep(cfg)









%%% visualize artifact components. Identify components that represents
%%% blink

cfg = [];
cfg.channel = datacomp.label(comp2View); % components to be plotted
cfg.layout = datacomp.elec;
cfg.viewmode = 'vertical';
artifact_eye = ft_databrowser(cfg, datacomp);
