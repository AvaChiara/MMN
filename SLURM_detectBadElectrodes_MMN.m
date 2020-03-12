function SLURM_detectBadElectrodes_MMN(basename, indir, outdir)
% Detect bad electrodes but do not remove them:
%
% 'indir', val > [string] the directory containing the imported data
% 'outdir', val > [string] with the directory where to save the data

loadPathMMN;


% Loading data

filename = basename;
EEG = pop_loadset('filename', filename, 'filepath', indir);

chandata = reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials); %Get chan x tpts..
zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
disp('Zero activity channels were detected: Loading results');
fprintf('--> Channel %d \n',zerochan);
electrodes = setdiff(1:EEG.nbchan,zerochan);
[EEG, indelec, ~, ~] = priv_rejchan(EEG,'elec',electrodes ,'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 48]);
EEG.reject.rejchan = indelec;

% inter

EEG.filepath = outdir;
EEG.filename = [basename(1:end-10) '_rej.set'];
EEG.setname = [basename(1:end-10) '_rej'];
fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
 
