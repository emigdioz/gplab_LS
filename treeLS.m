function [state,pop] = treeLS(params,state,data,pop,index,type)
%TREELS    Optimizes a parametrized tree by means of non-linear method.
%          In this case uses the Trust Region method.
%   TREELS(TREE) returns the string and the optimized parameters
%
%   Input arguments:
%      IND   - individual in GPLAB form (struct)
%      XDATA - input training/testing data
%      YDATA - output training/testing data
%      NITER - number of iterations for the optimizer (default 400)
%   Output arguments:
%      STR   - the string respresented by the tree (string)
%      PARS  - optimized parameters in case that everything was succesful
%
% www.tree-lab.org
% Copyright (C) 2014 Emigdio Z.Flores
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%%
global strEval;
global span_interval;
global optimum_classifier_th;
global type_function;
global funcEvalC; % Global counter for function evaluations tracking
global vector_sampling; % Global sampling vector for function evaluations
global history_stats; % Global vector for fitness history when using function evaluations


original_fitness = pop(index).fitness; % Record original fitness

AUC_full = false; % Compute full AUC or partial
verbose = false; % Print partial results
plot_calculations = false; % Plot partial calculations

strEval = pop(index).str;
if strcmp(type,'classification')
   type_function = 2;
elseif strcmp(type,'regression')
   type_function = 1;
else
   fprintf('Unknown method for LS calculation. Aborting individual\n');
   return;
end

