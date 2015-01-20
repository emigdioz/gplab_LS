function [vars,best,bloat,overfit]=gplab(g,varargin)
%GPLAB    Runs the GPLAB genetic programming algorithm.
%   GPLAB(NGENS,POPSIZE) initializes a GPLAB algorithm using
%   POPSIZE individuals, and runs it for NGENS generations
%   using default parameter variables. If NGENS=0 only the
%   initializations are done. It returns the algorithm
%   variables after the run.
%
%   GPLAB(NGENS,POPSIZE,PARAMS) uses previously set algorithm
%   parameters, PARAMS, instead of the default ones.
%
%   GPLAB(NGENS,VARS) continues a GPLAB run for NGENS generations,
%   starting from the point defined by the algorithm variables VARS.
%
%   [VARS,BEST] = GPLAB(...) also returns the best individual found
%   during the run, which is already part of the algorithm variables.
%
%   Input arguments:
%      NGENS - the number of generations to run the algorithm (integer)
%      POPSIZE - the number of individuals in the population (integer)
%      PARAMS - the algorithm running parameters (struct)
%      VARS - the algorithm variables (struct)
%        VARS.POP - the current population
%        VARS.PARAMS - the algorithm running parameters = PARAMS
%        VARS.STATE - the current state of the algorithm
%   Output arguments:
%      VARS - the algorithm variables (struct) - see Input arguments
%      BEST - the best individual found in the run (struct)
%
%   See also SETPARAMS, RESETPARAMS, RESETSTATE
%
%   --------------------------
%   See demo functions DEMO*
%   --------------------------
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox
global funcEvalC; % Global counter for function evaluations tracking
global vector_sampling; % Global sampling vector for function evaluations
global history_stats; % Global vector for fitness history when using function evaluations

if (nargin<2) || (nargin>3)
   error('GPLAB: Wrong number of input arguments. Use either gplab(ngens,vars) to continue a run, or gplab(ngens,popsize,[optional params]) to start a run')   
   
elseif isstruct(varargin{1})
   % argument 1: the number of additional generations to run
   % argument 2: the algorithm variables
   if ~(is_valid(g,'posint'))
      error('GPLAB: The first argument must be an integer greater than 0.')
   end
   start=0;
   continuing=1;
   vars=varargin{1};
   n=vars.state.popsize;
   level=vars.state.maxlevel;
   ginic=vars.state.generation+1; % start generation number
   gend=ginic-1+g; % end generation number
   
else
   % argument 1: the number of generations to run
   % argument 2: the number of individuals in the population
   % argument 3: (optional) the parameters of the algorithm
   if ~(is_valid(g,'special_posint') && is_valid(varargin{1},'posint') && varargin{1}>=2)
      error('GPLAB: The first two arguments must be integers, and the second > 1')
   end
   start=1;
   continuing=0;
   n=varargin{1};
   if nargin==3
      vars.params=varargin{2};
   else
      vars.params=[];
   end
   vars.state=[];
   vars.data=[];
   ginic=1; % start generation number
   gend=g; % end generation number
end

% check parameter variables:
vars.params=checkvarsparams(start,continuing,vars.params,n);

% check data variables:
[vars.data,vars.params]=checkvarsdata(start,continuing,vars.data,vars.params);

% check state variables:
[vars.state,vars.params]=checkvarsstate(start,continuing,vars.data,vars.params,vars.state,n,g);

% initialize random number generator (see help on RAND):
rand('state',sum(100*clock));

%% Construct sampling vector in case of function evaluations stop criteria
if vars.params.stop_by_funceval
   fprintf('\nUsing stop criteria by number of function evaluations\n');
   span_sample = vars.params.funceval_limit/vars.params.funceval_nsamples;   
   vector_sampling = 1:span_sample:vars.params.funceval_limit;
   history_stats = zeros(length(vector_sampling),6);
   history_stats(:,1) = vector_sampling';
   funcEvalC = 0;
end

%%
%construct symbolic tree:
%Form: +( * (x,1) , 1) or x * 1 + 1
vars.params.symtree=constsymtree(vars.params,vars.state);
%Adds tree struct to params for future use.

%Generate params for Optimization use...
%Type of parametrization.......

%%

fprintf('\nRunning algorithm...\n');

% initiate graphics:
% (if we're not going to run generations or draw history, don't initiate the graphics)
if ~isempty(vars.params.graphics) && (ginic<=gend || continuing) 
   gfxState=graphicsinit(vars.params);
end


% initial generation:

if start
   [vars.pop,vars.state]=genpop(vars.params,vars.state,vars.data,n);
   if strcmp(vars.params.savetofile,'firstlast') || strcmp(vars.params.savetofile,'every10') || strcmp(vars.params.savetofile,'every100') || strcmp(vars.params.savetofile,'always')
      saveall(vars);
   end
   if ~strcmp(vars.params.output,'silent')
      fprintf('     #Individuals:  %d\n',vars.state.popsize);
      if strcmp(vars.params.survival,'resources')
	fprintf('     MaxResources:  %d\n',vars.state.maxresources);
      end
      fprintf('     UsedResources: %d\n',vars.state.usedresources);
      fprintf('     Best so far:   %d\n',vars.state.bestsofar.id);
      fprintf('     Fitness:       %f\n',vars.state.bestsofar.fitness);
      if vars.params.usetestdata
         fprintf('     Test fitness:  %f\n',vars.state.bestsofar.testfitness);
      end
      fprintf('     Depth:         %d\n',vars.state.bestsofar.level);
      fprintf('     Nodes:         %d\n\n',vars.state.bestsofar.nodes);
   end
   % (if we're not going to run generations, don't start the graphics:)
   if ~isempty(vars.params.graphics) && ginic<=gend
      gfxState=graphicsstart(vars.params,vars.state,gfxState);
   end
