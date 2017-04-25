function feat = featurenegativevspositive(strFold)
% negatives: if you have a lot of negatives (similar number and
% strength to positives) that's probably an artefact AND general stats
% mean entropy (of nonzero voxels)
global icThreshold;
% system(sprintf('a=`fslstats %sfix/dummy -E`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy -E > %sfix/dummy1.txt', strFold, strFold));
feat(1) = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));

% system(sprintf('a=`fslstats %sfix/dummyabs -E`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummyabs -E > %sfix/dummy1.txt', strFold, strFold));
feat(2) = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));

% mean (for nonzero voxels)
% system(sprintf('a=`fslstats %sfix/dummy -M`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy -M > %sfix/dummy1.txt', strFold, strFold));
a = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));
% system(sprintf('a=`fslstats %sfix/dummy -S`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummy -S > %sfix/dummy1.txt', strFold, strFold));
aS = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));

% mean (for abs of nonzero voxels)
% system(sprintf('a=`fslstats %sfix/dummyabs -M`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummyabs -M > %sfix/dummy1.txt', strFold, strFold));
b = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));
% system(sprintf('a=`fslstats %sfix/dummyabs -S`; echo $a>%sfix/dummy1.txt', strFold, strFold));
call_fsl(sprintf('fslstats %sfix/dummyabs -S > %sfix/dummy1.txt', strFold, strFold));
bS = load(sprintf('%sfix/dummy1.txt', strFold));
delete(sprintf('%sfix/dummy1*', strFold));

feat(3) = abs(a)/(eps+abs(b));
feat(4) = abs(a*bS)/abs(eps+aS*b);

% diff (for abs of pos and neg voxels)
img = read_avw(sprintf('%sfix/dummy', strFold));
feat(5) = abs(sum(img(:)>0)-sum(img(:)<0))/(eps+sum(img(:)>0));
feat(6) = abs(sum(img(:)>icThreshold)-sum(img(:)<-icThreshold))/(eps+sum(img(:)>icThreshold));

end
