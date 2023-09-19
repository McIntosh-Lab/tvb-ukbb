function feat = featureedgemasks(strFold)
% compare high zstat voxels against original EPI mean image intensities 
% (in some artefacts the mean FMRI image is dark)
% Similar to above - compare zstat against original EPI *edge* image  
% and/or the original PCA residual image
global icThreshold;

feat = [];
for i = 1:5
    imgMaskEdge = read_avw(sprintf('%sedge%d',[strFold 'fix/'],i));
    
    imgIc = abs(read_avw(sprintf('%sfix/dummy', strFold)))>icThreshold;
    whatPercentOnEdgeB = sum(imgIc(:).*imgMaskEdge(:))/(eps+sum(imgIc(:)));
    whatPercentOfEdge = sum(imgIc(:).*imgMaskEdge(:))/(eps+sum(imgMaskEdge(:)));
    
    imgIc = read_avw(sprintf('%sfix/dummyabs', strFold));
    wch = imgIc(:)>icThreshold;
    whatPercentOnEdgeC = sum(imgIc(wch).*imgMaskEdge(wch))/(eps+sum(imgIc(wch)));
    
    feat = [feat whatPercentOnEdgeB whatPercentOnEdgeC whatPercentOfEdge]; %#ok<AGROW>
end

return


