function [EEG,indelec] = detect_reject_BadElectrodes_MMN(basename, varargin)
% Detect bad electrodes and removes:
%
% 'indir', val > [string] the directory containing the imported data
% 'outdir', val > [string] with the directory where to save the data

loadPathMMN;

opt = finputcheck(varargin, {
    'indir' 'string' [] pwd;...
    'outdir' 'string' [] pwd;...
    });

% Loading data
if ischar(basename)
    basename = {basename};
end
   
 for i = 1:length(basename)
        filename = [basename{i} '_epoch.set'];
        EEG = pop_loadset('filename', filename, 'filepath', opt.indir);

        chandata = reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials); %Get chan x tpts..
        zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
        disp('Zero activity channels were detected: Loading results');
        fprintf('--> Channel %d \n',zerochan);
        electrodes = setdiff(1:EEG.nbchan,zerochan);
        [EEG, indelec, ~, ~] = priv_rejchan(EEG,'elec',electrodes ,'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 48]);
        EEG.reject.rejchan = indelec;
        allelec = 1:size(EEG.data,1);
        EEG.data(indelec,:,:) = []; %Remove bad channels
        allelec(indelec) = [];
        EEG.reject.goodchan = allelec; %keep list of good channels

        % inter

        EEG.filepath = opt.outdir;
        EEG.filename = [basename{i} '_rej.set'];
        EEG.setname = [basename{i} '_rej'];
        fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
        pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
 end
