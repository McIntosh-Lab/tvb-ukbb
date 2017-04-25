function features = featuremasktscorrandoverlap(strFold, timeSeries, imgSeg, timeSeriesCsf, timeSeriesGm, timeSeriesWm)

% In this function, given the time series, the mean CSF time-series is
% estimated and then its correlation with the given ts is calc'd
% Next, the overlap of spatial map w/each and everyone of these masks is
% estimated

global icThreshold;

features = regress(timeSeries/(eps+std(timeSeries)), [ones(size(timeSeries)) timeSeriesWm/(eps+std(timeSeriesWm)), timeSeriesGm/(eps+std(timeSeriesGm)), timeSeriesCsf/(eps+std(timeSeriesCsf))]);
features = abs(features(2:end));

imgIc = read_avw(sprintf('%sfix/dummyabs', strFold));
denom = eps+sum(imgIc(:));
features(4) = sum(imgIc(:).*(imgSeg(:)==1))/denom;
features(5) = sum(imgIc(:).*(imgSeg(:)==2))/denom;
features(6) = sum(imgIc(:).*(imgSeg(:)==3))/denom;

imgIc = imgIc>icThreshold;
denom = eps + sum(imgIc(:));
features(7) = sum(imgIc(:).*(imgSeg(:)==1))/denom;
features(8) = sum(imgIc(:).*(imgSeg(:)==2))/denom;
features(9) = sum(imgIc(:).*(imgSeg(:)==3))/denom;

imgIc = read_avw(sprintf('%sfix/dummyabs', strFold));
wch = imgIc>icThreshold;
denom = eps+sum(imgIc(wch));
features(10) = sum(imgIc(wch).*(imgSeg(wch)==1))/denom;
features(11) = sum(imgIc(wch).*(imgSeg(wch)==2))/denom;
features(12) = sum(imgIc(wch).*(imgSeg(wch)==3))/denom;

end
