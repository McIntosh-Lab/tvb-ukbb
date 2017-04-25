function features = featurefftfinerwrtnull(timeSeries, TR, threshArray)
% % Concolve single-gamma HRF w/WGN and compare its spectrum w/actual RSN 
% do it for real
L = length(timeSeries); % Length of signal
nFFT = 2^nextpow2(L); % Next power of 2 from length of S
Y = abs(fft(timeSeries, nFFT)/L);
f = ((1/TR)/2)*linspace(0,1,nFFT/2);
Y = Y(1:length(f));

features = zeros(1,length(threshArray));
for i = 1:(length(threshArray)-1)
    features(i) = sum(Y(f>threshArray(i) & f<=threshArray(i+1)));
end
features(i+1) = sum(Y(f>threshArray(i+1)));
featuresReal = features;
% do it under the H0
delay = 6/TR; 
sigma = delay/2;
hrf = gampdf(0:(size(timeSeries,1)-1), (delay/sigma)^2, delay/(sigma^2));
featuresNull = features*0;
for i = 1:100
    y = randn(length(timeSeries),1);
    y = conv(y,hrf);
    y = y(1:length(timeSeries));    
    y = y/std(y);
    yFft = abs(fft(y, nFFT)/L);
    yFft = yFft(1:length(f));
    for j = 1:(length(threshArray)-1)
        features(j) = sum(yFft(f>threshArray(j) & f<=threshArray(j+1)));
    end
    features(j+1) = sum(yFft(f>threshArray(j+1)));    
    featuresNull = featuresNull + features;
end
featuresNull = featuresNull/100;
features = (featuresReal-featuresNull).^2./(eps+(featuresReal.^2));
features = [features sum(features)];
end

