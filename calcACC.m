function [ACC] = calcACC(ind,data,testdata)
global optimum_classifier_th;
res = ind.result;
if testdata
   GT = data.test.result;
else
   GT = data.result;
end
predicted_v = zeros(length(res),1); % Clear vector
predicted_v(res<optimum_classifier_th) = 2;  % All values less or equal than threshold assign Class 2
predicted_v(res>=optimum_classifier_th) = 1;   % All values greater than threshold assign Class 1  
TP = predicted_v(GT == 1);
TP = length(TP(TP == 1));
FP = predicted_v(GT == 2);
FP = length(FP(FP == 1));
FN = predicted_v(GT == 1);
FN = length(FN(FN == 2));
TN = predicted_v(GT == 2);
TN = length(TN(TN == 2));
ACC = (TP + TN)/(TP + TN + FP + FN);
