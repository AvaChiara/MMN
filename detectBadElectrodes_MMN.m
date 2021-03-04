function [EEG,indelec] = detectBadElectrodes_MMN(basename, varargin)
% Detect bad electrodes but do not remove them:
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
        
        % CHI *********************************
        if zerochan > 1
           not_Ref = find(zerochan ~= 93);
           dead_elec = zerochan(not_Ref);
           
           %Make sure that they are excluded from computation by setting
           %data values to actual 0
           EEG2 = EEG;
           dummy = zeros(numel(dead_elec),size(EEG2.data,2), size(EEG2.data,3));
           EEG2.data(dead_elec,:,:) = dummy;
           
        else
           EEG2 = EEG;
           dead_elec = [];
        end
        %CHI***********
        
        electrodes = setdiff(1:EEG.nbchan,zerochan);
        [EEG, indelec, ~, ~] = priv_rejchan(EEG2,'elec',electrodes , 'threshold',[-3.5 3.5],'norm','on','measure','spec' ,'freqrange',[1 48]);
        EEG.reject.rejchan = [indelec dead_elec]; %CHI

        % inter

        EEG.filepath = opt.outdir;
        EEG.filename = [basename{i} '_rej.set'];
        EEG.setname = [basename{i} '_rej'];
        fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
        pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');
 end
