function [cell,j]=gettreeparams(tree,cell,d,i,j)
%GETTREEPARAMETERS     Generates a cell containing the tree's parameter values.
%   GETTREEPARAMETERS (TREE,CELL,D,CON,I) returns the nodes where they are 
%   located as well as a string of the structure's address.  
%
if i ~= 0
    %
    i=num2str(i);
    %d=strcat(d,'.kids{1,',i,'}');
    d=[d '.kids{1,' num2str(i) '}'];
end
if isfield (tree,'param')
    if ~isempty(tree.param)
        cell{1}(1,j)=tree.param;
        cell{1}(2,j)=tree.nodeid;
        cell{2,j}=d;
        j=j+1;
    end
end
for k=1:length(tree.kids)
   [cell,j]=gettreeparams(tree.kids{k},cell,d,k,j);
end
