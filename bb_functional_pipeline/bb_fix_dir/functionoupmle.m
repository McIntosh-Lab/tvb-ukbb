function [ mu, sigma, lambda ] = functionoupmle(S, deltat)
% The Ornstein Uhlenbeck process is widely used for modelling a 
% mean-reverting process. The process S is modelled as
% dS = \lambda (\mu-S)dT + \sigma dW
% Where
% W is a Brownian- Motion, so dW~N(0, dt),
% \lambda meaures the speed of mean reversion
% \mu is the 'long run mean', to which the process tends to revert.
% \sigma, as usual, is a measure of the process volatility



% Regressions prefer row vectors to column vectors, so rearrange if necessary.
if (size(S,2) > size(S,1)), S = S'; end

n = length(S)-1; 
Sx = sum( S(1:end-1) ); 
Sy = sum( S(2:end) ); 
Sxx = sum( S(1:end-1).^2 ); 
Sxy = sum( S(1:end-1).*S(2:end) ); 
Syy = sum( S(2:end).^2 ); 

mu = (Sy*Sxx - Sx*Sxy) / ( n*(Sxx - Sxy) - (Sx^2 - Sx*Sy) ); 
lambda = -(1/deltat)*...
    log((Sxy - mu*Sx - mu*Sy + n*mu^2) / (Sxx -2*mu*Sx + n*mu^2)); 

alpha = exp(- lambda*deltat); 
alpha2 = exp(-2*lambda*deltat); 
sigmahat2 = (1/n)*(Syy - 2*alpha*Sxy + alpha2*Sxx - ... 
    2*mu*(1-alpha)*(Sy - alpha*Sx) + n*mu^2*(1-alpha)^2); 

sigma = sqrt(sigmahat2*2*lambda/(1-alpha2));



end

