function epoch_MMN_SLURM(base, indir, outdir)
% This function filters and epochs the data
%% Initialize and load
loadPathMMN;

opt.lpfreq = 20;
opt.hpfreq = [];
opt.timewindow = [-0.2 0.7];
opt.showvalues = false;
opt.indir = indir;
opt.outdir = outdir;

      

%% loading the data

      EEG = pop_loadset('filename', base, 'filepath', indir);
   
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
        EEG = pop_eegfiltnew(EEG, [], opt.lpfreq, 66, 0, [], 0);

%         % hpfilter
%         %hpfreq = 0.5;
%         fprintf('High-pass filtering below %dHz...\n',opt.hpfreq);
%         EEG = pop_eegfiltnew(EEG, [], opt.hpfreq, 3300, true, [], 0);
        

        allevents = {EEG.event.type};
        selectevents = [];
        
        eventlist = unique(allevents);
        ev_idx = ~contains(eventlist, '_5'); %identify markers that we are NOT interested in (everything but 5th tone)
        eventlist(ev_idx) = []; %Remove them
        
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

    

        fprintf('removing baseline.\n');
        EEG = pop_rmbase( EEG, [-200 0]); %Baseline correct relative to last tone


        if ischar(base)
            EEG.setname = [base(1:end-9) '_epoch'];
            EEG.filepath = opt.outdir;
            EEG.filename = [base(1:end-9) '_epoch.set'];

            fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
            pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
        end
