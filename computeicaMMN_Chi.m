 function computeicaMMN_Chi(basename,icatype,pcacheck,indir,outdir)
%Coded for submission in through SLURM

loadPathMMN;
    
if ~exist('icatype','var') || isempty(icatype)
    icatype = 'runica';
end

if (strcmp(icatype,'runica') || strcmp(icatype,'binica') || strcmp(icatype,'mybinica')) && ...
    (~exist('pcacheck','var') || isempty(pcacheck))
    pcacheck = true;
end

if ischar(basename)
    EEG = pop_loadset('filename', basename, 'filepath', indir);

else
    EEG = basename;
end

% find and but do not remove bad channels
if  isfield(EEG.reject,'rejchan')
    badchannels = cell2mat({EEG.reject.rejchan});
    %isfield(EEG.chanlocs,'badchan')
    %badchannels = find(cell2mat({EEG.chanlocs.badchan}));
    if ~isempty(badchannels)
        fprintf('\nFound %d bad channels: ', length(badchannels));
        for ch=1:length(badchannels)-1
            fprintf('%s,',EEG.chanlocs(badchannels(ch)).labels);
        end
        fprintf('%s\n',EEG.chanlocs(badchannels(end)).labels);
        % EEG = pop_select(EEG,'nochannel',badchannels); this line will remove the bad channels and it will be 
    else
        badchannels = [];
        fprintf('No bad channel info found.\n');
    end
else
    badchannels = [];
    fprintf('No bad channel info found.\n');
end

if strcmp(icatype,'runica') || strcmp(icatype,'binica') || strcmp(icatype,'mybinica')
    if pcacheck
        kfactor = 60;
        pcadim = round(sqrt(EEG.pnts*EEG.trials/kfactor));
        if EEG.nbchan > pcadim
            fprintf('Too many channels for stable ICA. Data will be reduced to %d dimensions using PCA.\n',pcadim);
            icaopts = {'extended' 1 'pca' pcadim};
        else
            icaopts = {'extended' 1};
        end
    else
        icaopts = {'extended' 1};
    end
else
    icaopts = {};
end

if strcmp(icatype,'mybinica')
    EEG = mybinica(EEG);
else
    AllElectrodes = 1:EEG.nbchan;
    AllElectrodes(badchannels) = [];
    GoodElectrodes = AllElectrodes;
    EEG = pop_runica(EEG, 'icatype',icatype,'dataset',1,'chanind',GoodElectrodes,'options',icaopts);
end

if ischar(basename) && ~isempty(EEG.icaweights)
    EEG.saved = 'no';
    EEG.filename = [basename(1:end-7) 'ica.set'];
    EEG.filepath = outdir;
    fprintf('Saving %s%s\n',EEG.filepath, EEG.filename);
    %pop_saveset(EEG, 'savemode', 'resave');
    pop_saveset(EEG, 'filepath', outdir, 'filename', [basename(1:end-7) 'ica.set']);
end