%#######################################################################
%
%           * MRI Meniscus Erode Square FIT Year 2 Program *
%
%          M-File which reads the registered MRI data and segmentation 
%     MAT files and fits a monoexponential to the MRI data as a function
%     of spin lock or echo times.  T1rho or T2* are the time constants
%     of the fits.  The masks are eroded by one pixel on the boundary
%     using square structural elements.  These masks are used to get
%     T1rho and T2* over the smaller areas.  Resulting T1rho and T2*
%     values and summary statistics are written to the MS-Excel
%     spreadsheet, mri_mes_fit_y2.xlsx, in the
%     "Results\Meniscus\mri_mes_fit_y2" directory.
%
%     NOTES:  1.  The longest spin lock time for T1rho is not used in
%             the exponential fits.
%
%             2.  Data MAT files must be in subject directories 
%             "..\PTOA\0*" where "*" is the subject number.
%
%             3.  T1rho MAT files must start with "T1rho_S" and T2* MAT
%             files must start with "T2star_S".  Segmentation MAT file
%             names must contain "mroi".  See rd_m_dicom.m and
%             seg_ama_rois.m.
%
%             4.  M-file exp_fun1.m, cmprt_ana4m.m and cmprt_plt4m.m
%             must be in the current directory or path.
%
%     22-Jul-2022 * Mack Gardner-Morse
%

%#######################################################################
%
% Setup Color Map
%
gmap = gray(128);       % Gray color map for not cartilage
jmap = jet(128);        % Jet color map for cartilage
cmap = [gmap; jmap];
%
% Bounding Box for Plot Zoom Window
%
% boxr = [150 345 185 320];    % T1rho bounding box - not used - see bbox
% boxs = [90 250 150 250];     % T2* bounding box - not used - see bbox
%
% Set Curvefit Optimization Parameters
%
opt = optimset('Display','off','TolFun',1e-8,'TolX',1e-8,'MaxIter', ...
               2e+3,'Algorithm','levenberg-marquardt','Jacobian', ...
               'on','UseParallel',true);
%
fun = @exp_fun1;        % Exponential function
%
% Get Different Structured Elements for Eroding the Masks by One Pixel
% (Increase 3 to 5 to erode by two (2) pixels.)
%
sec = strel(logical([0 1 0; 1 1 1; 0 1 0]));     % Crossed lines
ses = strel('square',3);                         % Square
%
ana_typ = ['no'; 'ec'; 'es'];          % Analysis identifiers
%
% Initialize Parameters
%
% init = -1;              % Use weighted least squares for starting parameters
% init = 0;               % Use linear least squares for starting parameters
init = 1;               % Use fixed starting parameters
tr0 = 20;               % 21.45 ms - mean w/ 50 ms threshold
% tr0 = 65;               % Initial T1rho estimate in ms
% tr0 = 80;               % Initial T1rho estimate in ms
trmx = 100;             % Maximum valid T1rho result
trmn = 0;               % Minimum valid T1rho result
ts0 = 12;               % 12.38 ms - mean w/ 50 ms threshold
% ts0 = 35;               % Initial T2* estimate in ms
tsmx = 100;             % Maximum valid T2* result
tsmn = 0;               % Minimum valid T2* result
%
mxtr = 60;              % Maximum scale on T1rho plots
mxts = 55;              % Maximum scale on T2* plots
%
% Output Directory, Output Files and Output Labels
%
% resdir = fullfile('Results\Meniscus\mri_mes_fit_y2');      % Results directory
resdir = fullfile('Results\Meniscus\mri_mes_fit_y2_03Nov2026'); % Results directory
xlsnam1 = 'mri_mes_fit_y2';            % Results spreadsheet
xlsnam1 = fullfile(resdir,xlsnam1);    % Include output directory
xlstyp = '.xlsx';       % Spreadsheet file extension
xlsnam = [xlsnam1 xlstyp];             % Add spreadsheet file extension
hdrs1 = {'Subject' 'Visit' 'Result' 'Leg' 'Comprt' 'AP'};
hdrs2 = {'Pixels' 'T1R/T2S' 'RSS' 'ValidPix' 'Mean' 'Min' 'Max' ...
         'SD' 'COV'};
