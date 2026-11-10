%#######################################################################
%
%                * SEGmentation to Abigail's Meniscus *
%                * Regions of Interest (ROIs) Program *
%
%          M-File which reads the PTOA registered MRI data and meniscus
%     segmentation CSV files to create masks for the meniscus regions
%     of interest in the lateral and medial compartments.  The masks
%     are saved in MAT files with the series number, visit ID, and
%     ending in "_mrois.mat."
%
%     NOTES:  1.  The registered MRI MAT files must be in subject
%             directories and in visit subdirectories  "..\PTOA\0*\?"
%             where "*" is the subject number and ? is one of the visit
%             identifiers (BASELINE, YEAR1, etc.).
%
%             2.  T1rho MAT files must start with "T1rho_S" and T2* MAT
%             files must start with "T2star_S".  See rd_m_dicom.m.
%
%             3.  Meniscus segmentation files ending with "*AC.csv" are
%             used if there are other meniscus segmentation files not
%             ending with "*AC.csv".
%
%             4.  M-files circ_plt.m, cr_mask2.m, cr_mask2f.m,
%             fnd_bbox.m, lsect2.m, lsect2a.m, lsect3.m, lsect4.m,
%             lsect5.m, midline.m,  mk2_tri_2d.m, mk2_tri_2df.m,
%             rd_roi6hp.m and tri2d.m must be in the current directory
%             or path.
%
%     03-Sep-2024 * Mack Gardner-Morse
%

%#######################################################################
%
% Setup Color Maps, Line Types and Color, and Legend Strings
%
gmap = gray(128);       % Gray color map for not cartilage
jmap = jet(128);        % Jet color map for cartilage
cmap = [gmap; jmap];
rmap = [[0.85 0 0]; [0 0 0.85]; gmap]; % Red/blue color map for ROIs
%
lt = ['g.-'; 'b.-'; 'r.-'; 'c.-'; 'y.-'; 'm.-']; % Line color and type
legds = {'ANT_LAT'; 'ANT_MED'; 'POST_LAT'; 'POST_MED'};
nlegds = size(legds,1);
%
ipad = 25;              % Bounding box padding in pixels
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
sdat = {'004\BASELINE'
        '005\BASELINE'
        '006\BASELINE'
        '008\BASELINE'
        '009\BASELINE'
        '010\BASELINE'
        '011\BASELINE'
        '014\BASELINE'
        '015\BASELINE'
        '016\BASELINE'
        '022\BASELINE'
        '023\BASELINE'
        '025\BASELINE'
        '026\BASELINE'
        '027\BASELINE'
        '028\BASELINE'
        '033\BASELINE'
        '036\BASELINE'
        '037\BASELINE'
        '040\BASELINE'
        '041\BASELINE'
        '043\BASELINE'
        '045\BASELINE'
        '047\BASELINE'
        '049\BASELINE'
        '050\BASELINE'
        '053\BASELINE'
        '055\BASELINE'
        '056\BASELINE'
        '057\BASELINE'
        '058\BASELINE'
        '059\BASELINE'
        '060\BASELINE'
        '061\BASELINE'
        '062\BASELINE'
        '063\BASELINE'
        '064\BASELINE'
        '065\BASELINE'
        '066\BASELINE'
        '067\BASELINE'
        '068\BASELINE'
        '069\BASELINE'
        '070\BASELINE'
        '071\BASELINE'
        '072\BASELINE'
        '073\BASELINE'
        '074\BASELINE'
        '075\BASELINE'
        '076\BASELINE'
        '077\BASELINE'
        '079\BASELINE'
        '083\BASELINE'
        '084\BASELINE'
        '085\BASELINE'
        '086\BASELINE'
        '087\BASELINE'
        '088\BASELINE'
        '089\BASELINE'
        '090\BASELINE'
        '091\BASELINE'
        '092\BASELINE'
        '093\BASELINE'
        '094\BASELINE'
        '095\BASELINE'
        '096\BASELINE'
        '097\BASELINE'
        '098\BASELINE'
        '099\BASELINE'
        '005\YEAR1'
        '006\YEAR1'
        '008\YEAR1'
        '010\YEAR1'
        '025\YEAR1'
        '033\YEAR1'
        '037\YEAR1'
        '053\YEAR1'
        '055\YEAR1'
        '057\YEAR1'
        '060\YEAR1'
        '063\YEAR1'
        '070\YEAR1'
        '007\YEAR1'
        '017\YEAR1'
        '018\YEAR1'
        '020\YEAR1'
        '021\YEAR1'
        '024\YEAR1'
        '031\YEAR1'
        '034\YEAR1'
        '035\YEAR1'
        '038\YEAR1'
        '042\YEAR1'
        '051\YEAR1'
        '062\YEAR1'};
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
% for ks = 27:nsubj
% ids = [29 30 31 32 33 34 35 36 37 38 39 41 42 43 44 45 46 48 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 68 69 70 71 72 74 75 76 77 78 79 80];
ids = [27 28 40 47 49 65 66 67 73];
for ks = ids
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
      id5m = 1;         % Use first spin lock time for plots
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
         rnam = {rnam.name}';
