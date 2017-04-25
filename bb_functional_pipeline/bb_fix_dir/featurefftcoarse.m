function features = featurefftcoarse(timeSeries, TR, freqThreshold)
% In this function, given the time series and its sampling rate (e.g,
% TR), we calculate the ratio of its high-frequency energy to low-frequency
% energy
L = length(timeSeries); % Length of signal
nFFT = 2^nextpow2(L); % Next power of 2 from length of S
Y = abs(fft(timeSeries, nFFT)/L);
f = ((1/TR)/2)*linspace(0,1,nFFT/2);
Y = Y(1:length(f));
features = sum(Y(f>=freqThreshold))/(eps+sum(Y(f<freqThreshold)));
% features = sum(Y(f>=freqThreshold))/(sum(Y)+eps);
end

