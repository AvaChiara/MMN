function dataimport_MMN(mfffiles, indir)

% Import mff files


filepath = [indir filesep];
basename = mfffiles(1:15);

if isempty(mfffiles)
    error('No files found to import!\n');
end

filename = mfffiles;
fprintf('\nProcessing %s.\n\n', mfffiles);
EEG = pop_mffimport(sprintf('%s%s', filepath, filename), 'code'); %needs MFFMatlabIO2.01 plugin


%Add marker at 5th tone (move to 600ms because S1@0ms, S2@150ms,
%S3@300, S4@450, S5@600ms)
fprintf('Adding markers to 5th tone.\n');
events = {'LAX', 'LAY', 'LBX', 'LBY', 'RAX', 'RAY', 'RBX', 'RBY'}; 

EEG.eventOrig = EEG.event;
f = fieldnames(EEG.eventOrig)';
f{2,1} = {};
EEG.event = struct(f{:});

c = 1;
         for q = 1:length(EEG.eventOrig)
             cont = contains(events, EEG.eventOrig(q).type(1:3));
            if istrue(sum(cont))
               EEG.event(c) = EEG.eventOrig(q);
               c = c+1;
               EEG.event(c) = EEG.eventOrig(q);
               EEG.event(c).type = [EEG.event(c).type '_5'];
               EEG.event(c).latency = EEG.eventOrig(q).latency + 600*(EEG.srate/1000); %onset of 5th sound is 600ms after onset of 1st
               c = c+1; 
            else
               EEG.event(c) = EEG.eventOrig(q);
            end
         end
        



EEG.setname = sprintf('%s_orig',basename);
EEG.filename = sprintf('%s_orig.set',basename);
EEG.filepath = filepath;

loadPathMMN;
fprintf('Saving %s%s.\n',[filepath '/Analysis/Imported/'], EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', [filepath '/Analysis/Imported'],'version','7.3');