%
         if isempty(rnam)
           warning([' *** WARNING in seg_am_rois: CSV segmentation', ...
                    ' file %s not found!'],fullfile(segdir,[sdir, ...
                    '_' leg '_sag_menisci_RHO_*.csv']));
           continue;
         end
%
         idx = ~contains(rnam,'_REL','IgnoreCase',true);
         rnam = rnam(idx);
         idx = contains(rnam,'_EDIT');      % Check for edited files
         if any(idx)
           rnam = rnam(idx);
         end
%
         if size(rnam,1)>1
%
           rnam = dir(fullfile(segdir,[sdir '_' leg ...
                      '_sag_menisci_RHO_*AC.csv']));
           rnam = {rnam.name}';
           idx = ~contains(rnam,'_REL','IgnoreCase',true);
           rnam = rnam(idx);
           idx = contains(rnam,'_EDIT');    % Check for edited files
           if any(idx)
             rnam = rnam(idx);
           end
%
           if size(rnam,1)>1
             error([' *** ERROR in seg_am_rois:  More than one', ...
                    ' T1rho segmentation file for subject ' sdir, ...
                    ' on the ' lstr ' leg!']);
           end
         end
%
         rnam = char(rnam);
         rois = rd_roi6hp(fullfile(segdir,rnam),true);
         nrois = size(rois,1);
%
% Get MRI Slices
%
         rsl = [rois.imageno]';
         rsl = unique(rsl);  % Ensure unique slices in sorted order
         nrsl = size(rsl,1);
%
% Loop through ROI Slices, Plot ROIs and Generate Masks for Each Slice
%
         pnam1 = fullfile(svpdir,[fs '_am_ROIs1.ps']);     % ROI lines print file name
         pnam2 = fullfile(svpdir,[fs '_am_ROIs2.ps']);     % ROI areas print file name
%
         mcoords = cell(nrsl,nrois);   % Meniscus coordinates
%
         iap = zeros(nrsl,nrois);           % -1 - anterior, 1 - posterior
         icmprt = zeros(nrsl,nrois);        % -1 - lateral, 1 - medial
         npxt = prod(iszs);                 % Total number of pixels in a slice
         maskm = false(npxt,nrsl,nrois);    % Masks for all meniscus segmentations
         masks = false(npxt,nrsl);          % Masks for meniscus slices
%
% Loop through Slices
%
         for k = 1:nrsl % Loop through slices
%
% Get T1rho Slice Image
%
            slk = rsl(k);    % Slice number
            img = squeeze(v(:,:,slk,id5m));
%
            figure;
            orient landscape;
            imagesc(img);
            colormap gray;
            axis image;
            axis off;
            hold on;
%
            lh = gobjects(nrois,1);    % Line graphic handles
            idl = false(nrois,1);
            idxs = false(nlegds,1);
%
% Get ROI Data for this Slice and Plot ROIs
%
            for l = 1:nrois            % Loop through ROIs
               idxr = rois(l).imageno==slk;
               if any(idxr)
                 mcoords(k,l) = rois(l).data(idxr);   % Meniscus coordinates
%
                 snam = rois(l).name;  % Get ROI name
%
                 if strcmpi(snam(1),'A')
                   iap(k,l) = -1;      % -1 - anterior
                 else
                   iap(k,l) = 1;       % 1 - posterior
                 end
                 if strcmpi(snam(end-1),'L')
                   icmprt(k,l) = -1;   % -1 - lateral
                 else
                   icmprt(k,l) = 1;    % 1 - medial
                 end
%
% Create Logical Masks for this Slice
%
                 maskm(:,k,l) = cr_maskm(mcoords{k,l},iszs);    % Masks for all segmentations
                 masks(:,k) = masks(:,k)|maskm(:,k,l);          % Masks for slices
%
                 idx = iap(k,l)+icmprt(k,l)/2+2.5;    % Index to legend entry
                 idxs(idx) = true;
%
                 lh(l) = plot(mcoords{k,l}(:,1),mcoords{k,l}(:,2), ...
                              lt(idx,:));
                 idl(l) = true;
               end      % End of if - any rois for this slice
            end         % End of rois loop
