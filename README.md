gplab_LS
=======

Introduction
------------
General implementation of local search over GPLAB focusing in symbolic regression and classification. This is also an improved GPLAB implementation. Focused on speed and new features.

GPLAB is a [matlab][mt] genetic programming toolbox. Developed by Sara Silva and collaborators. Original implementation can be found in `gplab repository` http://gplab.sourceforge.net/

The goal is to enrich the original gplab with the findings of our group. Some detailed information of our group can be found in http://www.tree-lab.org

Tested in Matlab 8.1 (2013a) 64bits (Linux & Windows)

New features
------------

New features will be listed below as soon as are implemented

- Parametrized tree structures for local optimum study
- Speed up on tree to string conversion routines (overall performance should be better)
- Local search for symbolic regression problems
- Preliminary local search for classification problems

Installation
------------

Just add gplab_LS to matlab paths and use it!

How to
------

New parameters:

`useLS = 1` if use function set with parameters, `useLS = 0` regular GPLAB.

`LSbest = 1` 1 if apply only to best individual per generation

`LSworst = 1` 1 if apply only to worst individual per generation

`LSprob = x` x probability to apply LS to the selected subpopulation (float number from 0 to 1)

`LSasc = 1` if subpopulation belongs to the best individuals, `LSasc = 0` worst individuals

`LSheuristic = 1` if a proportional population size criterion is used. `LSheuristic = 0` for not using it

`cpath = pwd` loads the train,test files from current path

`LSniter = x` x number of iterations used in optimization algorithm

`stop_by_funceval = 0` if stop condition is original GPLAB method. `stop_by_funceval = 1` if uses number of function evaluations sampling instead of generations

`funceval_limit = x` x function evaluations calls if above is on

`funceval_nsamples = x` x number of samples for history stats matrix. Use a higher value if you require a high resolution sampling

`LStype = 'regression'` if the problem to be solved is of the form symbolic regression. `LStype = 'classification'` if the problem is a classification problem. The logic involved for each one is different in the local search process


Matlab is a product of MathWorks.

[mt]: http://www.mathworks.com/products/matlab/