if type_function==2 % Classification stage
   
   res = pop(index).result;
   [min_th, min_I] = min(res); % Minimum threshold
   [max_th, max_I] = max(res); % Maximum threshold

   if(min_th==max_th) % Avoid doing any calculation when vector is the same
      return;
   end
   if AUC_full
      % Calculate full AUC
      s_data = length(res);
      sorted_data = sort(res);  % sorted evaluated tree
      for i = 1:s_data
         predicted_v = zeros(length(res),1); % Clear vector
         predicted_v(res<sorted_data(i)) = 2;  % All values less or equal than threshold assign Class 2
         predicted_v(res>=sorted_data(i)) = 1;   % All values greater than threshold assign Class 1  
         % Calculate current TP & FP
         TP = predicted_v(data.result == 1);
         TPv(i) = length(TP(TP == 1))/length(TP); % Normalize
         FP = predicted_v(data.result == 2);
         FPv(i) = length(FP(FP == 1))/length(FP); % Normalize
         TN = predicted_v(data.result == 2);
         TNv(i) = length(TN(TN == 1))/length(TN); % Normalize
         FN = predicted_v(data.result == 1);
         FNv(i) = length(FN(FN == 1))/length(FN); % Normalize            
      end
      [FPv2,I] = sort(FPv);
      TPv2 = TPv(I);
      % Calculate also negative class
      [FNv2,I] = sort(FNv);
      TNv2 = TNv(I);

      AUCf_ori = sum(0.5.*(FPv2(2:s_data) - FPv2(1:(s_data-1))).*(TPv2(2:s_data) + TPv2(1:(s_data-1))));
      AUCf_ori_neg = sum(0.5.*(FNv2(2:s_data) - FNv2(1:(s_data-1))).*(TNv2(2:s_data) + TNv2(1:(s_data-1))));

      % Calculate best threshold
      for i=1:s_data
         angle_v(i) = angle_vector([0,1;1,0],[0,1;FPv2(i),TPv2(i)]);
      end
      [opt_c_angle, I_optimum_classifier] = min(angle_v); % Minimum vector is the prefered threshold
      sampling = min_th:(max_th - min_th)/s_data:max_th; % Finer sampling
      optimum_classifier_th = sampling(I_optimum_classifier); 

      % Calculate Acc before doind optimization (for optimum threshold only)
      predicted_v = zeros(length(res),1); % Clear vector
      predicted_v(res<optimum_classifier_th) = 2;  % All values less or equal than threshold assign Class 2
      predicted_v(res>=optimum_classifier_th) = 1;   % All values greater than threshold assign Class 1  
      TP = predicted_v(data.result == 1);
      TP = length(TP(TP == 1));
      FP = predicted_v(data.result == 2);
      FP = length(FP(FP == 1));
      FN = predicted_v(data.result == 1);
      FN = length(FN(FN == 2));
      TN = predicted_v(data.result == 2);
      TN = length(TN(TN == 2));
      ACC1 = (TP + TN)/(TP + TN + FP + FN);
   else
      % Calculate partial AUC
      nsamples = 10;
      sampling = min_th:(max_th - min_th)/nsamples:max_th;
      for i = 1:(nsamples+1)
         predicted_v = zeros(length(res),1); % Clear vector
         predicted_v(res<sampling(i)) = 2;  % All values less or equal than threshold assign Class 2
         predicted_v(res>=sampling(i)) = 1;   % All values greater than threshold assign Class 1  
         % Calculate current TP & FP
         TP = predicted_v(data.result == 1);
         TPv(i) = length(TP(TP == 1))/length(TP); % Normalize
         FP = predicted_v(data.result == 2);
         FPv(i) = length(FP(FP == 1))/length(FP); % Normalize
         TN = predicted_v(data.result == 2);
         TNv(i) = length(TN(TN == 1))/length(TN); % Normalize
         FN = predicted_v(data.result == 1);
         FNv(i) = length(FN(FN == 1))/length(FN); % Normalize                     
      end
      [FPv2,I] = sort(FPv);
      TPv2 = TPv(I);
      AUCp_ori = sum(0.5.*(FPv2(2:nsamples+1) - FPv2(1:nsamples)).*(TPv2(2:nsamples+1) + TPv2(1:nsamples)));

      % Calculate best threshold
      for i=1:(nsamples+1)
         angle_v(i) = angle_vector([0,1;1,0],[0,1;FPv2(i),TPv2(i)]);
      end
      [opt_c_angle, I_optimum_classifier] = min(angle_v); % Minimum vector is the prefered threshold
      optimum_classifier_th = sampling(I_optimum_classifier); 

      % Calculate ACC (for optimum threshold only)
      predicted_v = zeros(length(res),1); % Clear vector
      predicted_v(res<optimum_classifier_th) = 2;  % All values less or equal than threshold assign Class 2
      predicted_v(res>=optimum_classifier_th) = 1;   % All values greater than threshold assign Class 1  
      TP = predicted_v(data.result == 1);
      TP = length(TP(TP == 1));
      FP = predicted_v(data.result == 2);
      FP = length(FP(FP == 1));
      FN = predicted_v(data.result == 1);
      FN = length(FN(FN == 2));
      TN = predicted_v(data.result == 2);
      TN = length(TN(TN == 2));
      ACC1 = (TP + TN)/(TP + TN + FP + FN);
   end
   
   if plot_calculations
      clf;
      % Plot ROC before optimization
      subplot(3,2,1);
      plot(FPv,TPv,'color',([255 127 14]./255),'linewidth',2);
      xlabel('FP');
      ylabel('TP');
      title('ROC (before LS)');
      hold on;
      plot(FPv2(I_optimum_classifier),TPv2(I_optimum_classifier),'bx');
      axis square;
      subplot(3,2,2);
      plot(FNv,TNv,'color',([255 127 14]./255),'linewidth',2);
      xlabel('FN');
      ylabel('TN');
      title('ROC');
      axis square;
   end
   
   xdata = data.example;
   ydata = data.result;
   target_v = zeros(length(res),1);
   target_v(ydata==2) = 1; % Create target vector in order to do regression
   dist_from_th(1) = abs(optimum_classifier_th - min_th); % Check distances from middle to max and min
   dist_from_th(2) = abs(optimum_classifier_th - max_th);

   span_interval = 2*max(dist_from_th); % Choose as new interval 2*max distance from
                                        % middle to frontiers

   % Create sigmoid function                                     
   nsamples = 255;                                   
   sampling = (optimum_classifier_th - max(dist_from_th)):...
      span_interval/nsamples:(optimum_classifier_th + max(dist_from_th)); % Fine sampling
   sig_f = 1./(1+exp((15./span_interval).*(res-optimum_classifier_th)));
   sig_ideal = 1./(1+exp((15./span_interval).*(sampling-optimum_classifier_th)));
   
   if plot_calculations
      % Plot before optimization
      subplot(3,2,5);
      plot(sampling,sig_ideal,'color',([230 230 230]./255),'linewidth',4);
      hold on;
      plot(res(data.result==2),sig_f(data.result==2),'.','color',([214 39 40]./255)); % Class 2
      hold on;
      plot(res(data.result==1),sig_f(data.result==1),'.','color',([31 119 180]./255)); % Class 1
      legend('Sig function','Class 2','Class 1');
      hold on;
      line([optimum_classifier_th optimum_classifier_th],[0 1],...
           'color',([255 127 14]./255),'LineWidth',2);
      hold on;
      plot(res(data.result==2),target_v(data.result==2),'.','color',([236 149 149]./255)); % Class 2     
      hold on;
      plot(res(data.result==1),target_v(data.result==1),'.','color',([150 201 237]./255)); % Class 1     
      title('Before optimization...');
   end
end
if type_function==1 % Regression stage
   target_v = data.result;   
end
% Important! save optimum_classifier_th & span_interval to reuse in fitness
% function after individual has been optimized
pop(index).optimum_classifier_th = optimum_classifier_th;
pop(index).span_interval = span_interval;

%%
c_param=cell(2,1);
%First, inicialize a cell to store parameters
c_param=gettreeparams(pop(index).tree,c_param,'tree',0,1);
%Parameter extraction function

