function features = featuretsjump(timeSeries)
% Some jump characteristics of the time series
diffTs = diff(timeSeries);
features(1) = max(abs(diffTs/(eps+std(timeSeries))));
features(2) = max(abs(diffTs/(eps+std(diffTs))));
features(3) = sum((diffTs/(eps+std(timeSeries))).^2)/length(timeSeries);

% from Russell Poldrack's 08; Feature 5
[mx, imx] = max(abs(diffTs));
sel = imx-2:imx+2;
sel(sel>length(diffTs)) = [];
sel(sel<1) = [];
diffTs(sel) = [];
features(4) = mx/(eps+mean(abs(diffTs)));
features(5) = mx/(eps+sum(abs(diffTs)));
    
% from Russell Poldrack's 08; Feature 6
timeSeries = timeSeries-mean(timeSeries);
b = corrcoef([timeSeries(1:end-1),timeSeries(2:end)]);
features(6) = b(2,1);
end
