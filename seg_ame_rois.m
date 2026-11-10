%#######################################################################
%
%             * SEGmentation to Abigail's Meniscus Edited *
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
%             3.  MAT file "files_01Sep2024.mat" must be in the main
%             PTOA directory with the list of new edited files.
%
%             4.  M-files circ_plt.m, cr_mask2.m, cr_mask2f.m,
%             fnd_bbox.m, lsect2.m, lsect2a.m, lsect3.m, lsect4.m,
%             lsect5.m, midline.m,  mk2_tri_2d.m, mk2_tri_2df.m,
%             rd_roi6hp.m and tri2d.m must be in the current directory
%             or path.
%
%     17-Sep-2024 * Mack Gardner-Morse
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
% Get List of New Edited Segmentation CSV Files
%
load(fullfile(spath,'files_01Sep2024.mat'),'newfiles');
sdat = split(newfiles,'\');
subjs = sdat(:,1);      % Subjects
visits = sdat(:,2);     % Visits (BASELINE or YEAR1)
atyp = sdat(:,3);       % Analysis TYPe (RHO or T2S)
csvnams = sdat(:,4);    % CSV file names
nfiles = size(subjs,1); % Number of files
%
% Loop through Files
%
% for kf = 1:nfiles
% for kf = 72:nfiles
%
% Subject 077 Year 1 meniscus files are index 68, 69, 70, and 71
%
% for kf = 68:71
for kf = [3 71]         % Subject 006 and the last CSV file of subject 077
%
% Get CSV File and Leg
%
   csvfile = csvnams{kf};
   csvleg = upper(csvfile(5));
%
% Get Subject Directory, Name and Number
%
   sdir = subjs{kf};    % Current subject directory
   subj = eval(sdir);   % Subject number
%
   spdir = fullfile(spath,sdir);       % Include series path
%
% Get Visit Directory and Full Path to MRI Data
%
   vdir = visits{kf};
%
   svpdir = fullfile(spdir,vdir);      % Include visit in series path
%
% Get Analysis Type for Series and Segmentations
%
   rdir = atyp{kf};     % Directory for segmentations
   if strcmpi(rdir,'RHO')
     id5m = 1;          % Use first spin lock time for plots
     mnamr = 'T1rho_S*.mat';
   else
     id5m = 4;          % Default echo time (5 ms) for segmentations
     mnamr = 'T2star_S*.mat';
   end
%
% Get MAT Files in Directory
%
   d = dir(fullfile(svpdir,mnamr));
   mnams = {d.name}';
   idr = contains(mnams,'roi','IgnoreCase',true);     % ROI files
   mnams = mnams(~idr);
   idr = contains(mnams,'chk','IgnoreCase',true);     % Check files
   mnams = mnams(~idr);
   nmat = size(mnams,1);
   if nmat<1
     error(' ERROR in seg_ame_rois:  No image MAT file found!');
   end
%
% Loop through MAT Files
%
   for m = 1:nmat
%
      mnam = mnams{m};
      mnam = fullfile(svpdir,mnam);
      load(mnam,'st');
%
% Parse Series Text for Leg
%
      leg = upper(st(1));
      if strcmp(leg,csvleg)
        load(mnam,'iszs','snt','v');
        break;
      end
   end                  % End of m loop - MAT file loop
%
% Get Series Number and Parse Series Text for Leg
%
   fs = ['S' snt];      % Series number prefaced with a 'S'
%
   if strcmpi(leg,'L')
     lstr = legs{1};
   else
     lstr = legs{2};
   end
%
% Get Segmentation File Name and Read ROIs
%
   segdir = fullfile(svpdir,rdir);     % Segmentation path
   rois = rd_roi6hp(fullfile(segdir,csvfile),true);
   nrois = size(rois,1);
%
% Get MRI Slices
%
   rsl = [rois.imageno]';
   rsl = unique(rsl);        % Ensure unique slices in sorted order
   nrsl = size(rsl,1);
%
% Loop through ROI Slices, Plot ROIs and Generate Masks for Each Slice
%
   pnam1 = fullfile(svpdir,[fs '_ame_ROIs1.ps']);     % ROI lines print file name
   pnam2 = fullfile(svpdir,[fs '_ame_ROIs2.ps']);     % ROI areas print file name
%
   mcoords = cell(nrsl,nrois);         % Meniscus coordinates
%
   iap = zeros(nrsl,nrois);            % -1 - anterior, 1 - posterior
   icmprt = zeros(nrsl,nrois);         % -1 - lateral, 1 - medial
   npxt = prod(iszs);                  % Total number of pixels in a slice
   maskm = false(npxt,nrsl,nrois);     % Masks for all meniscus segmentations
   masks = false(npxt,nrsl);           % Masks for meniscus slices
%
% Loop through Slices
%
   for k = 1:nrsl       % Loop through slices
%
% Get T1rho Slice Image
%
      slk = rsl(k);     % Slice number
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
      lh = gobjects(nrois,1);          % Line graphic handles
      idl = false(nrois,1);
      idxs = false(nlegds,1);
%
% Get ROI Data for this Slice and Plot ROIs
%
      for l = 1:nrois   % Loop through ROIs
         idxr = rois(l).imageno==slk;
         if any(idxr)
           mcoords(k,l) = rois(l).data(idxr);    % Meniscus coordinates
%
           snam = rois(l).name;        % Get ROI name
%
           if strcmpi(snam(1),'A')
             iap(k,l) = -1;            % -1 - anterior
           else
             iap(k,l) = 1;             % 1 - posterior
           end
           if strcmpi(snam(end-1),'L')
             icmprt(k,l) = -1;         % -1 - lateral
           else
             icmprt(k,l) = 1;          % 1 - medial
           end
%
% Create Logical Masks for this Slice
%
           maskm(:,k,l) = cr_maskm(mcoords{k,l},iszs);     % Masks for all segmentations
           masks(:,k) = masks(:,k)|maskm(:,k,l);           % Masks for slices
%
           idx = iap(k,l)+icmprt(k,l)/2+2.5;     % Index to legend entry
           idxs(idx) = true;
%
           lh(l) = plot(mcoords{k,l}(:,1),mcoords{k,l}(:,2),lt(idx,:));
           idl(l) = true;
         end            % End of if - any rois for this slice
      end               % End of rois (l) loop
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
      img1(maskms(:,iap(k,idl)==-1)) = dcmx;     % Blue - Anterior
      img1(maskms(:,iap(k,idl)==1)) = cmx-dcmx;  % Red - Posterior
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
   end                  % End of slices (k) loop
%
% Get Bounding Box for All Slices
%
   bbox = fnd_bbox(masks,iszs,ipad);
%
% Get Compartment Identifier for Slices
%
   idl = sum(icmprt,2)<0;    % Index to lateral slices
   rsll = rsl(idl);          % Lateral compartment slices
   nl = size(rsll,1);        % Number of lateral slices
   rslm = rsl(~idl);         % Medial compartment slices
   nm = size(rslm,1);        % Number of medial slices
%
% Get Compartment and AP Specific Masks
%
   maskml = maskm(:,idl,:);  % Masks for lateral slices
   maskmm = maskm(:,~idl,:); % Masks for medial slices
%
   idapl = sum(iap(idl,:));
   idal = idapl<0;                % Column index to anterior lateral masks
   if any(idal)
     maskmal = maskml(:,:,idal);  % Anterior lateral mask
   else
     maskmal = false(npxt,nl);    % Anterior lateral mask
   end
   idpl = idapl>0;                % Column index to posterior lateral masks
   if any(idpl)
     maskmpl = maskml(:,:,idpl);  % Posterior lateral mask
   else
     maskmpl = false(npxt,nl);    % Posterior lateral mask
   end
%
   idapm = sum(iap(~idl,:));
   idam = idapm<0;                % Column index to anterior medial masks
   if any(idam)
     maskmam = maskmm(:,:,idam);  % Anterior medial mask
   else
     maskmam = false(npxt,nm);    % Anterior medial mask
   end
   idpm = idapm>0;                % Column index to posterior medial masks
   if any(idpm)
     maskmpm = maskmm(:,:,idpm);  % Posterior medial mask
   else
     maskmpm = false(npxt,nm);    % Posterior medial mask
   end
%
% Get Compartment and AP Specific Meniscus Coordinates
%
   mcoordl = mcoords(idl,:);      % Meniscus coordinates for lateral slices
   mcoordm = mcoords(~idl,:);     % Meniscus coordinates for medial slices
%
   mcoordal = mcoordl(:,idal);    % Anterior lateral meniscus coordinates
   mcoordpl = mcoordl(:,idpl);    % Posterior lateral meniscus coordinates
%
   mcoordam = mcoordm(:,idam);    % Anterior medial meniscus coordinates
   mcoordpm = mcoordm(:,idpm);    % Posterior medial meniscus coordinates
%
% Save Masks, ROIS and Slice Information into MAT File
%
   savnam = [mnam(1:end-4) '_mrois.mat'];
   save(savnam,'bbox','cmprt','legs','maskmal','maskmam', ...
        'maskmpl','maskmpm','masks','mcoordal','mcoordam', ...
        'mcoordpl','mcoordpm','rsl','rsll','rslm');
%
   close all;
%
end                     % End of CSV file (kf) loop
%
return