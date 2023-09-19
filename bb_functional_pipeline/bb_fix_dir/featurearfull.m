function features = featurearfull(timeSeries, TR, nOrder)
% this function calculates the AR-based features for the melodic time series

if(nargin<3), nOrder = 1; end

%timeSeries = iddata(timeSeries,[], TR);
%[m, ~] = ar(timeSeries, nOrder);    
%features = [m.NoiseVariance; m.ParameterVector];

[grotAR,grotV] = aryule(timeSeries, nOrder);
features = [grotV grotAR(2:end)];

end

