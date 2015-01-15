function y=mycubic(x1)
%MYCUBIC    Protected cubic function.
%   MYCUBIC(X1) returns 0 if X1^3 is NaN or Inf, 
%   or has imaginary part, otherwise returns X1^3.
%
%   Input arguments:
%      X1 - the base of the power function (double)
%   Output arguments:
%      Y - the power X1^3, or 0 (double)
%


y=x1.^3;
y(find(isnan(y) | isinf(y) | imag(y)))=0;
%y(find(isnan(y) || isinf(y) || ~isreal(y)))=0;
