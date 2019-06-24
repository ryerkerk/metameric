% Matt Ryerkerk - Michigan State University - June 2019
% 
% This operator selects only the best solutions from the niche in terms of 
% fitness and penalty. Solutions are ranked described by Deb in "An efficient
% constraint handling method for genetic algorithms":
%   Feasible solutions are compared based on fitness.
%   Infeasible solutions are compared based on penalty. 
%   Feasible solutions will always be preferred to infeasible solutions
%
% Note that this operator currently only works for single objective problems.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params.objList: List of objectives
%  outputs:
%  candSolus: Niche population, a vector of Individuals
%  nicheSize: Number of solutions to select
%
% outputs: (blank indicates the value is returned unmodified)
%  params: 
%  outputs:
%  nichePop: Vector of selected individuals

function [params, outputs, nichePop] = LocalSelection_Greedy(params, outputs, candSolus, nicheSize)

% If there aren't enough solutions to fill the niche then just return the 
% entire set of candidate solutions. 
if (length(candSolus) <= nicheSize)
  nichePop = candSolus;  
  return;
end

fit = shiftdim([candSolus.fitVals]); % Fitness of candidate solutions.
pen = shiftdim([candSolus.penalty]); % Penalty of solutions

% Flip sign on objectiv if this is a maximization problem
if (params.objList(1).type == Objective.MAXIMIZE)
  fit = fit*-1;
end

% Calculate the adjusted fitness described by Deb in "An efficient
% constraint handling method for genetic algorithms".
aFit = fit.*(pen==0) + (pen + max(fit)).*(pen>0);

% Sort and select the best solutions.
[~, rank] = sort(aFit); 
rank = rank(1:nicheSize); 
nichePop = candSolus(rank); 


