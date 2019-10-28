function dataimport_MMN(mfffiles, indir)

% Import mff files


filepath = [indir filesep];
basename = mfffiles(1:5);

if isempty(mfffiles)
    error('No files found to import!\n');
end

%mfffiles = filenames(logical(cell2mat({filenames.isdir})));
% if length(mfffiles) > 1
%     error('Expected 1 MFF recording file. Found %d.\n',length(mfffiles));
%     
% elseif isempty(mfffiles)
%     % check for and import NSF file
%     if length(filenames) ~= 1
%         error('Expected 1 NSF recording file. Found %d.\n',length(filenames));
%     else
%         filename = filenames.name;
%         fprintf('\nProcessing %s.\n\n', filename);
%         %EEG = pop_readegi(sprintf('%s%s', filepath, filename));
%         EEG = pop_mffimport(sprintf('%s%s', filepath, filename), 'code'); %needs MFFMatlabIO2.01 plugin
%         for e = 1:length(EEG.event)
%             EEG.event(e).codes = {'DUMM',0};
%         end
%         
%     end
%     
%else
    filename = mfffiles;
    fprintf('\nProcessing %s.\n\n', mfffiles);
    EEG = pop_mffimport(sprintf('%s%s', filepath, filename), 'code'); %needs MFFMatlabIO2.01 plugin

%end


% fprintf('Renaming markers.\n');
% countA = 0;
% countT = 0;
% for e = 1:length(EEG.event)
%     evtype = EEG.event(e).type;
%     
%     if countA == 10
%         countA = 0;
%     end
%     
%     if countT == 10
%         countT = 0;
%     end
%     
%     if evtype(1) =='A'
%         %EEG.event(e).type = [EEG.event(e).type(1) num2str(EEG.event(e).code(4))];
%         EEG.event(e).type = [EEG.event(e).type(1) EEG.event(e).mffkey_FREQ];
%         EEG.event(e).type = [EEG.event(e).type '_' num2str(countA)];
%         countA = countA +1;
%     elseif evtype(1) =='T'
%         %EEG.event(e).type = [EEG.event(e).type(1) num2str(EEG.event(e).code(4))];
%         EEG.event(e).type = [EEG.event(e).type(1) EEG.event(e).mffkey_FREQ];
%         EEG.event(e).type = [EEG.event(e).type '_' num2str(countT)];
%         countT = countT +1;
%     elseif evtype(1) =='O'
%         %EEG.event(e).type = [EEG.event(e).type(1) num2str(EEG.event(e).code(4))];
%         EEG.event(e).type = [EEG.event(e).type(1) EEG.event(e).mffkey_FREQ];
%         EEG.event(e).type = [EEG.event(e).type '_' num2str(countT)];
%         countT = countT +1;
%     end
% end % e


EEG.setname = sprintf('%s_orig',basename);
EEG.filename = sprintf('%s_orig.set',basename);
EEG.filepath = filepath;

loadPathMMN;
fprintf('Saving %s%s.\n',[filepath '/Analysis/Imported/'], EEG.filename);
pop_saveset(EEG,'filename', EEG.filename, 'filepath', [filepath '/Analysis/Imported'],'version','7.3');