%
% Add Legend and Title, and Print Slice Plots
%
            bbx = fnd_bbox(masks(:,k),iszs,ipad);
            axis(bbx);
            legend(lh(idl),legds(idxs,:),'Interpreter','none');
            title({[sdir ' ' vdir lstr 'Leg T1\rho']; [fs ' Slice ', ...
                  int2str(slk)]; [cmprt{any(icmprt(k,:)==1)+1}, ...
                  ' Compartment']},'FontSize',16,'FontWeight','bold');
            if k==1
              print('-dpsc2','-r600','-fillpage',pnam1);
            else
              print('-dpsc2','-r600','-fillpage','-append',pnam1);
            end
%
% Plot ROIs
%
            cmx = max(img(:));
            img1 = img-cmx-1;
            dcmx = 16*cmx/128;
            maskms = squeeze(maskm(:,k,idl));
            img1(maskms(:,iap(k,idl)==-1)) = dcmx;    % Blue - Anterior
            img1(maskms(:,iap(k,idl)==1)) = cmx-dcmx; % Red - Posterior
%
            figure;
            orient landscape;
            imagesc(img1);
            colormap(cmap);
            caxis([-cmx cmx]);
            axis image;
            axis(bbx);
            axis off;
            title({[sdir ' ' vdir lstr 'Leg T1\rho']; [fs ' Slice ', ...
                  int2str(slk)]; [cmprt{any(icmprt(k,:)==1)+1}, ...
                  ' Compartment']; ['Blue - Anterior and Red - ', ...
                  'Posterior']},'FontSize',16,'FontWeight','bold');
%
            if k==1
              print('-dpsc2','-r600','-fillpage',pnam2);
            else
              print('-dpsc2','-r600','-fillpage','-append',pnam2);
            end
%
         end            % End of slices loop
%
% Get Bounding Box for All Slices
%
         bbox = fnd_bbox(masks,iszs,ipad);
%
% Get Compartment Identifier for Slices
%
         idl = sum(icmprt,2)<0;        % Index to lateral slices
         rsll = rsl(idl);              % Lateral compartment slices
         nl = size(rsll,1);            % Number of lateral slices
         rslm = rsl(~idl);             % Medial compartment slices
         nm = size(rslm,1);            % Number of medial slices
%
% Get Compartment and AP Specific Masks
%
         maskml = maskm(:,idl,:);      % Masks for lateral slices
         maskmm = maskm(:,~idl,:);     % Masks for medial slices
%
         idapl = sum(iap(idl,:));
         idal = idapl<0;               % Column index to anterior lateral masks
         if any(idal)
           maskmal = maskml(:,:,idal); % Anterior lateral mask
         else
           maskmal = false(npxt,nl);   % Anterior lateral mask
         end
         idpl = idapl>0;               % Column index to posterior lateral masks
         if any(idpl)
           maskmpl = maskml(:,:,idpl); % Posterior lateral mask
         else
           maskmpl = false(npxt,nl);   % Posterior lateral mask
         end
%
         idapm = sum(iap(~idl,:));
         idam = idapm<0;               % Column index to anterior medial masks
         if any(idam)
           maskmam = maskmm(:,:,idam); % Anterior medial mask
         else
           maskmam = false(npxt,nm);   % Anterior medial mask
         end
         idpm = idapm>0;               % Column index to posterior medial masks
         if any(idpm)
           maskmpm = maskmm(:,:,idpm); % Posterior medial mask
         else
           maskmpm = false(npxt,nm);   % Posterior medial mask
         end
%
% Get Compartment and AP Specific Meniscus Coordinates
%
         mcoordl = mcoords(idl,:);     % Meniscus coordinates for lateral slices
         mcoordm = mcoords(~idl,:);    % Meniscus coordinates for medial slices
%
         mcoordal = mcoordl(:,idal);   % Anterior lateral meniscus coordinates
         mcoordpl = mcoordl(:,idpl);   % Posterior lateral meniscus coordinates
%
         mcoordam = mcoordm(:,idam);   % Anterior medial meniscus coordinates
         mcoordpm = mcoordm(:,idpm);   % Posterior medial meniscus coordinates
%
% Save Masks, ROIS and Slice Information into MAT File
%
         savnam = [mnam(1:end-4) '_mrois.mat'];
         savnam = fullfile(svpdir,savnam);
         save(savnam,'bbox','cmprt','legs','maskmal','maskmam', ...
              'maskmpl','maskmpm','masks','mcoordal','mcoordam', ...
              'mcoordpl','mcoordpm','rsl','rsll','rslm');
