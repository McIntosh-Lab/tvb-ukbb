function feat = featurezstattofuncratio(strFold)
% compare high zstat voxels against original EPI mean image intensities 
% (in some artefacts the mean FMRI image is dark)
% Similar to above - compare zstat against original EPI *edge* image  
% and/or the original PCA residual image
% global icThreshold;
meanepi = sprintf('%smean_func',strFold);
call_fsl(sprintf('fslmaths %sfix/dummy -s 5 -abs -div %s %sfix/dummyd', strFold, meanepi, strFold));
call_fsl(sprintf('fslmaths %sfix/dummy -s 5 -abs -mul %s %sfix/dummym', strFold, meanepi, strFold));
imgRatio = read_avw(sprintf('%sfix/dummyd',strFold)); % ratio image
imgMultiple = read_avw(sprintf('%sfix/dummym',strFold)); % multiple image

% if(~exist(sprintf('%smasknew.nii.gz',[strFold 'fix/']),'file'))
%     system(sprintf('fslmaths %smask.nii.gz -ero -ero %smasknew2.nii.gz',...
%         strFold, [strFold 'fix/']));
%     system(sprintf('fslmaths %smask.nii.gz -sub %smasknew2.nii.gz %smasknew',...
%         strFold,[strFold 'fix/'], [strFold 'fix/']));
% end
% imgMaskEdge = read_avw(sprintf('%smasknew',[strFold 'fix/']));
% imgIc = abs(read_avw(sprintf('%sfix/dummy', strFold)))>icThreshold;
% whatPercentOnEdgeB = sum(imgIc(:).*imgMaskEdge(:))/(eps+sum(imgIc(:)));
% whatPercentOfEdge = sum(imgIc(:).*imgMaskEdge(:))/(eps+sum(imgMaskEdge(:)));

a = (~isnan(imgMultiple(:))) & (~isinf(imgMultiple(:)));
dummyMultiplePos = imgMultiple((imgMultiple(:)>0) & a );

a = (~isnan(imgRatio(:))) & (~isinf(imgRatio(:)));
dummyRatioPos = imgRatio((imgRatio(:)>0) & a );

% imgIc = read_avw(sprintf('%sfix/dummyabs', strFold));
% wch = imgIc(:)>icThreshold;
% whatPercentOnEdgeC = sum(imgIc(wch).*imgMaskEdge(wch))/(eps+sum(imgIc(wch)));

feat = [ ...
%     whatPercentOnEdgeB whatPercentOnEdgeC whatPercentOfEdge ...
    prctile(dummyMultiplePos,99) prctile(dummyMultiplePos,95) ...
    prctile(dummyRatioPos,99) prctile(dummyRatioPos,95) ...
    ];
end
