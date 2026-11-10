%#######################################################################
%
%              * Meniscus Erosion DEMOgraphics 2 Program *
%
%          M-File which reads the PTOA demographics data from two CSV 
%     file in the Meniscus\Results\ subdirectory:
% PTOA Study Meniscus Analysis Year 1 - Baseline (RedCap Variable)).csv
%     and PTOA Meniscus Group Subject Ages.csv.
%
%          The meniscus T1rho and T2* results are read from the MS-Excel
%     spreadsheet file in the Meniscus\Results\ subdirectory:
%     mri_mes_fit.xlsx.
%
%          The meniscus T1rho and T2* results, the demographics, and
%     days between injury and MRI are incorporated into the results.
%
%          The expanded results are written to the MS-Excel
%     spreadsheets:  mri_mes_fit_stat.xlsx in the Meniscus\Results\
%     subdirectory.
%
%     NOTES:  1.  Assumes Matlab is starting in the Meniscus directory.
%
%     29-Jan-2025 * Mack Gardner-Morse
%

%#######################################################################
%
% Read Demographics Data for All PTOA Subjects from Demographics CSV
% File
%
data = readtable(fullfile('Results',['PTOA Study Meniscus ', ...
                 'Analysis Year 1 - Baseline (RedCap Variable)).csv']));
subjID = data.ptoa_subj;
subjID = strrep(subjID,'PTOA','');
subjID = strrep(subjID,'-1','');
subjn = str2double(subjID);            % Subject ID as a number
%
% Get Time from Injury
%
injdat = data{:,2};
bldat = data{:,3};
y1dat = data{:,4};
inj2bl = days(bldat-injdat);           % Time to baseline in days
inj2y1 = days(y1dat-injdat);           % Time to year 1 in days
inj2y1(isnan(inj2y1)) = 0;             % Set missing year 1 data to zero
%
% Get PTOA Subject Demographics
%
bmi = data{:,7};        % BMI in kg/m^2
sex = 2-data{:,8};      % Sex with female = 0 and male = 1
inj = 2-data{:,9};      % ACL injured knee with left = 0 and right = 1
%
% Get Meniscus Groups
%
grp = data{:,10};       % Meniscus groups as characters
grpn = grp;
grpn = strrep(grpn,'C','D');           % Convert 'C' to 'D'
grpn = double(char(grpn));             % Convert to ASCII number
grpn = rem(grpn,10)-5;                 % Meniscus groups as numbers
%
% Read Age Data for All PTOA Subjects from Age CSV File
%
age = readtable(fullfile('Results', ...
                'PTOA Meniscus Group Subject Ages.csv'));
ageID = age.ptoa_subj;
ageID = strrep(ageID,'PTOA','');
ageID = strrep(ageID,'-1','');
age = age{:,2};         % Age in years
%
% Get Results Spreadsheets
%
% xlsnam = 'mri_mes_fit.xlsx';
xlsnam = 'mri_mes_fit_6.xlsx';
xlsnam = fullfile('Results',xlsnam);
%
% Read Results Spreadsheet
%
res = readtable(xlsnam);
%
% Get Just the Variables for Statistical Analysis
%
res = res(:,[1:6 10:15]);
%
% Get Variable Names (Column Headers)
%
hdrs = res.Properties.VariableDescriptions;
hdrs = [hdrs(1) {'Sex' 'Age' 'BMI' 'InjLeg' 'MenGrp' 'MenGrpN', ...
        'Days2MRI'} hdrs(2:end)];
%
% Expand Subject Demographics to All Trials
%
subjs = res{:,1};
%
idx = double(subjs==subjn');
sex = idx*sex;
age = idx*age;
bmi = idx*bmi;
inj = idx*inj;
grp = cellstr(char(idx*double(char(grp))));
grpn = idx*grpn;
days2mri = idx*inj2bl;
inj2y1 = idx*inj2y1;
idv2 = res.Visit==1;
days2mri(idv2) = inj2y1(idv2);
%
% Expand Table with Demographics
%
res = addvars(res,sex,age,bmi,inj,grp,grpn,days2mri,'After','Subject');
res.Properties.VariableNames = hdrs;
%
% Write Table to MS-Excel Spreadsheet
%
idot = strfind(xlsnam,'.');
idot = idot(end);
xlsnamo = [xlsnam(1:idot-1) '_stat' xlsnam(idot:end)];
writetable(res,xlsnamo,'WriteMode','replacefile');
%
return