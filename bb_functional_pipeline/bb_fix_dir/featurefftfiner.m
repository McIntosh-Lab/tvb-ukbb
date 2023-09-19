function features = featurefftfiner(timeSeries, TR, threshArray)
% In this function, given the time series and its sampling rate (e.g,
% TR), we calculate the ratio of its high-frequency energy to low-frequency
% energy
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
features = features/(eps+sum(features));
end

