function newind=constsymtree(params,state)
%CONSTRUCT SYM TREE    Creates a new custom made symbolic tree.
%   NEWIND=CONSTSYMTREE(POPULATION,PARAMS,STATE,PARENT) returns a new individual
%   created by substituting a random subtree of PARENT by a new
%   randomly created tree, with the same depth/size restrictions
%   as the initial random trees.
%
%   Input arguments:
%      POPULATION - the population where the parent is (array)
%      PARAMS - the parameters of the algorithm (struct)
%      STATE - the current state of the algorithm (struct)
%      PARENT - the index of the parent in POPULATION (integer)
%   Output arguments:
%      NEWIND - the newly created individual (struct)
%
%   See also CROSSOVER, APPLYOPERATOR
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

%ind=pop(i);


% build a new branch for this tree, no deeper/bigger than the initial random trees:
% (and obeying the depth/size restrictions imposed by the limits in use)
%newtree=maketree(state.iniclevel,state.functions,state.arity,0,state.depthnodes,xnode.nodeid-1);
newtree = makesymtree(state.iniclevel,state.functions,state.arity,0,params.depthnodes,params.inicparamvalue);
% (the maximum size of the new branch is the same as the initial random trees)
% (0 means no exact level)

% swap old branch with new branch in only one step, as if this were
% crossover (but discard the resulting nind):
ind.tree = newtree;
%ind.tree=swapnodes(nind.tree,ind.tree,x,1);%El cruce se hace del nodo superior del arbol original con nodo x de sym
%ind.tree=swapnode(ind.tree,x,newtree);

ind.id = [];
ind.origin = 'custom';
ind.xsites = [];
[temp_str,con]=tree2str(ind.tree,1);
ind.str=temp_str;
ind.fitness=[];
ind.adjustedfitness=[];
ind.result=[];
ind.testfitness=[];
ind.testadjustedfitness=[];
ind.nodes=ind.tree.nodes;
ind.introns=[];
ind.level=[];

newind=ind;