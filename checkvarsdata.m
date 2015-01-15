function [data,params]=checkvarsdata(start,continuing,data,params);
%CHECKVARSDATA    Fills the dataset variable for the GPLAB algorithm.
%   CHECKVARSDATA(START,CONTINUE,DATA,PARAMS) returns the dataset
%   on which the GPLAB algorithm will run, after prompting the user
%   for the names of the files containing this data.
%
%   [DATA,PARAMS]=CHECKVARSDATA(START,CONTINUE,PARAMS) also
%   returns the updated algorithm parameters.
%
%   Input arguments:
%      START - true if no generations have been run yet (boolean)
%      CONTINUE - true if some generations have been run (boolean)
%      DATA - the current dataset for the algorithm to run (array)
%      PARAMS - the algorithm running parameters (struct)
%   Output arguments:
%      DATA - the dataset on which the algorithm will run (struct)
%      PARAMS - the algorithm running parameters (struct)
%
%   See also CHECKVARSSTATE, CHECKVARSPARAMS, GPLAB
%
%   Copyright (C) 2003-2007 Sara Silva (sara@dei.uc.pt)
%   This file is part of the GPLAB Toolbox

% check training data variables:

if start
   
   % ask for the name of the files:
   parentdir=strrep(which(mfilename),strcat(mfilename,'.m'),'');
      
   % training data:
   if isempty(params.datafilex) % if not in params, ask user
   	filenamex=input('Please name the file (with extension) containing the input data: ','s');
   else
      filenamex=params.datafilex;
   end
   if isempty(findstr(filenamex,filesep))
	   % if file was not given with path, use parentdir (where this file is):
      if (isfield(params,'cpath')~=0)
        filenamex=strcat(params.cpath,'/',filenamex);
      else
        filenamex=strcat(parentdir,filenamex);
      end
   end
   params.datafilex=filenamex;
   x=load(params.datafilex); % load the file
   
	if isempty(params.datafiley) % if not in params, ask user
   	filenamey=input('Please name the file (with extension) containing the desired output: ','s');
   else
      filenamey=params.datafiley;
   end
   if isempty(findstr(filenamey,filesep))
      % if file was not given with path, use parentdir (where this file is):
      if (isfield(params,'cpath')~=0)
        filenamey=strcat(params.cpath,'/',filenamey);  
      else
        filenamey=strcat(parentdir,filenamey);
      end
   end
   params.datafiley=filenamey;
   y=load(params.datafiley); % load the file
   
   
   % test data:
   if params.usetestdata
      
		if isempty(params.testdatafilex)
   		testfilenamex=input('Please name the file (with extension) containing the test input data: ','s');
      else
      	testfilenamex=params.testdatafilex;
      end
      if isempty(findstr(testfilenamex,filesep))
         %% ======= Emigdio's modification
         %testfilenamex=strcat(parentdir,testfilenamex);
         if (isfield(params,'cpath')~=0)
            testfilenamex=strcat(params.cpath,'/',testfilenamex);
         else
            testfilenamex=strcat(parentdir,testfilenamex);
         end
      end
      params.testdatafilex=testfilenamex;
      testx=load(params.testdatafilex); % load the file
      
		if isempty(params.testdatafiley)
   		testfilenamey=input('Please name the file (with extension) containing the test desired output: ','s');
   	else
      	testfilenamey=params.testdatafiley;
      end
      if isempty(findstr(testfilenamey,filesep))
         %% ======= Emigdio's modification
	      %testfilenamey=strcat(parentdir,testfilenamey);
          if (isfield(params,'cpath')~=0)
            testfilenamey=strcat(params.cpath,'/',testfilenamey);
          else
            testfilenamey=strcat(parentdir,testfilenamey);
          end
      end
      params.testdatafiley=testfilenamey;
      testy=load(params.testdatafiley); % load the file
      
   end %if params.usetestdata
   
	% create variable for the algorithm:
   data=feval(params.files2data,x,y);
   if params.usetestdata   	
	   data.test=feval(params.files2data,testx,testy);
   end
end
