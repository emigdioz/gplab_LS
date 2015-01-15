function tree=returnmatrix(tree,cell)
%RETURN MATRIX
%
%
nparams=size(cell);
for k=1:nparams(2)
    temp_tree=setfield(eval(cell{2,k}),'param',cell{1,1}(1,k));
    newtree=swapnodes(tree,temp_tree,cell{1,1}(2,k),1);
    tree=newtree;
end
