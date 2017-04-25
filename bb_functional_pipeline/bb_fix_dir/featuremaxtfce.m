function feat = featuremaxtfce(strFold)
% test for "clusterness" / "compactness" - e.g. feed through TFCE and 
% take the max (maybe pre-TFCE normalise e.g. by max(abs(z)))
global icThreshold;

% old version
% system(sprintf('fslmaths %sfix/dummy -abs -div `fslstats %sfix/dummy -a -P 99` -tfce 2 .5 6 %sfix/dummy2', strFold, strFold, strFold));
% new version
call_fsl(sprintf('fslmaths %sfix/dummy -abs -div `fslstats %sfix/dummy -S` -tfce 2 .5 6 %sfix/dummy2', strFold, strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy2 -P 100 > %sfix/dummy2.txt', strFold, strFold));
feat(1) = load(sprintf('%sfix/dummy2.txt', strFold));
delete(sprintf('%sfix/dummy2*', strFold));
    
call_fsl(sprintf('fslmaths %sfix/dummy -abs -tfce 2 .5 6 %sfix/dummy2', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy2 -P 100 > %sfix/dummy2.txt', strFold, strFold));
feat(2) = load(sprintf('%sfix/dummy2.txt', strFold));
delete(sprintf('%sfix/dummy2*', strFold));

% system(sprintf('fslmaths %sfix/dummy -abs -thr 3 -tfce 2 .5 6 %sfix/dummy2', strFold, strFold));
call_fsl(sprintf('fslmaths %sfix/dummy -abs -thr %f -tfce 2 .5 6 %sfix/dummy2', strFold, icThreshold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy2 -P 100 > %sfix/dummy2.txt', strFold, strFold));
feat(3) = load(sprintf('%sfix/dummy2.txt', strFold));
delete(sprintf('%sfix/dummy2*', strFold));

end
