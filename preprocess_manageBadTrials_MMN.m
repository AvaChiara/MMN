function [EEG] = preprocess_manageBadTrials_MMN(EEG,opts, outdirectory)
% 
% EEG   - EEGlab data structure
% opts   - options for managing bad trials
% folder - epoched for the first step rejetion. reconstruction for the econd step interpolation 
% outdirectory - directory where file is going to be saved
% 
%_____________________________________________________________________________
% Author: Sridhar Jagannathan (01/01/2017).
%
% Copyright (C) 2017 Sridhar Jagannathan
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

   loadPathMMN
%   if strcmp(folder,'epoched')
%   EEG = pop_loadset('filename', [basename  '_epochs.set'], 'filepath', [filepath '/analysis/' folder]);
%   elseif strcmp(folder,'rejected')
%   EEG = pop_loadset('filename', [basename  '_rej.set'], 'filepath', [filepath '/analysis/' folder]);
%   end

[BadTrlIdx,BadElecIdx] = preprocess_detectBadTrials(EEG,opts);

if opts.reject 
    
    fprintf('<--------Summary------------->\n');
    fprintf('The following epochs have been marked for rejection after manual inspection \n');
    fprintf([num2str(BadTrlIdx) '\n']);

    if ~isempty(BadTrlIdx)
            EEG = pop_select(EEG, 'notrial', BadTrlIdx);
            EEG.rejepoch = BadTrlIdx;
    end
    
elseif opts.recon
    
    nrrejec = sum(BadElecIdx,1);
    rejelecscount = nrrejec(BadTrlIdx);
    [~,idx] = find(rejelecscount==0); %Remove the trials that have no bad electrodes..
    BadTrlIdx(idx)=[];
    EEG.rejepoch = BadTrlIdx;
    EEG.reconepoch = BadElecIdx;
    
    fprintf('\nInterpolating bad channels in a trial by trial manner...\n');
    for m = 1:length(BadTrlIdx)
        %tempEEG.data = EEG.data(:,:,BadTrlIdx(m));
        tempEEG = pop_select(EEG, 'trial', BadTrlIdx(m)); %Select only the rejected trial..
        badelectrodes = find(BadElecIdx(:,BadTrlIdx(m)));
        strtxt = sprintf('%.0f,',badelectrodes');

        fprintf('\n Replacing electrodes %s in trial %d\n', strtxt(1:end-1), BadTrlIdx(m));

        tempEEG = eeg_interp(tempEEG, badelectrodes);
        %now put the data back..
        EEG.data(badelectrodes,:,BadTrlIdx(m)) = tempEEG.data(badelectrodes,:);

    end
    
       
end
    EEG.filepath = outdirectory;
    EEG.filename = [EEG.filename(1:end-4) 'Trials.set'];
    EEG.setname = [EEG.filename(1:end-4) 'Trials'];
    fprintf('Saving set %s%s.\n',EEG.filepath,EEG.filename);
    pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath,'version','7.3');

return