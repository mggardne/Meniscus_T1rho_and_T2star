%
s = load('Results\mri_mes_fit.mat');
%
s.t1r_nps(ks,:,:,:) = t1r_nps(ks,:,:,:);
s.t1r_npx(ks,:,:,:) = t1r_npx(ks,:,:,:);
s.t1r_res(ks,:,:,:) = t1r_res(ks,:,:,:);
s.t1r_respx(ks,:,:,:) = t1r_respx(ks,:,:,:);
s.t1r_rss(ks,:,:,:) = t1r_rss(ks,:,:,:);
s.t1r_rsspx(ks,:,:,:) = t1r_rsspx(ks,:,:,:);
%
t1r_nps = s.t1r_nps;
t1r_npx = s.t1r_npx;
t1r_res = s.t1r_res;
t1r_respx = s.t1r_respx;
t1r_rss = s.t1r_rss;
t1r_rsspx = s.t1r_rsspx;
%
matnam = fullfile(resdir,'mri_mes_fit.mat');
save(matnam,'t1r_res','t1r_npx','t1r_rss','t1r_respx', ...
     't1r_rsspx','t1r_nps','-append');
%
return