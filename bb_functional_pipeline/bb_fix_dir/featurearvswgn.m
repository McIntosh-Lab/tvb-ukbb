function features = featurearvswgn(timeSeries, TR)
% this function calculates the AR-based features for the melodic time series.

%timeSeries = iddata(timeSeries,[], TR);
%for i = 1:6
%    [m, ~] = ar(timeSeries, i); 
%    mvec(i) = m.NoiseVariance;
%end

for i = 1:6
    [grotAR,grotV] = aryule(timeSeries, i); 
    mvec(i) = grotV;
end

features = polyfit(1:6, mvec, 1);

end

