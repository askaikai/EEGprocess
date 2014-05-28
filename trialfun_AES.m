function [trl, event] = trialfun_AES(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% % search for "trigger" events
% value  = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).value]';
% sample = [event(find(strcmp(cfg.trialdef.trigchannel, {event.type}))).sample]';

% search for trigger events
for i = 1:length(event)
    yn = event(i).value == str2double(cfg.trialdef.trigchannel);
    match(i) = yn(1);
end
sample = [event(find(match)).sample];


% determine the number of samples before and after the trigger
pretrig  = -cfg.trialdef.prestim  * hdr.Fs;
posttrig =  cfg.trialdef.poststim * hdr.Fs;

trl = [];

for j = 1:length(sample);
    trlbegin = sample(j) + pretrig;
    trlend   = sample(j) + posttrig;
    offset   = pretrig;
    newtrl   = [trlbegin trlend offset];
    trl      = [trl; newtrl];  
end

