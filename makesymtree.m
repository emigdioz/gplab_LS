function [tree,lastnode]=makesymtree(level,oplist,oparity,exactlevel,depthnodes,inicparamvalue,lastnode)

%MAKESYMTREE    Creates representation tree for the GPLAB algorithm.
%   MAKETREE(MAXLEVEL,OPERATORS,ARITY,EXACTLEVEL,DEPTHNODES,LASTNODE)
%   creates a random tree no deeper than MAXLEVEL (or with no
%   more nodes than MAXLEVEL, depending on parameter DEPTHNODES)
%   using the available OPERATORS with arity ARITY. If EXACTLEVEL
%   is true, the tree level will be exactly MAXLEVEL in depth
%   (or close to it in number of nodes).
%
%   Additional input parameter (not set in the first call)
%   is LASTNODE, the id of the last node created in the tree.
%
%   Additional output argument (essential in recursiveness)
%   is LASTNODE, the id of the last node created in the tree.
%
%   Input arguments:
%      MAXLEVEL - the maximum depth or size of the new tree (integer)
%      OPERATORS - the available functions and terminals (cell array)
%      ARITY - the arity of the operators, in numeric format (array)
%      EXACTLEVEL - whether the new tree is exactly MAXLEVEL (boolean)
%      DEPTHNODES - '1' (limit depth) or '2' (limit nodes) (char)
%      LASTNODE - the id of the last node created in the tree (integer)
%   Output arguments:
%      TREE - the new random tree (struct)
%      LASTNODE - the id of the last node created in the tree (integer)
%
%   Notes:
%      MAKETREE is a recursive function.
%
%   See also NEWIND, TREELEVEL, NODES
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

if ~strcmp(depthnodes,'1') && ~strcmp(depthnodes,'2')
   error('MAKETREE: must specify limit on depth or nodes.')
end

if ~exist('lastnode')
   lastnode = 0; 
end
thisnode = lastnode+1;

if level==1
   % we must choose a terminal because of the level limitation
   % (whether it's depth or number of nodes)
   f=find(oparity==0); % f gives all indices of terminals
   if isempty(f)
      error('RAND generated 0.0000! Possible cause: no terminals (including variables) available.')
   end
   ind=intrand(1,size(f,2)); % choose one at random
   op=f(ind);
   
else
    if thisnode == 1
        tree.op='plus';
        a=2;
    elseif thisnode == 2
        tree.op='times';
        a=2;
    elseif thisnode == 3
        tree.op='par';
        a=0;
        if inicparamvalue == 1
            tree.param=1;
        else
            tree.param=rand(1,1);
        end
    elseif thisnode == 4
        tree.op='par';
        a=0;
        if inicparamvalue == 1
            tree.param=1;
        else
            tree.param=rand(1,1);
        end
    elseif thisnode == 5
        tree.op='par';
        a=0;
        if inicparamvalue == 1
            tree.param=1;
        else
            tree.param=rand(1,1);
        end
    end
end


% check for terminals to evaluate now - only example right now is 'rand':

%if (oplist{op,2}==0) & (~strncmp(oplist{op,1},'X',1))
%   % IF YOU CHANGE 'X', ALSO CHANGE IN CHECKVARSSTATE
%   % if it's a terminal (but not a variable), evaluate it now
%   t=eval(oplist{op,1});
%   if isstr(t)
%      tree.op=t;
%   else
%      tree.op=num2str(t);
%   end
%else
%   tree.op=oplist{op,1};
%end

% old version: when there was only "rand"
% going back to the  old version...
% if op < 0
%     tree.op='1';
% else
%     if strcmp(oplist{op,1},'rand')
%         r=rand;
%         tree.op=num2str(r);
%     else
%         tree.op=oplist{op,1};
%     end
% end
%%Aqui convierten la localidad del operador en la operacion...


% generate branches:

tree.kids=[];
tree.nodeid=thisnode;

% if there is a next branch, define level limitation for it:
% if (op < 0)
%     a = 0;
% else
%     a=oplist{op,2}; % a = arity of the chosen op
% end
if a~=0
   level=level-1; % discount the node (or depth level) just used
   if strcmp(depthnodes,'2') % if limiting nodes, try to balance the tree
      splitnodes=round(level/a); % distribute remaining places between kids
   end
end

% now generate branches (if a>0, ie, non terminal) with new level limitation:
for i=1:a
   if strcmp(depthnodes,'2')
      % make sure to use all places (because of round, last branch uses the rest)
   	if i==a
      	newlevel=level-(splitnodes*(a-1)); % remaining places
   	else
      	newlevel=splitnodes;
      end
   else
      newlevel=level;
   end
   [t,lastnode] = makesymtree(newlevel,oplist,oparity,exactlevel,depthnodes,inicparamvalue,thisnode);
   tree.kids{i} = t;
   thisnode = lastnode+1;
end

tree.nodes = thisnode-tree.nodeid+1;
tree.maxid = lastnode+1;