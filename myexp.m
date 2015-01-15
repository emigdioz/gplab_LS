function y = myexp(x)
%MYEXP    Protected EXP function

if x>700
   y = exp(700);
else
   y = exp(x);
end