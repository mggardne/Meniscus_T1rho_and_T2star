%#######################################################################
%
%                     * CHecK Abigail's Meniscus *
%          * Regions of Interest (ROIs) Reliability Program *
%
%          M-File which reads the PTOA registered MRI data and meniscus
%     reliability segmentation CSV files to check the naming convention
%     of the meniscus regions of interest in the lateral and medial
%     compartments.  
%
%     NOTES:  1.  The registered MRI MAT files must be in subject
%             directories and in visit subdirectories  "..\PTOA\0*\?"
%             where "*" is the subject number and ? is one of the visit
%             identifiers (BASELINE, YEAR1, etc.).
%
%             2.  T1rho MAT files must start with "T1rho_S" and T2* MAT
%             files must start with "T2star_S".  See rd_m_dicom.m.
%
%             3.  M-file rd_roi6hp.m  must be in the current directory
%             or path.
%
%     12-Sep-2024 * Mack Gardner-Morse
%

%#######################################################################
%
% ROI Names
%
roinams = { 'PHLM'
            'PHMM' };
%
% roinams = { 'AHL
%             'PHL
%             'AHM
%             'PHMM' };
%
num_rois = size(roinams,1);
%
% Compartment Labels
%
cmprt = {'Lateral'; 'Medial'};
%
% Knee Labels
%
legs = {' Left '; ' Right '};
%
% Get PTOA Directory
%
spath = fullfile('..','PTOA');         % Path to series MAT files
%
% Subject Data
%
sdat = {'068\YEAR2\'
        '069\YEAR2\'
        '070\YEAR2\'
        '071\YEAR2\'
        '072\YEAR2\'
        '074\YEAR2\'
        '075\YEAR2\'
        '076\YEAR2\'
        '077\YEAR2\'
        '079\YEAR2\'
        '080\YEAR2\'} ;
%
% sdat = {'003\YEAR2' 
%         '005\YEAR2'
%         '006\YEAR2'
%         '007\YEAR2'
%         '008\YEAR2' };
%
% sdat = {'004\BASELINE'
%         '005\BASELINE'
%         '006\BASELINE'
%         '008\BASELINE'
%         '009\BASELINE'
%         '010\BASELINE'
%         '011\BASELINE'
%         '014\BASELINE'
%         '015\BASELINE'
%         '016\BASELINE'
%         '022\BASELINE'
%         '023\BASELINE'
%         '025\BASELINE'
%         '026\BASELINE'
%         '027\BASELINE'
%         '028\BASELINE'
%         '033\BASELINE'
%         '036\BASELINE'
%         '037\BASELINE'
%         '040\BASELINE'
%         '041\BASELINE'
%         '043\BASELINE'
%         '045\BASELINE'
%         '047\BASELINE'
%         '049\BASELINE'
%         '050\BASELINE'
%         '053\BASELINE'
%         '055\BASELINE'
%         '056\BASELINE'
%         '057\BASELINE'
%         '058\BASELINE'
%         '059\BASELINE'
%         '060\BASELINE'
%         '061\BASELINE'
%         '062\BASELINE'
%         '063\BASELINE'
%         '064\BASELINE'
%         '065\BASELINE'
%         '066\BASELINE'
%         '067\BASELINE'
%         '068\BASELINE'
%         '069\BASELINE'
%         '070\BASELINE'
%         '071\BASELINE'
%         '072\BASELINE'
%         '073\BASELINE'
%         '074\BASELINE'
%         '075\BASELINE'
%         '076\BASELINE'
%         '077\BASELINE'
%         '079\BASELINE'
%         '083\BASELINE'
%         '084\BASELINE'
%         '085\BASELINE'
%         '086\BASELINE'
%         '087\BASELINE'
%         '088\BASELINE'
%         '089\BASELINE'
%         '090\BASELINE'
%         '091\BASELINE'
%         '092\BASELINE'
%         '093\BASELINE'
%         '094\BASELINE'
%         '095\BASELINE'
%         '096\BASELINE'
%         '097\BASELINE'
%         '098\BASELINE'
%         '099\BASELINE'
%         '005\YEAR1'
%         '006\YEAR1'
%         '008\YEAR1'
%         '010\YEAR1'
%         '025\YEAR1'
%         '033\YEAR1'
%         '037\YEAR1'
%         '053\YEAR1'
%         '055\YEAR1'
%         '057\YEAR1'
%         '060\YEAR1'
%         '063\YEAR1'
%         '070\YEAR1'
%         '007\YEAR1'
%         '017\YEAR1'
%         '018\YEAR1'
%         '020\YEAR1'
%         '021\YEAR1'
%         '024\YEAR1'
%         '031\YEAR1'
%         '034\YEAR1'
%         '035\YEAR1'
%         '038\YEAR1'
%         '042\YEAR1'
%         '051\YEAR1'
%         '062\YEAR1'};
%
% Get Subject and Visit Data
%
subjs = char(sdat);
subjs = subjs(:,1:3);
subjs = unique(subjs,'rows');
nsubj = size(subjs,1);
%
visits = cell(nsubj,1);
%
for k = 1:nsubj
   idx = startsWith(sdat,subjs(k,:));
   vdat = sdat(idx);
   visits{k} = strrep(vdat,[subjs(k,:) '\'],'');
end
%
nvisits = cellfun('length',visits);
%
% Loop through Subjects
%
% for ks = 1:nsubj
% for ks = 1:2
% for ks = 26:nsubj
% for ks = 67:nsubj
% for ks = [27 61 71:nsubj]
for ks = 1:nsubj
%
% Get Subject Directory, Name and Number
%
   sdir = subjs(ks,:);  % Current subject directory
   subj = eval(sdir);   % Subject number
%
   spdir = fullfile(spath,sdir);       % Include series path
%
% Get Number of Visits for this Subject
%
   nv = nvisits(ks);    % Number of visits
%
% Loop through Visits
%
   for kv = 1:nv
%
% Get Visit Directory and Full Path to MRI Data
%
      vdir = visits{ks}{kv};
%
      svpdir = fullfile(spdir,vdir);   % Include visit in series path
%
% T1rho Series and Segmentations
%
      rdir = 'RHO';     % Directory for T1rho segmentations
%
% Get T1rho MAT Files in Directory
%
      d = dir(fullfile(svpdir,'T1rho_S*.mat'));
      mnams = {d.name}';
      idr = contains(mnams,'roi','IgnoreCase',true);  % ROI files
      mnams = mnams(~idr);
      idr = contains(mnams,'chk','IgnoreCase',true);  % Check files
      mnams = mnams(~idr);
      nmat = size(mnams,1);
%
% Loop through T1rho MAT Files
%
      for m = 1:nmat
%
         mnam = mnams{m};
         load(fullfile(svpdir,mnam),'iszs','snt','st','v');
         fs = ['S' snt];     % Series number prefaced with a 'S'
%
% Parse Series Text for Leg
%
         leg = upper(st(1));
         if strcmpi(leg,'L')
           lstr = legs{1};
         else
           lstr = legs{2};
         end
%
% Get Segmentation File Name and Read ROIs
%
         segdir = fullfile(svpdir,rdir);    % Segmentation path
         rnam = dir(fullfile(segdir,[sdir '_' leg ...
                    '_sag_menisci_RHO_*.csv']));
         if isempty(rnam)
           rnam = [sdir '_' leg '_SAG_MENISCI_RHO_*.csv'];
           fprintf(1,'\n\n *** ERROR in %s in directory %s!\n', ...
                   rnam,segdir);
           fprintf(1,'CSV file %s not found!\n',rnam);
         else
           rnam = {rnam.name}';
           idx = contains(rnam,'_REL','IgnoreCase',true);
           rnam = rnam(idx);
           idx = contains(rnam,'_EDIT');    % Check for edited files
           if any(idx)
             rnam = rnam(idx);
           end
%
           if size(rnam,1)>1
             error([' *** ERROR in seg_am_rois:  More than one', ...
                    ' T1rho segmentation file for subject ' sdir, ...
                    ' on the ', lstr ' leg!']);
           end
%
% Read ROI Data and Check ROI Names
%
           rnam = char(rnam);
           rois = rd_roi6hp(fullfile(segdir,rnam),true);
           nrois = size(rois,1);
%
           roisnam = {rois.name}';
           idr = false(num_rois,nrois);
           for n = 1:nrois
              idr(:,n) = strcmp(roisnam{n},roinams);
           end
           idr1 = any(idr);            % ROI names are standard names
           idr2 = any(idr');           % Standard names are present
%
% Check for Number of Slices
%
           rsl = {rois.imageno}';
           nsls = cellfun('length',rsl);    % Five (5) meniscus slices
%
% Output Problem Segmentation Files
%
           if nrois~=num_rois||any(nsls>5)||~all(idr1)||~all(idr2)
             fprintf(1,'\n\n *** ERROR in %s in directory %s!\n', ...
                     rnam,segdir);
             if nrois<num_rois
               fprintf(1,'Only %1i ROIS!\n',nrois);
             else
               fprintf(1,'%1i ROIS!\n',nrois);
             end
%
             if any(nsls>5)            % Five (5) meniscus slices
               ids = nsls>5;
               fprintf(1,'%s appears more than once on a slice!\n', ...
                       roisnam{ids});
             end
%
             if ~all(idr1)
               idr = ~idr1;
               fprintf(1,'%s is not a standard ROI name!\n', ...
                       roisnam{idr});
             end
%
             if ~all(idr2)
               idr = ~idr2;
               fprintf(1,'%s is missing!\n', roinams{idr});
             end
           end
%
         end            % End of missing ROI CSV file
%
      end               % End of m loop - MAT file loop
%
% T2star
%
      rdir = 'T2S';     % Directory for T2* segmentations
%
% Get T2* MAT Files in Directory
%
      d = dir(fullfile(svpdir,'T2star_S*.mat'));
      mnams = {d.name}';
      idr = contains(mnams,'roi','IgnoreCase',true);  % ROI files
      mnams = mnams(~idr);
      idr = contains(mnams,'chk','IgnoreCase',true);  % Check files
      mnams = mnams(~idr);
      nmat = size(mnams,1);
%
% Loop through T2* MAT Files
%
      for m = 1:nmat
%
         mnam = mnams{m};
         load(fullfile(svpdir,mnam),'iszs','snt','st','v');
         fs = ['S' snt];     % Series number prefaced with a 'S'
%
% Parse Series Text for Leg
%
         leg = upper(st(1));
         if strcmpi(leg,'L')
           lstr = legs{1};
         else
           lstr = legs{2};
         end
%
% Get Segmentation File Name and Read ROIs
%
         segdir = fullfile(svpdir,rdir);    % Segmentation path
         rnam = dir(fullfile(segdir,[sdir '_' leg ...
                    '_SAG_MENISCI_T2S_*.csv']));
         if isempty(rnam)
           rnam = [sdir '_' leg '_SAG_MENISCI_T2S_*.csv'];
           fprintf(1,'\n\n *** ERROR in %s in directory %s!\n', ...
                   rnam,segdir);
           fprintf(1,'CSV file %s not found!\n',rnam);
         else
           rnam = {rnam.name}';
           idx = contains(rnam,'_REL','IgnoreCase',true);
           rnam = rnam(idx);
           idx = contains(rnam,'_EDIT');    % Check for edited files
           if any(idx)
             rnam = rnam(idx);
           end
%
           if size(rnam,1)>1
             error([' *** ERROR in seg_am_rois:  More than one T2*', ...
                    ' segmentation file for subject ' sdir ' on', ...
                    ' the ' lstr ' leg!']);
           end
%
% Read ROI Data and Check ROI Names
%
           rnam = char(rnam);
           rois = rd_roi6hp(fullfile(segdir,rnam),true);
           nrois = size(rois,1);
%
           roisnam = {rois.name}';
           idr = false(num_rois,nrois);
           for n = 1:nrois
              idr(:,n) = strcmp(roisnam{n},roinams);
           end
           idr1 = any(idr);            % ROI names are standard names
           idr2 = any(idr');           % Standard names are present
%
% Check for Number of Slices
%
           rsl = {rois.imageno}';
           nsls = cellfun('length',rsl);    % Five (5) meniscus slices
%
% Output Problem Segmentation Files
%
           if nrois~=num_rois||any(nsls>5)||~all(idr1)||~all(idr2)
             fprintf(1,'\n\n *** ERROR in %s in directory %s!\n', ...
                     rnam,segdir);
             if nrois<num_rois
               fprintf(1,'Only %1i ROIS!\n',nrois);
             else
               fprintf(1,'%1i ROIS!\n',nrois);
             end
%
             if any(nsls>5)            % Five (5) meniscus slices
               ids = nsls>5;
               fprintf(1,'%s appears more than once on a slice!\n', ...
                       roisnam{ids});
             end
%
             if ~all(idr1)
               idr = ~idr1;
               fprintf(1,'%s is not a standard ROI name!\n', ...
                       roisnam{idr});
             end
%
             if ~all(idr2)
               idr = ~idr2;
               fprintf(1,'%s is missing!\n', roinams{idr});
             end
           end
%
         end            % End of missing ROI CSV file
%
      end               % End of m loop - MAT file loop
%
   end                  % End of visit (kv) loop
%
end                     % End of subject (ks) loop
%
return