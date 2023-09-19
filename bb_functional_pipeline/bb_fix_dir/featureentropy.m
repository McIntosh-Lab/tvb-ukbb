function features = featureentropy(S)
[X, ~] = hist(S, linspace(-2,2,floor(sqrt(length(S)))));
X = X/sum(X);
features(1) = -sum( X.*log(X+eps) );

%features(2) = mean(S.^3)^2/12-kurtosis(S)^2/48;       % old broken estimate of negentropy
%features(2) = mean(S.^3)^2/12+(kurtosis(S)-3)^2/48;   % corrected but crap estimate of negentropy
S=S(:)/(std(S(:))+eps); features(2)=sum( (mean(-exp(-S.^2/2))+0.71).^2 );   % better-conditioned estimate of negentropy

end

