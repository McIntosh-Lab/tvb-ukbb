function features = featuremotioncorrelation(timeSeries, strFold)
% calculate the time series' correlation w/motion

thecwd=pwd;
cd(strFold);
[grot,TR]=call_fsl('fslval filtered_func_data pixdim4'); TR=str2num(TR);
[grot,hp]=system('[ -f design.fsf ] && [ _`grep fmri\(temphp_yn\) design.fsf | awk ''{print $3}''` = _1 ] && grep fmri\(paradigm_hp\) design.fsf | awk ''{print $3}''');
hp=str2num(hp);
if grot==1
  hp=0;
end
confounds = functionmotionconfounds(TR,hp);
cd(thecwd);

TSS=confounds;

%C1 = corrcoef([timeSeries TSS ]);
%C2 = corrcoef([timeSeries gradient(TSS')']);
%features(1) = max(abs(C1(1,2:end)));
%features(2) = max(abs(C2(1,2:end)));
%features(3) = max(features);

C1 = corrcoef([timeSeries TSS ]);   % TSS already contains the derivatives
C1 = abs(C1(1,2:end));
features(1) = max(C1(1:6));
features(2) = max(C1(7:end));
features(3) = max(features);

%regModel = regress(timeSeries/(eps+std(timeSeries)), [ones(size(timeSeries)) TSS]);
regModel = pinv([ones(size(timeSeries)) TSS],1e-6)*timeSeries/(eps+std(timeSeries));

regModel = sort(abs(regModel(2:end)));
features(4:6) = [regModel(end-1:end); mean(regModel(floor(end/2):end))];
end