nparams=size(c_param);
%Obtain number of parameters carried by individual.
x0=zeros(nparams(2),1);
%Generate parameter matrix
for k=1:nparams(2)
    x0(k)=c_param{1,1}(1,k);  %Fill matrix with parameter values
end
% Update parameter array
pop(index).parameters = x0; % If not changed after, it keeps updated anyway

niter = params.LSniter;
%niter = 1000;
options = optimset('Display','off','MaxIter',niter);

%lb = [-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000,-1000];
%ub = [1000,1000,1000,1000,1000,1000,1000,1000,1000,1000];

try
   [x,resnorm,residual,exitflag,output] = lsqcurvefit(@treeObj,x0,params.train_variables,target_v,[],[],options);
   
   temp_ind = pop(index);
   temp_ind.parameters = x;
   % evaluate fitness with optimized parameters
   %Return parameters to tree...
   %FIRST.. Replace cell with new values
   for k=1:nparams(2)
       c_param{1,1}(1,k) = x(k);
   end
   temp_ind.tree = returnmatrix(temp_ind.tree,c_param);
   
   % Recalculate again fitness to update individual
   individual_m = calcfitness(temp_ind,params,data,state,0); 

   if(individual_m.fitness == original_fitness)
      fprintf('=');
   end
   if(individual_m.fitness > original_fitness)
      fprintf('-'); % In case ACC is bigger
   end
   if(individual_m.fitness < original_fitness)
      fprintf('+');
      pop(index).fitness = individual_m.fitness;
      pop(index).adjustedfitness = individual_m.adjustedfitness;
      pop(index).result = individual_m.result;
      pop(index).tree = temp_ind.tree;
      pop(index).parameters = temp_ind.parameters;
      
      if type_function==2 % Classification stage
         sig_f_opt = 1./(1+exp((15./span_interval).*(pop(index).result-optimum_classifier_th)));

         if AUC_full
            % Calculate again ROC and AUCf
            out_exp = pop(index).result;
            sorted_data = sort(pop(index).result);  % sorted evaluated tree
            for i = 1:s_data
               predicted_v = zeros(length(pop(index).result),1); % Clear vector
               predicted_v(out_exp<sorted_data(i)) = 2;  % All values less or equal than threshold assign Class 2
               predicted_v(out_exp>=sorted_data(i)) = 1;   % All values greater than threshold assign Class 1  
               % Calculate current TP & FP
               TP_new = predicted_v(data.result == 1);
               TPv(i) = length(TP_new(TP_new == 1))/length(TP_new); % Normalize
               FP_new = predicted_v(data.result == 2);
               FPv(i) = length(FP_new(FP_new == 1))/length(FP_new); % Normalize
               TN_new = predicted_v(data.result == 2);
               TNv(i) = length(TN_new(TN_new == 2))/length(TN_new); % Normalize
               FN_new = predicted_v(data.result == 1);
               FNv(i) = length(FN_new(FN_new == 2))/length(FN_new); % Normalize            
            end
            [FPv2,I] = sort(FPv);
            TPv2 = TPv(I);
            % Calculate also negative class
            [FNv2,I] = sort(FNv);
            TNv2 = TNv(I);

            AUCf_opt = sum(0.5.*(FPv2(2:s_data) - FPv2(1:(s_data-1))).*(TPv2(2:s_data) + TPv2(1:(s_data-1))));
            AUCf_opt_neg = sum(0.5.*(FNv2(2:s_data) - FNv2(1:(s_data-1))).*(TNv2(2:s_data) + TNv2(1:(s_data-1))));
         else
            for i = 1:(nsamples+1)
               predicted_v = zeros(length(res),1); % Clear vector
               predicted_v(res<sampling(i)) = 2;  % All values less or equal than threshold assign Class 2
               predicted_v(res>=sampling(i)) = 1;   % All values greater than threshold assign Class 1  
               % Calculate current TP & FP
               TP_new = predicted_v(data.result == 1);
               TPv(i) = length(TP_new(TP_new == 1))/length(TP_new); % Normalize
               FP_new = predicted_v(data.result == 2);
               FPv(i) = length(FP_new(FP_new == 1))/length(FP_new); % Normalize
            end
            [FPv2,I] = sort(FPv);
            TPv2 = TPv(I);
            AUCp_opt = sum(0.5.*(FPv2(2:nsamples+1) - FPv2(1:nsamples)).*(TPv2(2:nsamples+1) + TPv2(1:nsamples)));
         end
         % Calculate ACC after optimization
         predicted_v_opt = zeros(length(res),1); % Clear vector
         predicted_v_opt(sig_f_opt<0.5) = 1;  
         predicted_v_opt(sig_f_opt>=0.5) = 2;
         TP_opt = predicted_v_opt(data.result == 1);
         TP_opt = length(TP_opt(TP_opt == 1));
         FP_opt = predicted_v_opt(data.result == 2);
         FP_opt = length(FP_opt(FP_opt == 1));
         FN_opt = predicted_v_opt(data.result == 1);
         FN_opt = length(FN_opt(FN_opt == 2));
         TN_opt = predicted_v_opt(data.result == 2);
         TN_opt = length(TN_opt(TN_opt == 2));

         ACC2 = (TP_opt + TN_opt)/(TP_opt + TN_opt + FP_opt + FN_opt);
         %fprintf(['Internal fitness: ' num2str(1-ACC2) '\n']);
         % Update fitness
         %pop(index).fitness = 1 - ACC2;

         if plot_calculations
            % Plot after optimization
            subplot(3,2,6);
            plot(sampling,sig_ideal,'color',([230 230 230]./255),'linewidth',4);
            hold on;
            plot(pop(index).result(data.result==2),sig_f_opt(data.result==2),'.','color',([214 39 40]./255)); % Class 2
            hold on;
            plot(pop(index).result(data.result==1),sig_f_opt(data.result==1),'.','color',([31 119 180]./255)); % Class 1
            legend('Sig function','Class 2','Class 1');
            hold on;
            line([optimum_classifier_th optimum_classifier_th],[0 1],...
                 'color',([255 127 14]./255),'LineWidth',2);
            hold on;   
            plot(pop(index).result(data.result==2),target_v(data.result==2),'.','color',([236 149 149]./255)); % Class 2     
            hold on;
            plot(pop(index).result(data.result==1),target_v(data.result==1),'.','color',([150 201 237]./255)); % Class 1          
            title('After optimization...'); 
            subplot(3,2,3);
            plot(FPv,TPv,'color',([255 127 14]./255),'linewidth',2);
            xlabel('FP');
            ylabel('TP');
            title('ROC (after LS)');
            axis square;
            subplot(3,2,4);
            plot(FNv,TNv,'color',([255 127 14]./255),'linewidth',2);
            xlabel('FN');
            ylabel('TN');
            title('ROC');
            axis square;
            drawnow;
         end
         if verbose
            fprintf('--------------------------------------------------------\n');
            if AUC_full
               fprintf(['AUCf before optimization = ' num2str(AUCf_ori) '\n']);      
               fprintf(['AUCf after optimization = ' num2str(AUCf_opt) '\n']);      
            else
               fprintf(['AUCp before optimization = ' num2str(AUCp_ori) '\n']);      
               fprintf(['AUCp after optimization = ' num2str(AUCp_opt) '\n']);      
            end
            fprintf(['ACC before optimization = ' num2str(ACC1) '\n']);
            fprintf(['ACC after optimization = ' num2str(ACC2) '\n']); 
            fprintf(['TP before optimization = ' num2str(TP) '/' num2str(sum(data.result == 1)) '\n']); 
            fprintf(['TP after optimization = ' num2str(TP_opt) '/' num2str(sum(data.result == 1)) '\n']); 
            fprintf(['TN before optimization = ' num2str(TN) '/' num2str(sum(data.result == 2)) '\n']); 
            fprintf(['TN after optimization = ' num2str(TN_opt) '/' num2str(sum(data.result == 2)) '\n']);       
         end
      else
         if params.usetestdata % Regression stage
            testindividual=calcfitness(state.bestsofar,params,data.test,state,1); % (1 = test data)   
            state.bestsofar.testfitness=testindividual.fitness;
         end
      end
   end
