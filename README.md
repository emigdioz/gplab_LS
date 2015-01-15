gplab_z
=======

Introduction
------------

This is an improved GPLAB implementation. Focused on speed and new features. GPLAB is a [matlab][mt] genetic programming toolbox. Developed by Sara Silva and collaborators. Original implementation can be found in `gplab repository` http://gplab.sourceforge.net/

The goal is to enrich the original gplab with the findings of our group. Some detailed information of our group can be found in http://www.tree-lab.org

Tested in Matlab 8.1 (2013a) 64bits (Linux & Windows)

New features
------------

New features will be listed below as soon as are implemented

- Parametrized tree structures for local optima study
- Speed up on tree to string conversion routines (overall performance should be better)

Installation
------------

Just add gplab_z to matlab paths and use it! Original functionality is intact

How to
------

New parameters:

`useLS = 1` if use function set with parameters, `useLS = 0` regular GPLAB. Change the parameter `setfunctions` to include parameter, example: `setfunctions(p,'parameter(1)*plus',2,'parameter(2)*times',2)`

`LSbest = 1` 1 if apply only to best individual per generation

`LSworst = 1` 1 if apply only to worst individual per generation

`LSprob = x` x probability to apply LS to the selected subpopulation (float number from 0 to 1)

`LSmaxind = x` x population percentage to apply LS (float number from 0 to 1)

`LSasc = 1` 1 choose over the best individuals and 0 over the worst individuals


`initialparfile = 'filename'` if above is set to 1, define the initial parameter file for each variable

`cpath = pwd` loads the train,test files from current path

`stopfitness = x` if set, process will stop when reached desired fitness even if there are generations to compute

`stopfitnesscall = x` number of function evaluations to trigger the algorthm stop. Use a high number of generations


Matlab is a product of MathWorks.

[mt]: http://www.mathworks.com/products/matlab/
