%
% Subject Data
%
sdat = {'003\BASELINE'
'004\BASELINE'
'005\BASELINE'
'005\YEAR1'
'006\BASELINE'
'006\YEAR1'
'007\BASELINE'
'007\YEAR1'
'008\BASELINE'
'008\YEAR1'
'009\BASELINE'
'010\BASELINE'
'010\YEAR1'
'011\BASELINE'
'012\BASELINE'
'014\BASELINE'
'015\BASELINE'
'016\BASELINE'
'017\BASELINE'
'017\YEAR1'
'018\BASELINE'
'018\YEAR1'
'019\BASELINE'
'020\BASELINE'
'020\YEAR1'
'021\BASELINE'
'021\YEAR1'
'022\BASELINE'
'023\BASELINE'
'024\BASELINE'
'024\YEAR1'
'025\BASELINE'
'025\YEAR1'
'026\BASELINE'
'027\BASELINE'
'028\BASELINE'
'030\BASELINE'
'031\BASELINE'
'031\YEAR1'
'032\BASELINE'
'033\BASELINE'
'033\YEAR1'
'034\BASELINE'
'034\YEAR1'
'035\BASELINE'
'035\YEAR1'
'036\BASELINE'
'037\BASELINE'
'037\YEAR1'
'038\BASELINE'
'038\YEAR1'
'040\BASELINE'
'041\BASELINE'
'042\BASELINE'
'042\YEAR1'
'043\BASELINE'
'045\BASELINE'
'046\BASELINE'
'047\BASELINE'
'048\BASELINE'
'049\BASELINE'
'050\BASELINE'
'051\BASELINE'
'051\YEAR1'
'053\BASELINE'
'053\YEAR1'
'055\BASELINE'
'055\YEAR1'
'056\BASELINE'
'057\BASELINE'
'057\YEAR1'
'058\BASELINE'
'059\BASELINE'
'060\BASELINE'
'060\YEAR1'
'061\BASELINE'
'062\BASELINE'
'062\YEAR1'
'063\BASELINE'
'063\YEAR1'
'064\BASELINE'
'065\BASELINE'
'066\BASELINE'
'067\BASELINE'
'068\BASELINE'
'069\BASELINE'
'070\BASELINE'
'070\YEAR1'
'071\BASELINE'
'072\BASELINE'
'073\BASELINE'
'074\BASELINE'
'075\BASELINE'
'076\BASELINE'
'077\BASELINE'
'077\YEAR1'
'079\BASELINE'
'080\BASELINE'
'080\YEAR1'
'081\BASELINE'
'082\BASELINE'
'082\YEAR1'
'083\BASELINE'
'084\BASELINE'
'085\BASELINE'
'086\BASELINE'
'087\BASELINE'
'088\BASELINE'
'089\BASELINE'
'090\BASELINE'
'091\BASELINE'
'091\YEAR1'
'092\BASELINE'
'092\YEAR1'
'093\BASELINE'
'094\BASELINE'
'095\BASELINE'
'096\BASELINE'
'096\YEAR1'
'097\BASELINE'
'098\BASELINE'
'099\BASELINE' };
%
% Get Subject and Visit Data
%
sdat = split(sdat,'\');
subjs = char(sdat(:,1));
[subjs,ids] = sortrows(subjs);
nsubj = size(subjs,1);
%
visits = sdat(:,2);
visits = visits(ids);
vtxts = ['BL'; 'Y1'; 'Y2'];
%
% Knee Labels
%
legs = {'Left'; 'Right'; 'Both'};
%
% Load T1rho and T2* Results
%
s = load(fullfile('Results','mri_mes_fit.mat'));
t1r = s.t1r_respx;
t2s = s.t2s_respx;
%
% Remove T1rho Results Above 100
%
r100 = cellfun(@(x) x(x>100),t1r,'UniformOutput',false);
ids = size(r100);
ide = ~cellfun('isempty',r100);
%
i100 = cellfun(@(x) x>100,t1r,'UniformOutput',false);
i100 = i100(ide);
%
t1r100 = t1r(ide);
n100 = size(t1r100);
%
for k = 1:n100
   t1r100{k}(i100{k}) = 0;
end
%
t1r(ide) = t1r100;
%
% Remove T2* Results Above 100
%
r100 = cellfun(@(x) x(x>100),t2s,'UniformOutput',false);
ids = size(r100);
ide = ~cellfun('isempty',r100);
%
i100 = cellfun(@(x) x>100,t2s,'UniformOutput',false);
i100 = i100(ide);
%
t2s100 = t2s(ide);
n100 = size(t2s100);
%
for k = 1:n100
   t2s100{k}(i100{k}) = 0;
end
%
t2s(ide) = t2s100;
%
% Find T1rho Results Above 55
%
% r55 = cellfun(@(x) x(x>55),t1r,'UniformOutput',false);
r55 = cellfun(@(x) x(x>60),t1r,'UniformOutput',false);
l55 = ~cellfun('isempty',r55);         % Convert to logical
%
% Find Subjects with T1rho Results Above 55
%
t1r_left_lat = l55(:,1,1,1)|l55(:,1,1,2);
t1r_left_med = l55(:,1,2,1)|l55(:,1,2,2);
%
t1r_right_lat = l55(:,2,1,1)|l55(:,2,1,2);
t1r_right_med = l55(:,2,2,1)|l55(:,2,2,2);
%
t1r_left = t1r_left_lat|t1r_left_med;
t1r_right = t1r_right_lat|t1r_right_med;
%
t1r_subj = t1r_left|t1r_right;
%
sum(t1r_subj)
sum(~t1r_subj)
t1r_leg = t1r_left+2*t1r_right;
t1r_both = t1r_leg==3;
sum(t1r_both)
%
t1rt = array2table([sdat(t1r_subj,:) legs(t1r_leg(t1r_subj))], ...
                   'VariableName',{'Subject','Visit','Leg'});
% writetable(t1rt,'AboveCutOff.xlsx','Sheet','T1rho');
writetable(t1rt,'AboveCutOff60.xlsx','Sheet','T1rho');
%
% Find T2* Results Above 50
%
r50 = cellfun(@(x) x(x>50),t2s,'UniformOutput',false);
l50 = ~cellfun('isempty',r50);         % Convert to logical
%
% Find Subjects with T1rho Results Above 55
%
t2s_left_lat = l50(:,1,1,1)|l50(:,1,1,2);
t2s_left_med = l50(:,1,2,1)|l50(:,1,2,2);
%
t2s_right_lat = l50(:,2,1,1)|l50(:,2,1,2);
t2s_right_med = l50(:,2,2,1)|l50(:,2,2,2);
%
t2s_left = t2s_left_lat|t2s_left_med;
t2s_right = t2s_right_lat|t2s_right_med;
%
t2s_subj = t2s_left|t2s_right;
%
% t2s_subj = l50(:,1,1,1)|l50(:,1,1,2)|l50(:,1,2,1)|l50(:,1,2,2)| ...
%            l50(:,2,1,1)|l50(:,2,1,2)|l50(:,2,2,1)|l50(:,2,2,2);
sum(t2s_subj)
sum(~t2s_subj)
t2s_leg = t2s_left+2*t2s_right;
t2s_both = t2s_leg==3;
sum(t2s_both)
%
t2st = array2table([sdat(t2s_subj,:) legs(t2s_leg(t2s_subj))], ...
                   'VariableName',{'Subject','Visit','Leg'});
% writetable(t2st,'AboveCutOff.xlsx','Sheet','T2star');
writetable(t2st,'AboveCutOff60.xlsx','Sheet','T2star');


