%#######################################################################
%
%                    * Year 1 Age and BMI Program *
%
%          M-File which reads the Year 1 PTOA subject age and BMI from
%     the MS-Excel spreadsheet file in the Meniscus\Results\
%     subdirectory: PTOA Baseline - Updated Meniscus Groups.xlsx.
%
%          The meniscus T1rho and T2* results are read from the MS-Excel
%     spreadsheet file in the Meniscus\Results\ subdirectory:
%     mri_mes_fit_stat3.xlsx.
%
%          The meniscus T1rho and T2* results and the updated age and
%      BMI are incorporated into the results.
%
%          The updated data are written back to the MS-Excel
%     spreadsheet:  mri_mes_fit_stat4.xlsx in the Meniscus\Results\
%     subdirectory.
%
%     NOTES:  1.  Assumes Matlab is starting in the Meniscus directory.
%
%     13-May-2025 * Mack Gardner-Morse
%

%#######################################################################
%
% Read Year 1 PTOA Subject Age and BMI from MS-Excel Spreadsheet File
%
data = readtable(fullfile('Results', ...
                 'Meniscus Paper (Year 1 Data RedCap Variables).csv'));
%
subj = data{:,1};       % Subject IDs
subj = strrep(subj,'PTOA','');
subj = str2double(subj);               % Subject ID as a number
nsubj = size(subj,1);   % Number of year 1 subjects
%
vis = ones(nsubj,1);    % Year 1 is visit (vis) = 1
%
% Get Age and BMI
%
age = data{:,4};        % Age in years
bmi = data{:,6};        % BMI in kg/m^2
%
% Read T1rho and T2* Results Spreadsheet
%
xlsnam = 'mri_mes_fit_stat4.xlsx';
xlsnam = fullfile('Results',xlsnam);
res = readtable(xlsnam);
%
s = res{:,1};           % Subjects
v = res{:,9};           % Visits
%
% Expand Age and BMI to All Trials
%
ids = s==subj';         % Trial subjects related to year 1 subjects
idv = v==vis';          % Trial visits related to year 1 visits
idx = double(ids&idv);  % Matrix relating subjects and visits
%
age = idx*age;
bmi = idx*bmi;
%
% Update Results Table
%
idx = any(idx,2);       % Updated trials
%
res.Age(idx) = age(idx);
res.BMI(idx) = bmi(idx);
%
% Write Table to MS-Excel Spreadsheet
%
writetable(res,xlsnam,'WriteMode','inplace');
%
return