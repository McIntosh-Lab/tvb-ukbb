function features = featureoupjk(S, deltat)
% The Ornstein Uhlenbeck process is widely used for modelling a 
% mean-reverting process. The process S is modelled as
% dS = \lambda (\mu-S)dT + \sigma dW
% Where
% W is a Brownian- Motion, so dW~N(0, dt),
% \lambda meaures the speed of mean reversion
% \mu is the 'long run mean', to which the process tends to revert.
% \sigma, as usual, is a measure of the process volatility

% Since the basic ML has a bias (resulting in frequent estimates of 
% lambda which are much too high), we perform a 'jackknife' operation 
% to reduce the bias.

% Regressions prefer row vectors to column vectors, so rearrange if 
% necessary.
if (size(S,2) > size(S,1)), S = S'; end
m = 2; % Number of partitions
partlength = floor(length(S)/m); 
Spart = zeros(m,partlength); 
for i=1:1:m 
    Spart(i,:) = S(partlength*(i-1)+1:partlength*i); 
end
[muT, sigmaT, lambdaT ] = functionoupmle(S, deltat);

% Calculate the individual partitions. 
mupart = zeros(m,1); 
sigmapart = zeros(m,1); 
lambdapart= zeros(m,1); 
for i=1:1:m 
    [mupart(i), sigmapart(i), lambdapart(i)] = functionoupmle(Spart(i,:), deltat); 
end
% Now the jacknife calculation. 
lambda = (m/(m-1))*lambdaT - (sum(lambdapart))/(m^2-m); 
% mu and sigma are not biased, so there's no real need for the jackknife. 
% But we do it anyway for demonstration purposes. 
mu = (m/(m-1))*muT - (sum(mupart ))/(m^2-m); 
sigma = (m/(m-1))*sigmaT - (sum(sigmapart ))/(m^2-m);
features =  [sigma lambda];
end



