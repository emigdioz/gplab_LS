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

GPLAB parameters:

| Name | Type | Default | Description |
|:-----|:----:|:-------:|-------------|
| useLS | Bool | 0 | 1 if use LS algorithm. 0 if use regular GPLAB |
| LSbest | Bool | 1 | 1 if apply only to best individual per generation |
| LSworst | Bool | 0 | 1 if apply only to worst individual per generation |
| LSprob | Real | 1 | [0~1] Probability to apply LS to the selected subpopulation |
| LSasc | Bool | 1 | 1 if subpopulation belongs to the best individuals. 0 for the worst individuals |
| LSheuristic | Bool | 0 | 1 if a proportional population criterion is used to apply LS |
| cpath | String | pwd | Loads the train, test files from current path |
| LSniter | Integer | 400 | Number of iterations used in optimization algorithm |
| stop_by_funceval | Bool | 0 | 1 if uses number of function evaluations sampling instead of generations |
| funceval_limit | Integer | 1000000 | Function evaluation calls until evolution stops, if above is on |
| funceval_nsamples | Integer | 100 | Number of samples for history stats matrix |
| LStype | String | regression | If the problem to be solved is of the form symbolic regression. 'classification' if the problem is a classification problem. The logic involved for each one is different in the local search process |

**Matlab is a product of MathWorks.**

[mt]: http://www.mathworks.com/products/matlab/
