% This function is used to save workspaces from without a parloop.
%
% Adapted from code available at the following link:
% https://www.mathworks.com/matlabcentral/answers/135285-how-do-i-use-save-with-a-parfor-loop-using-parallel-computing-toolbox

function parsave(savefolder,savename, vnames___,varargin)
if (exist('saved_trials') == 0)
  mkdir('saved_trials')
end

if (exist(['saved_trials/' savefolder]) == 0)
  mkdir('saved_trials', savefolder)
end

if (nargin == 2)
  save(['saved_trials/' savefolder '/' savename '.mat']);
  return;
end

numvars___=numel(varargin);
	for ii___=1:numvars___
       eval([vnames___{ii___},'=varargin{ii___};']);  
	end
	save(['saved_trials/' savefolder '/' savename '.mat'],vnames___{1});
	for ii___ = 2:numvars___    
		save(['saved_trials/' savefolder '/' savename '.mat'],vnames___{ii___},'-append');
	end
end