catch
   output.funcCount = 1;
   output.iterations = 1;
   fprintf(['        ' char(187) 'Individual %d fitness is too big -> Inf\n'],index);
end

%% Now begins function evaluations checking
if params.stop_by_funceval
   for i=1:(output.funcCount+output.iterations)      
      funcEvalC = funcEvalC + 1;
      if funcEvalC < vector_sampling(end)
         if ~isempty(find(vector_sampling==funcEvalC))
            index_v = find(vector_sampling==funcEvalC);
            % Output statistics
            if ~isempty(state.bestsofar)
               if ~isempty(state.bestsofar.fitness)
                  history_stats(index_v,2) = state.bestsofar.fitness;
               end
               if params.usetestdata
                  if ~isempty(state.bestsofar.testfitness)
                     history_stats(index_v,3) = state.bestsofar.testfitness;
                  end
               end
               if ~isempty(state.bestsofar.AUCf_opt)
                  history_stats(index_v,4) = state.bestsofar.AUCf_opt;
               end
               if ~isempty(state.bestsofar.nodes)          
                  history_stats(index_v,5) = state.bestsofar.nodes;
               end
               if state.generation > 0
                  history_stats(index_v,6) = state.avgnodeshistory(state.generation);   
               end
            end
         end
      end
   end
end

