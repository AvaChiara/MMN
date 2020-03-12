%Load files and rename event codes to run the ADAM toolbox

ChiLocal_loadPathMMN;
data_dir = [filepath filesep 'Analysis' filesep 'Rereferenced'];
filenames = getFilenames_Chi(data_dir, '.set');
cd(data_dir);

%Define here how to rename event codes. This will change according to what
%contrasts we want to run.
O_Loc_Std = {'LAX1' 'LBX1' 'LAY2' 'LBY2' 'RAX1' 'RBX1' 'RAY2' 'RBY2'}; %original Loc standard
O_Loc_Dev = {'LAX2' 'LBX2' 'LAY1' 'LBY1' 'RAX2' 'RBX2' 'RAY1' 'RBY1'}; %original local deviant
O_Aur_Dev = {'LAX3' 'LBX3' 'LAY3' 'LBY3' 'RAX3' 'RBX3' 'RAY3' 'RBY3'}; %original inter-aural deviant

Loc_Std = '1'; %Local Standard
Loc_Dev = '2';  %Local Deviant
Aur_Dev = 3; %Inter Aural Deviant

%Global standards are odd numbers (11 and 21), Global deviants are even
%numbers (12 and 22)
% 11 - Local Std & Global Std
% 21 - Local Dev & Global Std
% 12 - Local Std & Global Dev
% 22 - Local Dev & Global Dev
%
%               Local Std    |    Local Dev
%-------------------------------------------------
% Global Std       11        |      21
%-------------------------------------------------
% Global Dev       12        |      22


for i = 1:length(filenames)
    EEG = pop_loadset(filenames{i});
    EEG.epochOrig = EEG.epoch;
    for j = 1:length(EEG.epoch)
        if ismember(EEG.epoch(j).eventtype(1:4), O_Loc_Std)
           EEG.epoch(j).eventtype = Loc_Std;
           if contains(EEG.epoch(j).eventcode, '1')
              EEG.epoch(j).eventtype =[EEG.epoch(j).eventtype  '1'];
           elseif contains(EEG.epoch(j).eventcode, '2')
               EEG.epoch(j).eventtype = [EEG.epoch(j).eventtype '2'];
           end
              EEG.epoch(j).eventtype = str2double(EEG.epoch(j).eventtype);
              
        elseif ismember(EEG.epoch(j).eventtype(1:4), O_Loc_Dev)
           EEG.epoch(j).eventtype = Loc_Dev;
          if contains(EEG.epoch(j).eventcode, '1')
              EEG.epoch(j).eventtype =[EEG.epoch(j).eventtype  '1'];
           elseif contains(EEG.epoch(j).eventcode, '2')
               EEG.epoch(j).eventtype = [EEG.epoch(j).eventtype '2'];
           end
              EEG.epoch(j).eventtype = str2double(EEG.epoch(j).eventtype);
        elseif ismember(EEG.epoch(j).eventtype(1:4),O_Aur_Dev)
            EEG.epoch(j).eventtype = Aur_Dev;
        end
    end
    
    pop_saveset(EEG, 'filename', filenames{i});
end
