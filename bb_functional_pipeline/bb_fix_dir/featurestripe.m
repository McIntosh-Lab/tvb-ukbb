function feat = featurestripe(strFold)
call_fsl(sprintf('fslmaths %sfix/dummy -s 2 -abs %sfix/dummy01', strFold, strFold));
call_fsl(sprintf('fslmaths %sfix/dummy -abs -s 2 -sub %sfix/dummy01 -abs %sfix/dummy01', strFold, strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy01 -P 95 > %sfix/dummy01', strFold, strFold));
feat = dlmread(sprintf('%sfix/dummy01', strFold));
delete(sprintf('%sfix/dummy0*', strFold));
end
