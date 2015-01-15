function newind=addsymtree(params,ind)
%ADDSYMTREE    Extends selected individual by adding symbolic tree.
%       Using the function swapnodes de symbolic tree '1*1 + 1' is added
%       to the top node of the input individual.
%   Input arguments:
%      PARAMS - the parameters of the algorithm, they contain the sym tree (struct)
%      IND - Individual who will be extended. (struct)
%   Output arguments:
%      NEWIND - the newly created individual (struct)

x = 4; % mutation point: always the same point

% access symbolic tree from params array
newtree=params.symtree.tree;
% (the maximum size of the new branch is the same as the initial random trees)
% (0 means no exact level)

% swap old branch with new branch in only one step, as if this were
% crossover (but discard the resulting nind):
nind.tree = newtree;
ind.tree = swapnodes(nind.tree,ind.tree,x,1); % There is a crossover from original tree root node to the node x
ind.str = tree2str(ind.tree,1);

%ind.id=[];
%ind.origin='mutation';
%ind.parents=[pop(i).id];
%ind.xsites=[x];
%%
%MODDED
ind.str=tree2str(ind.tree,1);

%%
% ind.fitness=[];
% ind.adjustedfitness=[];
% ind.result=[];
% ind.testfitness=[];
% ind.testadjustedfitness=[];
ind.nodes=ind.tree.nodes;
% ind.introns=[];
% ind.level=[];

ind.extended=1;
%Tree has been extended for Local Search

newind = ind;