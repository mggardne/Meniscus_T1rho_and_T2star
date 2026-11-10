%#######################################################################
%
%              * UPDate Meniscus INJury GRouPs Program *
%
%          M-File which reads the PTOA updated meniscus injury groups
%     in MS-Excel spreadsheet file in the Meniscus\Results\
%     subdirectory: PTOA Baseline - Updated Meniscus Groups.xlsx.
%
%          The meniscus T1rho and T2* results are read from the MS-Excel
%     spreadsheet file in the Meniscus\Results\ subdirectory:
%     mri_mes_fit_stat3.xlsx.
%
%          The meniscus T1rho and T2* results and the updated meniscus
%      injury groups are incorporated into the results.
%
%          The updated data are written back to the MS-Excel
%     spreadsheet:  mri_mes_fit_stat3.xlsx in the Meniscus\Results\
%     subdirectory.
%
%     NOTES:  1.  Assumes Matlab is starting in the Meniscus directory.
%
%     13-May-2025 * Mack Gardner-Morse
%

%#######################################################################
%
% Read Updated Meniscus Injury Groups from MS-Excel Spreadsheet File
%
data = readtable(fullfile('Results',['PTOA Baseline - Updated ', ...
                 'Meniscus Groups.xlsx']));
subjID = data{:,1};
subjID = strrep(subjID,'PTOA','');
subj = str2double(subjID);             % Subject ID as a number
%
% Get Meniscus Injury Groups
%
grp = data{:,2};        % Meniscus groups as characters
grpn = grp;
grpn = strrep(grpn,'C','D');           % Convert 'C' to 'D'
grpn = double(char(grpn));             % Convert to ASCII number
grpn = rem(grpn,10)-5;                 % Meniscus groups as numbers
%
% Read T1rho and T2* Results Spreadsheet
%
xlsnam = 'mri_mes_fit_stat3.xlsx';
xlsnam = fullfile('Results',xlsnam);
res = readtable(xlsnam);
%
s = res{:,1};           % Subjects
%
% Expand Meniscus Injury Groups to All Trials
%
idx = double(s==subj');
grp = cellstr(char(idx*double(char(grp))));
grpn = idx*grpn;
%
% Update Results Table
%
res.MenGrp = grp;
res.MenGrpN = grpn;
%
% Write Table to MS-Excel Spreadsheet
%
writetable(res,xlsnam,'WriteMode','inplace');
%
return