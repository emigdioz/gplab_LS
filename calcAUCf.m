function [AUCf,AUCf_neg,opt_th] = calcAUCf(ind,params,data,state,testdata)

res = ind.result;

[min_th, min_I] = min(res);
[max_th, max_I] = max(res);

if testdata
   GT = data.test.result;
else
   GT = data.result;
end

% Calculate full AUC
out_exp = res;
s_data = length(res);
sorted_data = sort(res);  % sorted evaluated tree
for i = 1:s_data
   predicted_v = zeros(length(res),1); % Clear vector
   predicted_v(out_exp<sorted_data(i)) = 2;  % All values less or equal than threshold assign Class 2
   predicted_v(out_exp>=sorted_data(i)) = 1;   % All values greater than threshold assign Class 1  
   % Calculate current TP & FP
   TP = predicted_v(GT == 1);
   TPv(i) = length(TP(TP == 1))/length(TP); % Normalize
   FP = predicted_v(GT == 2);
   FPv(i) = length(FP(FP == 1))/length(FP); % Normalize
   TN = predicted_v(GT == 2);
   TNv(i) = length(TN(TN == 1))/length(TN); % Normalize
   FN = predicted_v(GT == 1);
   FNv(i) = length(FN(FN == 1))/length(FN); % Normalize            
end
[FPv2,I] = sort(FPv);
TPv2 = TPv(I);
% Calculate also negative class
[FNv2,I] = sort(FNv);
TNv2 = TNv(I);

AUCf = sum(0.5.*(FPv2(2:s_data) - FPv2(1:(s_data-1))).*(TPv2(2:s_data) + TPv2(1:(s_data-1))));
AUCf_neg = sum(0.5.*(FNv2(2:s_data) - FNv2(1:(s_data-1))).*(TNv2(2:s_data) + TNv2(1:(s_data-1))));

% Calculate best threshold

%    for i=1:s_data
%       dist_v(i) = sqrt(((0 - FPv2(i)).^2) + ((1 - TPv2(i)).^2)); % Euclidian distance for each point
%    end
%    [opt_c_dist, I_optimum_classifier] = min(dist_v); % Minimum vector is the prefered threshold

for i=1:s_data
   angle_v(i) = angle_vector([0,1;1,0],[0,1;FPv2(i),TPv2(i)]);
end

[opt_c_angle, I_optimum_classifier] = min(angle_v); % Minimum vector is the prefered threshold
sampling = min_th:(max_th - min_th)/s_data:max_th; % Finer sampling
opt_th = sampling(I_optimum_classifier); 
