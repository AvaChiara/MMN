%% semiautomatic inspection of noisy channels

% requires function priv_rejchan

% overwrites the same file name

% this stage could be fully automatized but I recommend to go through all data
% manually to get a better grasp of its quality

clear all
close all

cd('Z:\BabyLINC Data Backup\Matlab shared\Valdas\PL\eeglab_files')

PNo=124;

% baby

% 1. browse through the filtered file and forse excessively noisy periods
% of time between trials to 0
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',['EEG_PL_' num2str(PNo) '_B_filt.set'],'filepath','Z:\\BabyLINC Data Backup\\Matlab shared\\Valdas\\PL\\eeglab_files\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 1);
% mark bad times in sec
bad_times=[46 59; 78 81; 87 100; 118 121; 148 149.5; 264 269.5; 306 314; 345 362; 388 391; 462 493; 600 603; 619 629]; % 124_B
bad_times=bad_times*1000; % change to msec
bad_times=bad_times/(1000/EEG.srate); % change to time samples
bad_times_n=size(bad_times,1);
for b=1:bad_times_n
   EEG.data(:,bad_times(b,1):bad_times(b,2))=0; 
end
EEG = eeg_checkset( EEG );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',['EEG_PL_' num2str(PNo) '_B_filt.set'],'gui','off'); 

% 2. visually check spectopo   
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',['EEG_PL_' num2str(PNo) '_B_filt.set'],'filepath','Z:\\BabyLINC Data Backup\\Matlab shared\\Valdas\\PL\\eeglab_files\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
figure; pop_spectopo(EEG, 1, [0  1000/EEG.srate*(EEG.pnts-1)], 'EEG' , 'freq', [6 10 22], 'freqrange',[1 48],'electrodes','off');
eeglab redraw

% 3. automatic detection of bad channels
S =[];
S.eeg_filename = ['EEG_PL_' num2str(PNo) '_B_filt'];
S.eeg_filepath ='Z:\BabyLINC Data Backup\Matlab shared\Valdas\PL\eeglab_files';
EEG = pop_loadset('filename', [S.eeg_filename '.set'], 'filepath', S.eeg_filepath);
chandata = reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials); %Get chan x tpts..
zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
disp('Zero activity channels were detected: Loading results');
fprintf('--> Channel %d \n',zerochan);
electrodes = setdiff(1:EEG.nbchan,zerochan);
[~, indelec, ~, ~] = priv_rejchan(EEG,'elec',electrodes ,'threshold',[-2 2],'norm','on',...
                                               'measure','spec' ,'freqrange',[1 48]);


%% interpolate bad channels

clear all
close all

PNo=124;
age='M';
% age='B';
bad_channels=[11 17 29];

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',['EEG_PL_' num2str(PNo) '_' age '_filt_ICA_pruned.set'],'filepath','Z:\\BabyLINC Data Backup\\Matlab shared\\Valdas\\PL\\eeglab_files\\');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

if sum(bad_channels) > 0.5
    EEG = eeg_interp(EEG, bad_channels);
end

% [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',['EEG_PL_' num2str(PNo) '_' age '_filt_ICA_pruned_interp.set'],'filepath','Z:\\BabyLINC Data Backup\\Matlab shared\\Valdas\\PL\\eeglab_files\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);