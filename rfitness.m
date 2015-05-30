function ind=rfitness(ind,params,data,state,varsvals,testdata)
%REGFITNESS    Measures the fitness of a GPLAB individual.
%   REGFITNESS(INDIVIDUAL,PARAMS,DATA,TERMINALS,VARSVALS) returns
%   the fitness of INDIVIDUAL, measured as the sum of differences
%   between the obtained and expected results, on DATA dataset, and
%   also returns the result obtained in each fitness case.
%
%   Input arguments:
%      INDIVIDUAL - the individual whose fitness is to measure (struct)
%      PARAMS - the current running parameters (struct)
%      DATA - the dataset on which to measure the fitness (struct)
%      TERMINALS - the variables to set with the input dataset (cell array)
%      VARSVALS - the string of the variables of the fitness cases (string)
%   Output arguments:
%      INDIVIDUAL - the individual whose fitness was measured (struct)
%
%   See also CALCFITNESS, ANTFITNESS
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   Acknowledgements: Marco Medori (marco.medori@poste.it) and Bruno Morelli
%   This file is part of the GPLAB Toolbox

global funcEvalC; % Global counter for function evaluations tracking
global vector_sampling; % Global sampling vector for function evaluations
global history_stats;

X=data.example;
outstr=ind.str;

if testdata   % load data to workspace for fast processing
   load(params.test_variables);
else
   load(params.train_variables);
end

%Parameter extraction for evaluation purposes.
c_param=cell(2,1);
%First, inicialize a cell to store parameters
c_param=gettreeparams(ind.tree,c_param,'tree',0,1);
%Parameter extraction function

nparams=size(c_param);
%Obtain number of parameters carried by individual.
par=zeros(nparams(2),1);
%Generate parameter matrix
if(~isempty(c_param{1,1}))
   for k=1:nparams(2)
       par(k)=c_param{1,1}(1,k);
       %Fill matrix with parameter values
   end
end

%%
    
try    
    res=eval(outstr);    
catch
    % because of the "nesting 32" error of matlab
    res=str2num(evaluate_tree(ind.tree,X));
end

%for t=1:params.numvars
   %for all variables (which are first in input list), ie, X1,X2,X3,...
%   var=terminals{t,1};
%   val=varsvals{t}; % varsvals was previously prepared to be assigned (in genpop)
%   eval([var '=' val ';']);
   % (this eval does assignments like X1=2,X2=4.5,...)
%end
   
% evaluate the individual and measure difference between obtained and expected results:
%res=eval(ind);

% if the individual is just a terminal, res is just a scalar, but we want a vector:
if length(res)<length(data.result)
   res=res*ones(length(data.result),1);
end

sumdif=mean((res-data.result).^2);
%sumdif=mean(abs(res-data.result));

ind.result=res;

% raw fitness:
ind.fitness=sumdif; %lower fitness means better individual
% now limit fitness precision, to eliminate rounding error problem:
ind.fitness=fixdec(ind.fitness,params.precision);

%% Now begins function evaluations checking
if params.stop_by_funceval
   funcEvalC = funcEvalC + 1;
   if funcEvalC < vector_sampling(end) % Check only vor valid indexes
      if ~isempty(find(vector_sampling==funcEvalC))
         index_v = find(vector_sampling==funcEvalC);
         % Output statistics
         if ~isempty(state.bestsofar)
            if ~isempty(state.bestsofar.fitness)
               history_stats(index_v,2) = state.bestsofar.fitness;
            end
            if ~isempty(state.bestsofar.testfitness)
               history_stats(index_v,3) = state.bestsofar.testfitness;
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
