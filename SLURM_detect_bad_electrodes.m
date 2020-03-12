function SLURM_detect_bad_electrodes(s, in_dir, out_dir)

loadPathMMN;

EEG = pop_loadset([in_dir s]);
chandata = reshape(EEG.data,EEG.nbchan,EEG.pnts*EEG.trials); %Get chan x tpts..
zerochan = find(var(chandata,0,2) < 0.5); %Remove zero channels from spec..
disp('Zero activity channels were detected: Loading results');
fprintf('--> Channel %d \n',zerochan);
electrodes = setdiff(1:EEG.nbchan,zerochan);
[EEG, indelec, ~, ~] = priv_rejchan(EEG,'elec',electrodes ,'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 48]);
EEG.reject.rejchan = indelec;

% inter

EEG.filepath = out_dir;
EEG.filename = [s(1:end-10) '_rej.set'];
EEG.setname = [s(1:end-10) '_rej'];
fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
end