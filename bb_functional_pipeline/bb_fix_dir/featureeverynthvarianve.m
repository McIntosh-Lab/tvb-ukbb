function feat = featureeverynthvarianve(strFold)
% all-of-a-single-slice and none-of-others or every odd (or even) slices -
% effects; the above also tend to show up as VERY sparse or oddly  
% nonGaussian in time domain (this is like F4 in Podrack 08)
global icThreshold;
% % 
img = read_avw(sprintf('%sfix/dummyabs', strFold));
for i = 1:size(img,3), 
    imgS = squeeze(img(:,:,i)); 
    varSlc(i) = sum((imgS(:).^2)); 
end
feat(1) = abs(sum(varSlc(1:2:size(img,3)))-sum(varSlc(2:2:size(img,3))))/(eps+sum(varSlc));
% 
AA = [1:4:size(img,3) 2:4:size(img,3)];
BB = [3:4:size(img,3) 4:4:size(img,3)];
feat(2) = abs(sum(varSlc(AA))-sum(varSlc(BB)))/(eps+sum(varSlc));
% % 
img = img.*(img>icThreshold);
for i = 1:size(img,3), 
    imgS = squeeze(img(:,:,i)); 
    varSlc(i) = var(imgS(:)); 
end
feat(3) = abs(sum(varSlc(1:2:size(img,3)))-sum(varSlc(2:2:size(img,3))))/(eps+sum(varSlc));
% 
AA = [1:4:size(img,3) 2:4:size(img,3)];
BB = [3:4:size(img,3) 4:4:size(img,3)];
feat(4) = abs(sum(varSlc(AA))-sum(varSlc(BB)))/(eps+sum(varSlc));
end