%
         close all;
%
      end               % End of m loop - MAT file loop
%
% T2star
%
      rdir = 'T2S';     % Directory for T2* segmentations
      id5m = 4;         % Default echo time (5 ms) for segmentations
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
                    '_sag_menisci_T2S_*.csv']));
         rnam = {rnam.name}';
%
         if isempty(rnam)
           warning([' *** WARNING in seg_am_rois: CSV segmentation', ...
                    ' file %s not found!'],fullfile(segdir,[sdir, ...
                    '_' leg '_sag_menisci_T2S_*.csv']));
           continue;
         end
%
         idx = ~contains(rnam,'_REL','IgnoreCase',true);
         rnam = rnam(idx);
         idx = contains(rnam,'_EDIT');      % Check for edited files
         if any(idx)
           rnam = rnam(idx);
         end
%
         if size(rnam,1)>1
           rnam = dir(fullfile(segdir,[sdir '_' leg ...
                      '_sag_menisci_T2S_*AC.csv']));
           rnam = {rnam.name}';
           idx = ~contains(rnam,'_REL','IgnoreCase',true);
           rnam = rnam(idx);
           idx = contains(rnam,'_EDIT');    % Check for edited files
           if any(idx)
             rnam = rnam(idx);
           end
           if size(rnam,1)>1
             error([' *** ERROR in seg_am_rois:  More than one T2*', ...
                    ' segmentation file for subject ' sdir, ...
                    ' on the ' lstr ' leg!']);
           end
         end
%
         rnam = char(rnam);
         rois = rd_roi6hp(fullfile(segdir,rnam),true);
         nrois = size(rois,1);
%
% Get MRI Slices
%
         rsl = [rois.imageno]';
         rsl = unique(rsl);  % Ensure unique slices in sorted order
         nrsl = size(rsl,1);
%
% Loop through ROI Slices, Plot ROIs and Generate Masks for Each Slice
%
         pnam1 = fullfile(svpdir,[fs '_am_ROIs1.ps']);     % ROI lines print file name
         pnam2 = fullfile(svpdir,[fs '_am_ROIs2.ps']);     % ROI areas print file name
%
         mcoords = cell(nrsl,nrois);   % Meniscus coordinates
%
         iap = zeros(nrsl,nrois);            % -1 - anterior, 1 - posterior
         icmprt = zeros(nrsl,nrois);         % -1 - lateral, 1 - medial
         npxt = prod(iszs);                  % Total number of pixels in a slice
         maskm = false(npxt,nrsl,nrois);     % Masks for all meniscus segmentations
         masks = false(npxt,nrsl);           % Masks for meniscus slices
%
% Loop through Slices
%
         for k = 1:nrsl      % Loop through slices
%
% Get T2 Slice Image
%
            slk = rsl(k);    % Slice number
            img = squeeze(v(:,:,slk,id5m));
%
            figure;
            orient landscape;
            imagesc(img);
            colormap gray;
            axis image;
            axis off;
            hold on;
%
            lh = gobjects(nrois,1);    % Line graphic handles
            idl = false(nrois,1);
            idxs = false(nlegds,1);
%
% Get ROI Data for this Slice and Plot ROIs
%
            for l = 1:nrois            % Loop through ROIs
               idxr = rois(l).imageno==slk;
               if any(idxr)
                 mcoords(k,l) = rois(l).data(idxr); % Meniscus coordinates
%        
                 snam = rois(l).name;  % Get ROI name
%        
                 if strcmpi(snam(1),'A')
                   iap(k,l) = -1;      % -1 - anterior
                 else
                   iap(k,l) = 1;       % 1 - posterior
                 end
                 if strcmpi(snam(end-1),'L')
                   icmprt(k,l) = -1;   % -1 - lateral
                 else
                   icmprt(k,l) = 1;    % 1 - medial
                 end
%
% Create Logical Masks for this Slice
%
                 maskm(:,k,l) = cr_maskm(mcoords{k,l},iszs);    % Masks for all segmentations
                 masks(:,k) = masks(:,k)|maskm(:,k,l);          % Masks for slices
%
                 idx = iap(k,l)+icmprt(k,l)/2+2.5;
                 idxs(idx) = true;
%
                 lh(l) = plot(mcoords{k,l}(:,1),mcoords{k,l}(:,2), ...
                              lt(idx,:));
                 idl(l) = true;
               end      % End of if - any rois for this slice
            end         % End of rois loop
