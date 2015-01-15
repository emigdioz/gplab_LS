function result = treeObj(par,xdata)
%% 
% Function evaluation for optimization, just pass trough the tree string with
% initial parameters to be able to optimize. best_str is global variable
% coming from the tree to be evaluated
global strEval;
global span_interval;
global optimum_classifier_th;
global type_function;

load(xdata);
str = strEval;

if type_function == 1
   result = eval(str);
else
   res = eval(str);
   sig_f = 1./(1+exp((15./span_interval).*(res-optimum_classifier_th)));
   result = sig_f;
end

