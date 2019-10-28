% Preprocessing pipeline for Global-Local data

%% Setup directories and get filenames

% Directories
loadPathMMN;

raw_dir = [filepath filesep 'Raw_data']; %Raw data directory 
imp_dir = [filepath filesep 'Analysis' filesep 'Imported']; %Imported data directory
epo_dir = [filepath filesep 'Analysis' filesep 'Epoched']; %Epoched data directory
rej_dir = [filepath filesep 'Analysis' filesep 'Rejected']; %Rejected channels and trials directory
int_dir = [filepath filesep 'Analysis' filesep 'Interpolated']; %Interpolated channels and rejected trials directory
ref_dir = [filepath filesep 'Analysis' filesep 'Rereferenced']; %Rereferenced directory

% Get .mff directories names and extract basenames
dirList = get_directory_names(raw_dir);
basenames = cellfun(@(y) y(1:5), dirList, 'UniformOutput', false); %extract basename 1:18 will have to be modified according to how we decide to save the data

% What participants to include
participants = []; %leave this variable empty if you want to process all the files. Vector of numbers of participants in case you want to process only one or a few

if ~isempty(participants)
    basenames = basenames(participants);
end
%% Import

for i = 1:length(dirList)
    dataimport_MMN(dirList{i}, raw_dir)
end

%% Filter and Epoch
% >> help epoch_MMN
% for function usage

for i = 1:length(basenames)
    epoch_MMN(basenames{i}, 'indir', imp_dir, 'outdir', epo_dir, 'timewindow', [-0.1 0.7], 'showvalues', true)
end

%% Detect bad electrodes, interpolate and reject bad trials
%NB: need to check whether rejected channels are actually saved once we get
%a dataset with at least a bad channel

for i = 1:length(basenames)
    detectBadElectrodes_MMN(basenames{i}, 'indir', epo_dir, 'outdir', rej_dir)
    interpBadChanAndRejectBadTrials_MMN(basenames{i}, 'indir', rej_dir, 'outdir', int_dir)
end

%% Rereference

for i = 1:length(basenames)
    rereference_MMN(basenames{i},1,1, 'indir', int_dir, 'outdir', ref_dir)
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
title('Grand Average at Cz')