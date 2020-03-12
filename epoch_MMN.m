function EEG = epoch_MMN(basename, varargin)
% This function filters and epochs the data the arguments are as follows:
%
% basename > [string] with the basename of the file to load;
% eventlist > [cell array of strings] corresponding to event markers used
% for epoching the recording
% 'indir', val > [string] the directory containing the imported data
% 'outdir', val > [string] with the directory where to save the epoched
% data
% 'lpfreq', val > [real] low-pass filter cut-off frequency
% 'hpfreq', val > [real] high-pass filter cut-off frequency
% 'timewindow', val > [integers] min max in seconds of the epoch time window relative
% to the event marker
% 'showvalues', val > [boolean] if set to true it prints the values, including
% defaults values in the command window
%% Initialize and load
loadPathMMN;

opt = finputcheck(varargin, {
    'indir' 'string' [] pwd;...
    'outdir' 'string' [] pwd;...
    'lpfreq' 'real' [] 30;...
    'hpfreq' 'real' [] [];...
    'timewindow' 'real' [] [];...
    'showvalues' 'boolean' [] false;...
    });


if isempty(opt.timewindow)
    error('Timewindow not defined. Type "help epoch_P50" in the command window for function usage')
end

if istrue(opt.showvalues)
   disp(['indir: ' opt.indir]);
   disp(['outdir: ' opt.outdir]);
   fprintf('Low-pass: %dHz \nHigh-pass: %0.2fHz \n', opt.lpfreq, opt.hpfreq);
   fprintf('Timewindow from %0.3f sec to %0.3f sec \n', opt.timewindow(1), opt.timewindow(2));
end
      

%% loading the data

if ischar(basename)
   basename = {basename};
end

for i = 1:length(basename)
       base = basename{i}; 
       EEG = pop_loadset('filename', [base '_orig.set'], 'filepath', opt.indir);
   
        fprintf('remove external electrodes');
        chanexcl = [1,8,14,17,21,25,32,38,43,44,48,49,56,63,64,68,69,73,74,81,82,88,89,94,95,99,107,113,114,119,120,121,125,126,127,128];
        EEG = pop_select(EEG,'nochannel',chanexcl);
        EEG = eeg_checkset( EEG );

        % remove line noise
        freq = 50;
        fprintf('Notch filtering of %dH... \n',freq);
        EEG = rmlinenoisemt(EEG,freq);
        EEG = eeg_checkset( EEG );


        % lpfilter
        %lpfreq = 30;
        fprintf('Low-pass filtering above %dHz...\n',opt.lpfreq);
        EEG = pop_eegfiltnew(EEG, [], opt.lpfreq, [], 0, [], 0);

        % hpfilter
        %hpfreq = 0.5;
        if ~isempty(opt.hpfreq)
         fprintf('High-pass filtering below %dHz...\n',opt.hpfreq);
         EEG = pop_eegfiltnew(EEG, [], opt.hpfreq, [], true, [], 0);
        else 
            disp('No high-pass filter')
        end
        

        allevents = {EEG.event.type};
        selectevents = [];
        
        eventlist = unique(allevents);
        ev_idx = ~contains(eventlist, '_5'); %identify markers that we are NOT interested in (everything but 5th tone)
        eventlist(ev_idx) = []; %Remove them
        
        
%         rm = {'BEND', 'BGIN', 'boundary'}; %events we are not interested in
%         wrapper = @(x) strfind(eventlist,x);
%         whereStr = cellfun(wrapper, rm, 'UniformOutput', false);
%         
%         for q = 1:length(whereStr)
%             nomarkers{q} = find(~cellfun(@isempty,whereStr{q}));
%         end
%         
%         nomarkers = cell2mat(nomarkers);
%         eventlist(nomarkers) = []; %remove non interesting event markers
        
        for e = 1:length(eventlist)
            selectevents = [selectevents find(strncmp(eventlist{e},allevents,length(eventlist{e})))];
        end

        %epoch 'baseline' for cluster perm only
%         if cluster == 1
%            EEGbase = pop_epoch(EEG,{},[-0.22 -0.02],'eventindices',selectevents); 
%            EEGbase = eeg_checkset(EEGbase);
%            fprintf('removing BASELINE basline.\n');
%            EEGbase = pop_rmbase( EEGbase, [-220    -120]);
%            EEGbase.setname = base;
%            EEGbase.filepath = [filepath filesep 'Analysis' filesep 'epoched' filesep 'for_cluster'];
%            EEGbase.setname = base;
%            EEGbase.filename = [base '_baseline_epochs.set'];
%            pop_saveset(EEGbase,'filename', EEGbase.filename, 'filepath', EEGbase.filepath,'version','7.3');
%         end

        EEG = pop_epoch(EEG,{},opt.timewindow,'eventindices',selectevents);
        EEG = eeg_checkset(EEG);

    

        fprintf('removing basline.\n');
        EEG = pop_rmbase( EEG, [-200 0]); %baseline relative to -200 before last sound


        if ischar(base)
            EEG.setname = [base '_epoch'];
            EEG.filepath = opt.outdir;
            EEG.filename = [base '_epoch.set'];

            fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
            pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
        end
end