function feat = featuresagmasks(strFold)
% look at intersections of ICA spatial map with major vein mask images
global icThreshold;

imgIc2 = read_avw(sprintf('%sfix/dummyabs', strFold));
imgIc = imgIc2>icThreshold;
wch = imgIc2(:)>icThreshold;

feat = [];
for i = 0:3
    imgMaskEdge = read_avw(sprintf('%sfix/std1mm2exfunc%d',strFold,i));
    whatPercentOnEdgeB = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgIc(:)));
    whatPercentOfEdge  = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgMaskEdge(:)));
    whatPercentOnEdgeC = sum(imgIc2(wch).*imgMaskEdge(wch))/max(1,sum(imgIc2(wch)));
    grot1=corrcoef([imgMaskEdge(:) imgIc(:) imgIc2(:)]); grot1(isnan(grot1))=0;
    grot2=corrcoef([imgMaskEdge(wch) imgIc2(wch)]); grot2(isnan(grot2))=0;
    feat = [feat whatPercentOnEdgeB whatPercentOnEdgeC whatPercentOfEdge grot1(1,2:3) grot2(1,2)];
    
    imgMaskEdge = read_avw(sprintf('%sfix/std1mm2exfunc%ddil',strFold,i));
    whatPercentOnEdgeB = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgIc(:)));
    whatPercentOfEdge  = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgMaskEdge(:)));
    whatPercentOnEdgeC = sum(imgIc2(wch).*imgMaskEdge(wch))/max(1,sum(imgIc2(wch)));
    grot1=corrcoef([imgMaskEdge(:) imgIc(:) imgIc2(:)]); grot1(isnan(grot1))=0;
    grot2=corrcoef([imgMaskEdge(wch) imgIc2(wch)]); grot2(isnan(grot2))=0;
    feat = [feat whatPercentOnEdgeB whatPercentOnEdgeC whatPercentOfEdge grot1(1,2:3) grot2(1,2)];
    
    imgMaskEdge = read_avw(sprintf('%sfix/std1mm2exfunc%ddil2',strFold,i));
    whatPercentOnEdgeB = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgIc(:)));
    whatPercentOfEdge  = sum(imgIc(:).*imgMaskEdge(:))/max(1,sum(imgMaskEdge(:)));
    whatPercentOnEdgeC = sum(imgIc2(wch).*imgMaskEdge(wch))/max(1,sum(imgIc2(wch)));
    grot1=corrcoef([imgMaskEdge(:) imgIc(:) imgIc2(:)]); grot1(isnan(grot1))=0;
    grot2=corrcoef([imgMaskEdge(wch) imgIc2(wch)]); grot2(isnan(grot2))=0;
    feat = [feat whatPercentOnEdgeB whatPercentOnEdgeC whatPercentOfEdge grot1(1,2:3) grot2(1,2)];
end

return

