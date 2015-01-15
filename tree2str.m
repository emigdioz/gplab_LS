function [str, con]=tree2str(tree,con)
%TREE2STR    Translates a GPLAB algorithm tree into a string.
%   TREE2STR(TREE) returns the string represented by the tree,
%   in valid Matlab notation, ready for evaluation.
%
%   Input arguments:
%      TREE - the tree to translate (struct)
%   Output arguments:
%      STRING - the string respresented by the tree (string)
%
%   See also MAKETREE
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

if strcmp(tree.op,'par')
    if isfield (tree,'param')
        temp_str=num2str(con);
        str=strcat('par(',temp_str,')');
        con=con+1;
    end
else
    
    str=tree.op;
    %is field checks for a parameter in the node's location
    %if a parameter is found, then 'param' is added to the string
    if isfield (tree,'param')
        if ~isempty(tree.param)
            temp_str=num2str(con);
            str=strcat('par(',temp_str,')*',str);
            con=con+1;
        end
    end
end

args=[];
for k=1:length(tree.kids)
   [args{k},con]=tree2str(tree.kids{k},con);
end
if ~isempty(args)
   str = [str '(' implode(args,',') ')'];
end