end

if continuing
   if ~isempty(vars.params.graphics)
      gfxState=graphicscontinue(vars.params,vars.state,gfxState);
   end
end

sc=0;



%%% datos de la generacion cero para medir Bloat
program_size_0=vars.state.avgnodeshistory;
avg_fitness_0=vars.state.avgfitness;
bloat=[];

%%% datos de la generacion cero para Overfitting
btp=vars.state.bestsofar.testfitness;
tbtp=vars.state.bestsofar.fitness;
overfit=[];
test_fit=[];
training_fit=[];

%%% Datos de completjidad
complexity=[];
complexity2=[];


 % generations:  
for i=ginic:gend
   
   % stop condition?
   if vars.params.stop_by_funceval
      if funcEvalC > vector_sampling(end)
         break; %stop condition
      end
   else
      sc=stopcondition(vars.params,vars.state,vars.data);
      if sc
         % unless the option is to never save, save the algorithm variables now:
         if (~strcmp(vars.params.savetofile,'never'))
            saveall(vars);
         end
         break % if a stop condition has been reached, skip the for cycle
      end
   end
   % new generation:
   [vars.pop,vars.state]=generation(vars.pop,vars.params,vars.state,vars.data);
   
   
   % Calcular datos para bloat
   program_size=vars.state.avgnodeshistory(vars.state.generation+1);
   avg_fitness= vars.state.fithistory(vars.state.generation+1,3);  
   bloat(i)=((program_size - program_size_0)/program_size_0)/((avg_fitness_0-avg_fitness)/avg_fitness_0);
   
   
   % Calcular overfitting
   test_fit(i)=vars.state.bestsofar.testfitness;
   training_fit(i)=vars.state.bestsofar.fitness;
       
   
   if training_fit(i) > test_fit(i)
       overfit(i)=0;
   else
       if test_fit(i) < btp
           overfit(i)=0;
           btp=test_fit(i);
           tbtp=training_fit(i);
       else
           overfit(i)=abs(training_fit(i) - test_fit(i)) - abs(tbtp-btp);
       end
   end
   
   
   % Calcular complexity
%    partial_complex=[];
%    partial_complex2=[];
% 
%    for jj=1:size(vars.data.example,2)
%        Data=vars.data.example(:,jj);
%        [Sorted,IX]=sort(Data);
%        
%        response=vars.state.bestsofar.result(IX);
%        
%        response = exposc3(response,2.1,1,10,{'ls'});
%        partial_complex(jj)=median(response);
%        partial_complex2(jj)=mean(response);
%    end
%    
%    complexity(i)=median(partial_complex);
%    complexity2(i)=mean(partial_complex);
   
   
   % save to file?
   if (strcmp(vars.params.savetofile,'firstlast') && i==g) || (strcmp(vars.params.savetofile,'every10') && rem(i,10)==0) || (strcmp(vars.params.savetofile,'every100') && rem(i,100)==0) || strcmp(vars.params.savetofile,'always')
      saveall(vars);
   end
   
   % textual output:
   if ~strcmp(vars.params.output,'silent')
      fprintf('     #Individuals:  %d\n',vars.state.popsize);
      if strcmp(vars.params.survival,'resources')
	fprintf('     MaxResources:  %d\n',vars.state.maxresources);
      end
      fprintf('     UsedResources: %d\n',vars.state.usedresources);
      fprintf('     Best so far:   %d\n',vars.state.bestsofar.id);
      fprintf('     Best so far string: %s\n',vars.state.bestsofar.str);      
      fprintf('     Fitness:       %f\n',vars.state.bestsofar.fitness);
      if vars.params.usetestdata
         fprintf('     Test fitness:  %f\n',vars.state.bestsofar.testfitness);
      end
      fprintf('     Depth:         %d\n',vars.state.bestsofar.level);
      fprintf('     Nodes:         %d\n\n',vars.state.bestsofar.nodes);
   end
   if vars.params.stop_by_funceval
      fprintf('     Number of function evaluations so far:   %d\n',funcEvalC);
   end
   % plots:
   if ~isempty(vars.params.graphics)
      gfxState=graphicsgenerations(vars.params,vars.state,gfxState);
   end 
      
end % for i=ginic:gend


% messages regarding the stop condition reached:

if vars.params.stop_by_funceval
   fprintf(['\n' num2str(vector_sampling(end)) ' function evaluations have been done. Stopping run. ' num2str(vars.state.generation) ' generations\n']);
else
   if sc
      if vars.state.generation==0
         fprintf('\nStop condition #%d was reached after initial generation.\n',sc);      
      else
         fprintf('\nStop condition #%d was reached after generation %d.\n',sc,vars.state.generation);
      end
   else
      fprintf('\nMaximum generation %d was reached.\n',vars.state.generation);
   end      
end

best=vars.state.bestsofar;
best.history_stats = history_stats;
vars.state.keepevals=[]; % clear memory, we don't want to save all this!

fprintf('\nDone!\n\n');
