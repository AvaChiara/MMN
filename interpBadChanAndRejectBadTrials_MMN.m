function EEG = interpBadChanAndRejectBadTrials_MMN(basename, varargin)

% Initialize

loadPathMMN;

opt = finputcheck(varargin, {
    'indir' 'string' [] pwd;...
    'outdir' 'string' [] pwd;...
    });

    
if exist('basename','var') && ischar(basename)
       basename = {basename};
end
   
for i = 1:length(basename)
       filename = [basename{i} '_rej.set'];
       EEG = pop_loadset('filename', filename, 'filepath', opt.indir);

% badchannels = find(cell2mat({EEG.chanlocs.badchan}));
    if isfield(EEG.reject, 'rejchan')
       badchannels = EEG.reject.rejchan;
       if ~isempty(badchannels) 
        fprintf('\nInterpolating bad channels %d...\n', badchannels);
        EEG = eeg_interp(EEG, badchannels); 
       end
    else
    end

% delete bad trials
      opts.threshold = 1; opts.slope = 0;
      opts.reject = 1; opts.recon = 0;
      EEG = preprocess_manageBadTrials_MMN(EEG,opts,opt.outdir);
      
end


