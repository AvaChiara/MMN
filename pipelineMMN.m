% Preprocessing pipeline for Global-Local data

%% Setup directories and get filenames

% Directories
loadPathMMN;

raw_dir = '/rds/project/tb419/rds-tb419-bekinschtein/Chiara/Psychiatry/Sally'; %[filepath filesep 'Raw_data']; %Raw data directory 
imp_dir = [filepath filesep 'Analysis' filesep 'Imported']; %Imported data directory
epo_dir = [filepath filesep 'Analysis' filesep 'Epoched']; %Epoched data directory
bcd_dir = [filepath filesep 'Analysis' filesep 'BadChannelsDetected']; %Bad channels detected directory
rej_dir = [filepath filesep 'Analysis' filesep 'TrialsRejected']; %Interpolated channels and rejected trials directory
ref_dir = [filepath filesep 'Analysis' filesep 'Rereferenced']; %Rereferenced directory
pru_dir = [filepath filesep 'Analysis' filesep 'ICA_corrected']; %data with bad components removes
det_dir = [filepath filesep 'Analysis' filesep 'Detrended'];

% Get .mff directories names and extract basenames
dirList_cntrl = get_directory_names([raw_dir filesep 'CONTROLS_RAW_DATA']);
dirList_ds = get_directory_names([raw_dir filesep 'DS_RAW_DATA' filesep 'Gloloc']);

%To be removed and kept
keep_cntr = 'gloloc';
keep_idx = contains(dirList_cntrl, keep_cntr); %keep
dirList_cntrl = dirList_cntrl(keep_idx);

rm_ds = 'INCOMPLETE';
rm_idx = contains(dirList_ds, rm_ds);
dirList_ds(rm_idx) = []; 

basenames_cntrl = cellfun(@(y) y(1:15), dirList_cntrl, 'UniformOutput', false); %extract basename 1:18 will have to be modified according to how we decide to save the data
basenames_ds = cellfun(@(y) y(1:15), dirList_ds, 'UniformOutput', false);
basenames = [basenames_cntrl; basenames_ds];

% What participants to include
participants = []; %leave this variable empty if you want to process all the files. Vector of numbers of participants in case you want to process only one or a few

if ~isempty(participants)
    basenames = basenames(participants);
end
%% Import

%Controls 
for i = 1:length(dirList_cntrl)
    dataimport_MMN(dirList_cntrl{i}, [raw_dir filesep 'CONTROLS_RAW_DATA'])
end

%DS
for i = 1:length(dirList_ds)
    dataimport_MMN(dirList_ds{i}, [raw_dir filesep 'DS_RAW_DATA' filesep 'Gloloc'])
end

%% Filter and Epoch
% >> help epoch_MMN
% for function usage

for i = 1:length(basenames)
    epoch_MMN(basenames{i}, 'indir', imp_dir, 'outdir', epo_dir, 'timewindow', [-0.6 0.3], 'lpfreq', 20, 'showvalues', true)
end
% NB! Low-pass command has been commented out in epoch_MMN()
%[0.4 1.3] epoch -200 700ms relative to 5th tone
%% Detect bad electrodes (it does not reject them)
%NB: need to check whether rejected channels are actually saved once we get
%a dataset with at least a bad channel

for i = 1:length(basenames)
    detectBadElectrodes_MMN(basenames{i}, 'indir', epo_dir, 'outdir', bcd_dir)
end

%************************************************************%
% Optional ICA decomposition here. Better to run on parallel %
%************************************************************%

%% Optional if more channels need to be interpolated after visual inspection
clear EEG
filename = 'DWNS_gloloc_82__pru'; %File in which extra bad channel
chan = [17]; %number of bad channel. It can be a vector
EEG = pop_loadset([filename '.set']);

if ~isfield(EEG.reject, 'rejchan')
    EEG.reject.rejchan = chan;
elseif isfield(EEG.reject, 'rejchan') && isempty(EEG.reject.rejchan)
    EEG.reject.rejchan = chan;
elseif isfield(EEG.reject, 'rejchan') && ~isempty(EEG.reject.rejchan)
    EEG.reject.rejchan = [EEG.reject.rejchan chan];
end

pop_saveset(EEG, [pru_dir filesep filename '.set'])
%% Robust detrending
%better to run this in parallel on slurm because it takes a long time

for i = 1:length(basenames)
    EEG = pop_loadset([pru_dir filesep basenames{i} '_pru.set']);
    
    %Reintroduce information on rejected channels if lost during ICA
    %correction step
    EEGrej = pop_loadset([basenames{i} '_rej.set']); %load file that has rejected channels info
    EEG.reject.rejchan = EEGrej.reject.rejchan; %reintroduce rejected channels info into ICA corrected file
    clear EEGrej
    
    EEG = robust_locdetrend(EEG,'yes');
    pop_saveset(EEG, 'filepath', det_dir, 'filename', [basenames{i} '_det.set']);
end

%% Interpolate bad channels and remove bad trials
for i = 1:length(basenames)
    interpBadChanAndRejectBadTrials_MMN(basenames{i}, 'indir', det_dir, 'outdir', rej_dir)
end

%% Rereference

for i = 1:length(basenames)
    rereference_MMN(basenames{i},1,1, 'indir', rej_dir, 'outdir', ref_dir)
end

%% Plot Average of all trials at Cz as sanity check

figure;
AVG = [];

for i = 1:length(basenames)
    EEG = pop_loadset('filepath', ref_dir, 'filename', [basenames{i} '_ref.set']);
    AVG(i,:) = mean(EEG.data(93,:,:), 3);
end

GA = mean(AVG,1);
plot(EEG.times,GA)
xline(0, 'color', 'r'); xline(150, 'color', 'r'); xline(300, 'color', 'r'); xline(450, 'color', 'r'); xline(600, 'color', 'r'); 
title('Grand Average at Cz')

%% MVPA