%#######################################################################
%
%                  * Meniscus Erosion KOOS Program *
%
%          M-File which reads the PTOA KOOS subscores data from the CSV 
%     file in the Meniscus\Results\ subdirectory:
%     PTOAStudy_KOOSSubscores_DATA_2025-02-06.csv.
%
%          The subject and visit data for the meniscus T1rho and T2*
%     results are read from the MS-Excel spreadsheet file in the
%     Meniscus\Results\ subdirectory:  mri_mes_fit_stat2.xlsx.
%
%          The KOOS subscores are written back to the MS-Excel
%     spreadsheet:  mri_mes_fit_stat2.xlsx in the Meniscus\Results\
%     subdirectory.
%
%     NOTES:  1.  Assumes Matlab is starting in the Meniscus directory.
%
%             2.  The mri_mes_fit_stat2.xlsx must not be open.
%
%     31-Mar-2025 * Mack Gardner-Morse
%

%#######################################################################
%
% Read KOOS Subscore Data for All PTOA Subjects from KOOS CSV File
%
kooss = readtable(fullfile('Results', ...
                        'PTOAStudy_KOOSSubscores_DATA_2025-02-06.csv'));
%
subj = kooss{:,1};      % Subjects
vis = kooss{:,2};       % Visits
%
Symp_Stif = kooss{:,3}; % KOOS subscores
Pain = kooss{:,4};      % KOOS subscores
ADL = kooss{:,5};       % KOOS subscores
Sprt_Rec = kooss{:,6};  % KOOS subscores
QofL = kooss{:,7};      % KOOS subscores
%
% Read T1rho and T2* Results Spreadsheet
%
xlsnam = 'mri_mes_fit_stat2.xlsx';
xlsnam = fullfile('Results',xlsnam);
res = readtable(xlsnam);
%
s = res{:,1};           % Subjects
v = res{:,9};           % Visits
%
% Expand Subject KOOS Subscores to All Trials
%
ids = s==subj';         % Trial subjects related to KOOS subjects
idv = v==vis';          % Trial visits related to KOOS visits
idx = double(ids&idv);  % Matrix relating subjects and visits
%
Symp_Stif = idx*Symp_Stif;             % Expand subscore to all trials
Pain = idx*Pain;                       % Expand subscore to all trials
ADL = idx*ADL;                         % Expand subscore to all trials
Sprt_Rec = idx*Sprt_Rec;               % Expand subscore to all trials
QofL = idx*QofL;                       % Expand subscore to all trials
%
% Create Table with Expanded KOOS Subscores
%
koos = array2table([Symp_Stif Pain ADL Sprt_Rec QofL], ...
          'VariableNames',{'Symp_Stif','Pain','ADL','Sprt_Rec','QofL'});
%
% Write Table with Expanded KOOS Subscores
%
writetable(koos,xlsnam,'Range','T1');
%
return