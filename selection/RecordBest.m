% Matt Ryerkerk - Michigan State University - June 2019
%
% This function will record determine the best solution in the population
% and record its length, fitness, and penalty to the outputs structure.
%
% The best solution is considered to be the feasible solution with the best
% objective fitness. If no feasible solutions exist then the solution with
% the lowest penalty (i.e. constraint violation) is chosen.
%
% Currently only works for single-objective problems
%
% inputs:
%   params.objList: Should be a single objective. If more than one
%     objective is present it will choose the best based on the first
%     objective.
%   outputs: Current output structure
%   pop: The population being considered, a vector of Individuals
%
% Outputs:
%   outputs.bestLength: Length of best solution
%   outputs.bestFit: Fitness of best solution
%   outputs.bestPen: Penalty of best solution

function [outputs] = RecordBest(params, outputs, pop)

len = shiftdim([pop.length]); % Length of solutions.
fit  = reshape([pop.fitVals], length(params.objList), length(pop))';  % Fitness of solutions
fit = fit(:,1); % Remove fitness for objectives other than first objective. 
pen = shiftdim([pop.penalty]); % Penalty of solutions

fOrig = fit; % Fitness before we flip the sign

% In case of maximization problem, flip sign on fitness. 
if (params.objList(1).type == Objective.MAXIMIZE)
  fit = fit * -1;
end

% Calculate the adjusted fitness described by Deb in "An efficient
% constraint handling method for genetic algorithms".
aFit = fit.*(pen==0) + (pen + max(fit)).*(pen>0);

% Determine the best individual, make note of its length, fitness, and penalty
bestInd = find(aFit(:,1)==min(aFit(:,1)));
outputs.bestLength(params.curGen) = len(bestInd(1));
outputs.bestFit(params.curGen) = fOrig(bestInd(1));
outputs.bestPen(params.curGen) = pen(bestInd(1));