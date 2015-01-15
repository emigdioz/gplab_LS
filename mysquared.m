function y=mysquared(x1)
%MYSQUARED    Protected power function.
%   MYSQUARED(X1) returns 0 if X1^2 is NaN or Inf, 
%   or has imaginary part, otherwise returns X1^2.
%
%   Input arguments:
%      X1 - the base of the power function (double)
%   Output arguments:
%      Y - the power X1^2, or 0 (double)
%


y=x1.^2;
y(find(isnan(y) | isinf(y) | imag(y)))=0;
%y(find(isnan(y) || isinf(y) || ~isreal(y)))=0;