%
psnam = fullfile(resdir,'mri_mes_fit_y2_');      % Start of PS file name
pstyp = '.ps';          % PS file type
%
% Get PTOA Directory
%
spath = fullfile('..','PTOA');         % Path to series MAT files
%
% Subject Data
%
sdat = { '005\YEAR2\'
         '006\YEAR2\'
         '007\YEAR2\'
         '008\YEAR2\'
         '010\YEAR2\'   % Right leg T1ρ/T2* scan had a quality/bloom issue in medial compartment but was used
         '011\YEAR2\'
         '014\YEAR2\'
         '015\YEAR2\'
         '016\YEAR2\'
         '017\YEAR2\'
         '019\YEAR2\'
         '020\YEAR2\'
         '021\YEAR2\'
         '023\YEAR2\'
         '024\YEAR2\'
         '027\YEAR2\'
         '028\YEAR2\'
         '031\YEAR2\'
         '033\YEAR2\'   % T1ρ right leg scan had a quality/bloom issue and is unusable
         '034\YEAR2\'
         '035\YEAR2\'
         '036\YEAR2\'
         '037\YEAR2\'   % T2* right leg has excessive motion artifact and is unusable
         '038\YEAR2\'
         '040\YEAR2\'
         '042\YEAR2\'
         '043\YEAR2\'
         '045\YEAR2\'
         '046\YEAR2\'
         '047\YEAR2\'
         '048\YEAR2\'
         '049\YEAR2\'
         '050\YEAR2\'
         '051\YEAR2\'
         '057\YEAR2\'
         '060\YEAR2\'
         '061\YEAR2\'
         '063\YEAR2\'
         '064\YEAR2\'
         '068\YEAR2\'
         '069\YEAR2\'
         '070\YEAR2\'
         '071\YEAR2\'
         '072\YEAR2\'
         '074\YEAR2\'
         '075\YEAR2\'
         '076\YEAR2\'   % T1ρ right leg scan is missing
         '077\YEAR2\'
         '079\YEAR2\'
         '080\YEAR2\'
         '081\YEAR2\'
         '082\YEAR2\'
         '083\YEAR2\'
         '084\YEAR2\'
         '085\YEAR2\'
         '086\YEAR2\'
         '087\YEAR2\'
         '088\YEAR2\'
         '091\YEAR2\'
         '092\YEAR2\'
         '093\YEAR2\'
         '094\YEAR2\'
         '095\YEAR2\'
         '096\YEAR2\'
         '097\YEAR2\'
         '099\YEAR2\' };
%
% sdat = {'003\BASELINE'
%         '004\BASELINE'
%         '005\BASELINE'
%         '005\YEAR1'   
%         '006\BASELINE'
%         '006\YEAR1'   
%         '007\BASELINE'
%         '007\YEAR1'   
%         '008\BASELINE'
%         '008\YEAR1'   
%         '009\BASELINE'
%         '010\BASELINE'
%         '010\YEAR1'   
%         '011\BASELINE'
%         '012\BASELINE'
%         '014\BASELINE'
%         '015\BASELINE'
%         '016\BASELINE'
%         '017\BASELINE'
%         '017\YEAR1'   
%         '018\BASELINE'
%         '018\YEAR1'   
%         '019\BASELINE'
%         '020\BASELINE'
%         '020\YEAR1'   
%         '021\BASELINE'
%         '021\YEAR1'   
%         '022\BASELINE'
%         '023\BASELINE'
%         '024\BASELINE'
%         '024\YEAR1'   
%         '025\BASELINE'
%         '025\YEAR1'   
%         '026\BASELINE'
%         '027\BASELINE'
%         '028\BASELINE'
%         '030\BASELINE'
%         '031\BASELINE'
%         '031\YEAR1'   
%         '032\BASELINE'
%         '033\BASELINE'
%         '033\YEAR1'   
%         '034\BASELINE'
%         '034\YEAR1'   
%         '035\BASELINE'
%         '035\YEAR1'   
%         '036\BASELINE'
%         '037\BASELINE'
%         '037\YEAR1'   
%         '038\BASELINE'
%         '038\YEAR1'   
%         '040\BASELINE'
%         '041\BASELINE'
%         '042\BASELINE'
%         '042\YEAR1'   
%         '043\BASELINE'
%         '045\BASELINE'
%         '046\BASELINE'
%         '047\BASELINE'
%         '048\BASELINE'
%         '049\BASELINE'
%         '050\BASELINE'
%         '051\BASELINE'
%         '051\YEAR1'   
%         '053\BASELINE'
%         '053\YEAR1'   
%         '055\BASELINE'
%         '055\YEAR1'   
%         '056\BASELINE'
%         '057\BASELINE'
%         '057\YEAR1'   
%         '058\BASELINE'
%         '059\BASELINE'
%         '060\BASELINE'
%         '060\YEAR1'   
%         '061\BASELINE'
%         '061\YEAR1'
%         '062\BASELINE'
%         '062\YEAR1'   
%         '063\BASELINE'
%         '063\YEAR1'   
%         '064\BASELINE'
%         '065\BASELINE'
%         '066\BASELINE'
%         '067\BASELINE'
%         '068\BASELINE'
%         '069\BASELINE'
%         '070\BASELINE'
%         '070\YEAR1'   
%         '071\BASELINE'
%         '072\BASELINE'
%         '073\BASELINE'
%         '074\BASELINE'
%         '075\BASELINE'
%         '076\BASELINE'
%         '077\BASELINE'
%         '077\YEAR1'   
%         '079\BASELINE'
%         '080\BASELINE'
%         '080\YEAR1'   
%         '081\BASELINE'
%         '082\BASELINE'
%         '082\YEAR1'   
%         '083\BASELINE'
%         '084\BASELINE'
%         '085\BASELINE'
%         '086\BASELINE'
%         '087\BASELINE'
%         '088\BASELINE'
%         '089\BASELINE'
%         '090\BASELINE'
%         '091\BASELINE'
%         '091\YEAR1'   
%         '092\BASELINE'
%         '092\YEAR1'   
%         '093\BASELINE'
%         '094\BASELINE'
%         '095\BASELINE'
%         '096\BASELINE'
%         '096\YEAR1'   
%         '097\BASELINE'
%         '098\BASELINE'
%         '099\BASELINE' };
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
o3 = ones(1,3);         % Column index for variable "id"
o5 = ones(1,5);         % Column index for variable "ids"
%
% Initialize Results Variables
%
% Indices key:
%   Index 1 - Subject
%   Index 2 - Leg - 1 = left and 2 = right
%   Index 3 - Compartment - 1 = lateral and 2 = medial
%   Index 4 - AP - 1 = anterior and 2 = posterior
%
t1r_res = zeros(nsubj,2,2,2);
t1r_npx = zeros(nsubj,2,2,2);
t1r_rss = zeros(nsubj,2,2,2);
%
t1r_respx = cell(nsubj,2,2,2);
t1r_rsspx = cell(nsubj,2,2,2);
t1r_nps = cell(nsubj,2,2,2);
%
t2s_res = zeros(nsubj,2,2,2);
t2s_npx = zeros(nsubj,2,2,2);
t2s_rss = zeros(nsubj,2,2,2);
%
t2s_respx = cell(nsubj,2,2,2);
t2s_rsspx = cell(nsubj,2,2,2);
t2s_nps = cell(nsubj,2,2,2);
%
% Loop through Erosion Analysis with Different Masks
%
% for ke = 1:3
for ke = 3              % Square erosion only
%
% Add Erosion Analysis to File Names
%
   atyp = ana_typ(ke,:);
%
   psnama = [psnam atyp];              % Add analysis to PS file name
%    xlsnam = [xlsnam1 atyp xlstyp];     % Add analysis to spreadsheet file name
%
   ifirst = true;       % First write to spreadsheet file
%    ifirst = false;       % First write to spreadsheet file
%
   atyptxt = [upper(atyp) ' Erosion']; % Text for plots
%
% Loop through Subjects\Visits
%
   for ks = 1:nsubj
%    for ks = 72:73
%    for ks = 78:nsubj
%
% Get Subject Directory, Name and Number
%
      sdir = subjs(ks,:);              % Current subject directory
      subj = eval(sdir);               % Subject number
%
      spdir = fullfile(spath,sdir);    % Include series path
%
% Get Visit Directory, Full Path to MRI Data, and Visit Code
%
      vdir = visits{ks};
      if startsWith(vdir,'BASEL','IgnoreCase',true)
        vc = 0;                        % Visit code
      else
        vc = str2double(vdir(end));    % Visit code
      end
%
      vtxt = vtxts(vc+1,:);
%
      svpdir = fullfile(spdir,vdir)    % Include visit in series path
%
      psnams = [psnama '_' sdir '_' vtxt];  % Add subject\visit to PS file name
%
% Get T1rho MAT Files in Directory
%
      d = dir(fullfile(svpdir,'T1rho_S*.mat'));
      rhonams = {d.name}';
      idr = contains(rhonams,'roi','IgnoreCase',true);     % ROI files
      rhonams = rhonams(~idr);
      idr = contains(rhonams,'chk','IgnoreCase',true);     % Check files
      rhonams = rhonams(~idr);
      idr = contains(rhonams,'orig','IgnoreCase',true);    % Original files
      rhonams = rhonams(~idr);
      nrho = size(rhonams,1);
%
      d = dir(fullfile(svpdir,'T1rho_S*mrois.mat'));       % ROI files
      roinams = {d.name}';
      idr = contains(roinams,'orig','IgnoreCase',true);    % ROI original files
      roinams = roinams(~idr);
      nroi = size(roinams,1);
%
      if nrho~=nroi
        warning([' *** WARNING in mri_mes_fit_y2:  Number of T1rho', ...
                 ' MAT files not equal to number of ROI MAT files!']);
      end
%
% T1rho Identifier
%
      ires = 0;         % ires = 0 - T1rho, ires = 1 - T2*
      idt = 1;          % Spin lock/echo time for plots - 1 = 0 ms spin lock time
%
      psnamr = [psnams '_T1R_'];       % Add result type to PS file name
%
% Loop through T1rho MAT Files
%
      for km = 1:nroi
%
% Load Data
%
         roinam = roinams{km};
         load(fullfile(svpdir,roinam),'bbox','cmprt','maskmal', ...
              'maskmam','maskmpl','maskmpm','rsll','rslm');
%
         idm = contains(rhonams,roinam(1:end-10));    % Get matching file
         if ~any(idm)
           error([' *** ERROR in mri_mes_fit_y2:  Matching T1rho', ...
                  ' MAT file not found for ROI MAT file:  ', ...
                  roinam '!']);
         end
         rhonam = rhonams{idm};
         load(fullfile(svpdir,rhonam),'iszs','nslt','scmx','sns', ...
              'snt','splt','st','v');
%
% Remove Longest Spin Lock Time???
%
         nslt = nslt-1;                % Remove longest spin lock time
         splt = splt(1:nslt);
         v = v(:,:,:,1:nslt);
%
         npix = prod(iszs);  % Number of pixels in an image
         fs = ['S' snt];     % Series number prefaced with a 'S'
%
% Parse Series Text for Leg
%
         if strcmpi(st(1),'L')
           leg = 'L';
           ileg = 0;    % Coding for left leg
           ltxt = 'Left';
         else
           leg = 'R';
           ileg = 1;    % Coding for right leg
           ltxt = 'Right';
         end
%
% Add Leg to PS File Name
%
         psnamf = [psnamr leg pstyp];  % Add leg to PS file name
%
% Get Compartment Identifier for Slices
%
         rsls = {rsll'; rslm'};        % Lateral - row 1, medial - row 2
         nrsls = [size(rsll,1); size(rslm,1)];
%
% Get Masks
%
         emaskmal = maskmal;           % No erosion of the mask
         emaskmam = maskmam;           % No erosion of the mask
         emaskmpl = maskmpl;           % No erosion of the mask
         emaskmpm = maskmpm;           % No erosion of the mask
%
         if ke>1       % Erode masks
%
% Loop through the Lateral Slices
%
           for ksl = 1:nrsls(1)
%
% Get Lateral Slice Masks as Two-Dimensional Images
%
              msk_tmpa = maskmal(:,ksl);
              msk_tmpa = reshape(msk_tmpa,iszs);
              msk_tmpp = maskmpl(:,ksl);
              msk_tmpp = reshape(msk_tmpp,iszs);
%
% Erode Lateral Masks
%
              if ke==2
                msk_tmpa = imerode(msk_tmpa,sec);  % Crossed lines
                msk_tmpp = imerode(msk_tmpp,sec);  % Crossed lines
              else
                msk_tmpa = imerode(msk_tmpa,ses);  % Square
                msk_tmpp = imerode(msk_tmpp,ses);  % Square
              end
              emaskmal(:,ksl) =   msk_tmpa(:);
              emaskmpl(:,ksl) =   msk_tmpp(:);
           end
%
% Loop through the Medial Slices
%
           for ksl = 1:nrsls(2)
%
% Get Medial Slice Masks as Two-Dimensional Images
%
              msk_tmpa = maskmam(:,ksl);
              msk_tmpa = reshape(msk_tmpa,iszs);
              msk_tmpp = maskmpm(:,ksl);
              msk_tmpp = reshape(msk_tmpp,iszs);
%
% Erode Medial Masks
%
              if ke==2
                msk_tmpa = imerode(msk_tmpa,sec);  % Crossed lines
                msk_tmpp = imerode(msk_tmpp,sec);  % Crossed lines
              else
                msk_tmpa = imerode(msk_tmpa,ses);  % Square
                msk_tmpp = imerode(msk_tmpp,ses);  % Square
              end
              emaskmam(:,ksl) =   msk_tmpa(:);
              emaskmpm(:,ksl) =   msk_tmpp(:);
           end
%
         end            % End of if - ke>1
%
% Combine Masks into a Cell Array
%
         maskmapl = {emaskmal; emaskmpl};   % Combine lateral anterior and posterior masks
         maskmapm = {emaskmam; emaskmpm};   % Combine medial anterior and posterior masks
         mask = {maskmapl; maskmapm};       % Combine compartment masks
%
% Do Compartmental Analysis
%
         [tc,~,rss,npx,id,tcp,ampp,rssp,nps] = cmprt_ana4m(v,mask, ...
                                 rsls,nrsls,splt,nslt,fun,init,tr0,opt);
         na = size(tc,1);              % Number of results
%
% Save Results
%
% Indices key:
%   Index 1 - Subject
%   Index 2 - Leg - 1 = left and 2 = right
%   Index 3 - Compartment - 1 = lateral and 2 = medial
%   Index 4 - AP - 1 = anterior and 2 = posterior
%
         for ka = 1:na
            t1r_res(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = tc(ka);
            t1r_npx(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = npx(ka);
            t1r_rss(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = rss(ka);
            t1r_respx{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = tcp{ka};
            t1r_rsspx{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = rssp{ka};
            t1r_nps{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = nps{ka};
         end
%
% Plot Results
%
         sid = ['Subject ' sdir ' ' vdir ', ' ltxt ' Leg, T1\rho, ' ...
                atyptxt];
         cmprt_plt4m(v,mask,rsls,nrsls,idt,tcp,nps,mxtr,cmap,bbox, ...
                     sid,psnamf);
%
% Get Statistics on Pixel Results
%
         npxv = zeros(na,1);           % Number of valid results
         tcpm = zeros(na,1);           % Mean
         tcpmn = zeros(na,1);          % Minimum
         tcpmx = zeros(na,1);          % Maximum
         tcpsd = zeros(na,1);          % SD
%
         for ka = 1:na
            idv = tcp{ka}>=trmn&tcp{ka}<=trmx;
            npxv(ka) = sum(idv);       % Number of valid results
            if npxv(ka)>0
              tcpv = tcp{ka}(idv);     % Valid T1rho values
              tcpm(ka) = mean(tcpv);   % Mean
              tcpmn(ka) = min(tcpv);   % Minimum
              tcpmx(ka) = max(tcpv);   % Maximum
              tcpsd(ka) = std(tcpv);   % SD
            end
         end
%
         tcpcov = 100*tcpsd./tcpm;     % Coefficient of variation
         tcpcov(isnan(tcpcov)) = 0;    % Catch any NaNs
%
% Combine Identifiers
%
         ids = [subj vc ires ileg];    % MAT file identifiers
         ids = repmat(ids,na,1);
         ida = [ids id];               % All identifiers
%
% Create and Write Table of Results
%
         t1 = array2table(ida,'VariableNames',hdrs1);
         t2 = table(npx,tc,rss,npxv,tcpm,tcpmn,tcpmx,tcpsd,tcpcov, ...
                    'VariableNames',hdrs2);
         t = [t1 t2];
%
         if ifirst
           writetable(t,xlsnam,'WriteMode','replacefile');
           ifirst = false;
         else
           writetable(t,xlsnam,'WriteMode','append', ...
                      'WriteVariableNames',false);
         end
%
      end               % End of km loop - T1rho MAT file loop
%
      close all;        % Close all plot windows
%
% Get T2* MAT Files in Directory
%
      d = dir(fullfile(svpdir,'T2star_S*.mat'));
      starnams = {d.name}';
      idr = contains(starnams,'roi','IgnoreCase',true);    % ROI files
      starnams = starnams(~idr);
      idr = contains(starnams,'chk','IgnoreCase',true);    % Check files
      starnams = starnams(~idr);
      idr = contains(starnams,'orig','IgnoreCase',true);   % Original files
      starnams = starnams(~idr);
      nstar = size(starnams,1);
%
      d = dir(fullfile(svpdir,'T2star_S*mrois.mat'));      % ROI files
      roinams = {d.name}';
      idr = contains(roinams,'orig','IgnoreCase',true);    % ROI original files
      roinams = roinams(~idr);
      nroi = size(roinams,1);
%
      if nstar~=nroi
        warning([' *** WARNING in mri_mes_fit_y2:  Number of T2*', ...
                 ' MAT files not equal to number of ROI MAT files!']);
      end
%
% T2* Identifier
%
      ires = 1;         % ires = 0 - T1rho, ires = 1 - T2*
      idt = 4;          % Spin lock/echo time for plots - 4 = 5 ms echo time
%
      psnamr = [psnams '_T2S_'];       % Add result type to PS file name
%
% Loop through T2* MAT Files
%
      for km = 1:nroi
%
% Load Data
%
         roinam = roinams{km};
         load(fullfile(svpdir,roinam),'bbox','cmprt','maskmal', ...
              'maskmam','maskmpl','maskmpm','rsll','rslm');
%
         idm = contains(starnams,roinam(1:end-10));   % Get matching file
         if ~any(idm)
           error([' *** ERROR in mri_mes_fit_y2:  Matching T2* MAT', ...
                  ' file not found for ROI MAT file:  ' roinam '!']);
         end
         starnam = starnams{idm};
         load(fullfile(svpdir,starnam),'etns','iszs','netn','scmx', ...
              'sns','snt','st','v');
%
% Remove Longest Echo Time???
%
         netn = netn-1;                % Remove longest echo time
         etns = etns(1:netn);
         v = v(:,:,:,1:netn);
%
         npix = prod(iszs);  % Number of pixels in an image
         fs = ['S' snt];     % Series number prefaced with a 'S'
%
% Parse Series Text for Leg
%
         if strcmpi(st(1),'L')
           leg = 'L';
           ileg = 0;       % Coding for left leg
           ltxt = 'Left';
         else
           leg = 'R';
           ileg = 1;       % Coding for right leg
           ltxt = 'Right';
         end
%
% Add Leg to PS File Name
%
         psnamf = [psnamr leg pstyp];  % Add leg to PS file name
%
% Get Compartment Identifier for Slices
%
         rsls = {rsll'; rslm'};        % Lateral - row 1, medial - row 2
         nrsls = [size(rsll,1); size(rslm,1)];
%
% Get Masks
%
         emaskmal = maskmal;           % No erosion of the mask
         emaskmam = maskmam;           % No erosion of the mask
         emaskmpl = maskmpl;           % No erosion of the mask
         emaskmpm = maskmpm;           % No erosion of the mask
%
         if ke>1       % Erode masks
%
% Loop through the Lateral Slices
%
           for ksl = 1:nrsls(1)
%
% Get Lateral Slice Masks as Two-Dimensional Images
%
              msk_tmpa = maskmal(:,ksl);
              msk_tmpa = reshape(msk_tmpa,iszs);
              msk_tmpp = maskmpl(:,ksl);
              msk_tmpp = reshape(msk_tmpp,iszs);
%
% Erode Lateral Masks
%
              if ke==2
                msk_tmpa = imerode(msk_tmpa,sec);  % Crossed lines
                msk_tmpp = imerode(msk_tmpp,sec);  % Crossed lines
              else
                msk_tmpa = imerode(msk_tmpa,ses);  % Square
                msk_tmpp = imerode(msk_tmpp,ses);  % Square
              end
              emaskmal(:,ksl) =   msk_tmpa(:);
              emaskmpl(:,ksl) =   msk_tmpp(:);
           end
%
% Loop through the Medial Slices
%
           for ksl = 1:nrsls(2)
%
% Get Medial Slice Masks as Two-Dimensional Images
%
              msk_tmpa = maskmam(:,ksl);
              msk_tmpa = reshape(msk_tmpa,iszs);
              msk_tmpp = maskmpm(:,ksl);
              msk_tmpp = reshape(msk_tmpp,iszs);
%
% Erode Medial Masks
%
              if ke==2
                msk_tmpa = imerode(msk_tmpa,sec);  % Crossed lines
                msk_tmpp = imerode(msk_tmpp,sec);  % Crossed lines
              else
                msk_tmpa = imerode(msk_tmpa,ses);  % Square
                msk_tmpp = imerode(msk_tmpp,ses);  % Square
              end
              emaskmam(:,ksl) =   msk_tmpa(:);
              emaskmpm(:,ksl) =   msk_tmpp(:);
           end
%
         end            % End of if - ke>1
%
% Combine Masks into a Cell Array
%
         maskmapl = {emaskmal; emaskmpl};   % Combine lateral anterior and posterior masks
         maskmapm = {emaskmam; emaskmpm};   % Combine medial anterior and posterior masks
         mask = {maskmapl; maskmapm};       % Combine compartment masks
%
% Do Compartmental Analysis
%
         [tc,~,rss,npx,id,tcp,ampp,rssp,nps] = cmprt_ana4m(v,mask, ...
                                    rsls,nrsls,etns,netn,fun,init,ts0,opt);
         na = size(tc,1);              % Number of results
%
% Save Results
%
% Indices key:
%   Index 1 - Subject
%   Index 2 - Leg - 1 = left and 2 = right
%   Index 3 - Compartment - 1 = lateral and 2 = medial
%   Index 4 - AP - 1 = anterior and 2 = posterior
%
         for ka = 1:na
            t2s_res(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = tc(ka);
            t2s_npx(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = npx(ka);
            t2s_rss(ks,ileg+1,id(ka,1)+1,id(ka,2)+1) = rss(ka);
            t2s_respx{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = tcp{ka};
            t2s_rsspx{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = rssp{ka};
            t2s_nps{ks,ileg+1,id(ka,1)+1,id(ka,2)+1} = nps{ka};
         end
%
% Plot Results
%
         sid = ['Subject ' sdir ' ' vdir ', ' ltxt ' Leg, T2*, ' ...
                atyptxt];
         cmprt_plt4m(v,mask,rsls,nrsls,idt,tcp,nps,mxts,cmap,bbox, ...
                     sid,psnamf);
%
% Get Statistics on Pixel Results
%
         npxv = zeros(na,1);           % Number of valid results
         tcpm = zeros(na,1);           % Mean
         tcpmn = zeros(na,1);          % Minimum
         tcpmx = zeros(na,1);          % Maximum
         tcpsd = zeros(na,1);          % SD
%
         for ka = 1:na
            idv = tcp{ka}>=tsmn&tcp{ka}<=tsmx;
            npxv(ka) = sum(idv);       % Number of valid results
            if npxv(ka)>0
              tcpv = tcp{ka}(idv);     % Valid T2* values
              tcpm(ka) = mean(tcpv);   % Mean
              tcpmn(ka) = min(tcpv);   % Minimum
              tcpmx(ka) = max(tcpv);   % Maximum
              tcpsd(ka) = std(tcpv);   % SD
            end
         end
%
         tcpcov = 100*tcpsd./tcpm;     % Coefficient of variation
         tcpcov(isnan(tcpcov)) = 0;    % Catch any NaNs
%
% Combine Identifiers
%
         ids = [subj vc ires ileg];    % MAT file identifiers
         ids = repmat(ids,na,1);
         ida = [ids id];               % All identifiers
%
% Create and Write Table of Results
%
         t1 = array2table(ida,'VariableNames',hdrs1);
         t2 = table(npx,tc,rss,npxv,tcpm,tcpmn,tcpmx,tcpsd,tcpcov, ...
                    'VariableNames',hdrs2);
         t = [t1 t2];
%
         writetable(t,xlsnam,'WriteMode','append', ...
                    'WriteVariableNames',false);
%
      end               % End of km loop - T2* MAT file loop
%
      close all;        % Close all plot windows
%
   end                  % End of ks loop - subjects loop
%
% Save to MAT File
%
   matnam = fullfile(resdir,'mri_mes_fit_y2.mat');
   save(matnam,'t1r_res','t1r_npx','t1r_rss','t1r_respx', ...
        't1r_rsspx','t1r_nps','t2s_res','t2s_npx','t2s_rss', ...
        't2s_respx','t2s_rsspx','t2s_nps');
%
end                     % End of ke loop - erosion analysis loop
%
return