%
% Add Legend and Title, and Print Slice Plots
%
            bbx = fnd_bbox(masks(:,k),iszs,ipad);
            axis(bbx);
            legend(lh(idl),legds(idxs,:),'Interpreter','none');
            title({[sdir ' ' vdir lstr 'Leg T2*']; [fs ' Slice ' ...
                  int2str(slk)]; [cmprt{any(icmprt(k,:)==1)+1} ...
                  ' Compartment']}, 'FontSize',16,'FontWeight','bold');
            if k==1
              print('-dpsc2','-r600','-fillpage',pnam1);
            else
              print('-dpsc2','-r600','-fillpage','-append',pnam1);
            end
%
% Plot ROIs
%
            cmx = max(img(:));
            img1 = img-cmx-1;
            dcmx = 16*cmx/128;
            maskms = squeeze(maskm(:,k,idl));
            img1(maskms(:,iap(k,idl)==-1)) = dcmx;    % Blue - Anterior
            img1(maskms(:,iap(k,idl)==1)) = cmx-dcmx; % Red - Posterior
%
            figure;
            orient landscape;
            imagesc(img1);
            colormap(cmap);
            caxis([-cmx cmx]);
            axis image;
            axis(bbx);
            axis off;
            title({[sdir ' ' vdir lstr 'Leg T2*']; [fs ' Slice ' ...
                  int2str(slk)]; [cmprt{any(icmprt(k,:)==1)+1} ...
                  ' Compartment']; ['Blue - Anterior and Red - ' ...
                  'Posterior']},'FontSize',16,'FontWeight','bold');
%
            if k==1
              print('-dpsc2','-r600','-fillpage',pnam2);
            else
              print('-dpsc2','-r600','-fillpage','-append',pnam2);
            end
%
         end            % End of slices loop
%
% Get Bounding Box for All Slices
%
         bbox = fnd_bbox(masks,iszs,ipad);
%
% Get Compartment Identifier for Slices
%
         idl = sum(icmprt,2)<0;        % Index to lateral slices
         rsll = rsl(idl);              % Lateral compartment slices
         nl = size(rsll,1);            % Number of lateral slices
         rslm = rsl(~idl);             % Medial compartment slices
         nm = size(rslm,1);            % Number of medial slices
%
% Get Compartment and AP Specific Masks
%
         maskml = maskm(:,idl,:);      % Masks for lateral slices
         maskmm = maskm(:,~idl,:);     % Masks for medial slices
%
         idapl = sum(iap(idl,:));
         idal = idapl<0;               % Column index to anterior lateral masks
         if any(idal)
           maskmal = maskml(:,:,idal); % Anterior lateral mask
         else
           maskmal = false(npxt,nl);   % Anterior lateral mask
         end
         idpl = idapl>0;               % Column index to posterior lateral masks
         if any(idpl)
           maskmpl = maskml(:,:,idpl); % Posterior lateral mask
         else
           maskmpl = false(npxt,nl);   % Posterior lateral mask
         end
%
         idapm = sum(iap(~idl,:));
         idam = idapm<0;               % Column index to anterior medial masks
         if any(idam)
           maskmam = maskmm(:,:,idam); % Anterior medial mask
         else
           maskmam = false(npxt,nm);   % Anterior medial mask
         end
         idpm = idapm>0;               % Column index to posterior medial masks
         if any(idpm)
           maskmpm = maskmm(:,:,idpm); % Posterior medial mask
         else
           maskmpm = false(npxt,nm);   % Posterior medial mask
         end
%
% Get Compartment and AP Specific Meniscus Coordinates
%
         mcoordl = mcoords(idl,:);     % Meniscus coordinates for lateral slices
         mcoordm = mcoords(~idl,:);    % Meniscus coordinates for medial slices
%
         mcoordal = mcoordl(:,idal);   % Anterior lateral meniscus coordinates
         mcoordpl = mcoordl(:,idpl);   % Posterior lateral meniscus coordinates
%
         mcoordam = mcoordm(:,idam);   % Anterior medial meniscus coordinates
         mcoordpm = mcoordm(:,idpm);   % Posterior medial meniscus coordinates
%
% Save Masks, ROIS and Slice Information into MAT File
%
         savnam = [mnam(1:end-4) '_mrois.mat'];
         savnam = fullfile(svpdir,savnam);
         save(savnam,'bbox','cmprt','legs','maskmal','maskmam', ...
              'maskmpl','maskmpm','masks','mcoordal','mcoordam', ...
              'mcoordpl','mcoordpm','rsl','rsll','rslm');
%        
         close all;
%
      end               % End of m loop - MAT file loop
%
   end                  % End of visit (kv) loop
%
end                     % End of subject (ks) loop
%
return