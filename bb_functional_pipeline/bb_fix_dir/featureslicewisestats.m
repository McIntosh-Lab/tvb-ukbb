function feat = featureslicewisestats(strFold)
% all-of-a-single-slice and none-of-others or every odd (or even) slices -
% effects; the above also tend to show up as VERY sparse or oddly  
% nonGaussian in time domain 
global icThreshold;
img = read_avw(sprintf('%sfix/dummyabs', strFold));
sumTot = sum(img(:).^2)+eps;
for i = 1:size(img,3)
    imgS = squeeze(img(:,:,i));
    sumSlc(i) = sum(imgS(:).^2)/sumTot;
end
feat(1) = sum(sumSlc>.15);
feat(2) = max(sumSlc);

sumTot = sum(img(:)>icThreshold)+eps;
for i = 1:size(img,3)
    imgS = squeeze(img(:,:,i));
    sumSlc(i) = sum(imgS(:)>icThreshold)/sumTot;
end
feat(3) = sum(sumSlc>.15);
feat(4) = max(sumSlc);
end
