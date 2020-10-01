function feat = featuresmoothest(strFold)
% closely related: spatial smoothness (resel size etc) of zstat map
% spatial entropy (histogram) / parameters from histogram mixture-model fit    
% smoothness    
msk = sprintf('%smask',strFold);
call_fsl(sprintf('echo `smoothest -z %sfix/dummy -m %s` > %sfix/dummy1.txt', strFold, msk, strFold));        

fid = fopen(sprintf('%sfix/dummy1.txt', strFold));
%tline = fgetl(fid);
%C = textscan(tline, '%s %f %s %f %s %f');
feat = textscan(fid, 'DLH %*f VOLUME %*d RESELS %f');
feat = feat{1};
fclose(fid);

% DLH, VOL, RESEL
%feat = C{6};
delete(sprintf('%sfix/dummy1*', strFold));
end
