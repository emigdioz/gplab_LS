function [str, n_pars]=treePar(tree,n_pars)
%TREEPAR    Takes a given tree and adds parameters to its string.
%   TREEPAR(TREE) returns string with parameters
%   in valid Matlab notation, ready for optimization.
%
%   Input arguments:
%      TREE - the tree to process (struct)
%   Output arguments:
%      STRING - the string respresented by the tree (string)
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
str=tree.op;
temp_str=num2str(n_pars);
str=strcat('par(',temp_str,')*',str);
n_pars=n_pars+1;

args=[];
for k=1:length(tree.kids)
   [args{k},n_pars]=treePar(tree.kids{k},n_pars);
end
if ~isempty(args)
   str = [str '(' implode(args,',') ')'];
end
