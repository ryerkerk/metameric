% Matt Ryerkerk - Michigan State University - June 2019
% 
% This operator performs tournament selection on the niche. The size of the pool
% of candidate solutions, and the number of solutions to select from that pool,
% will frequently change. Due to this an adaptive tournament size is used, this
% is the smallest tournament size that allows every candidate solution to 
% participate in at least one tournament. By necessity some solutions may participate
% in multiple tournaments
% 
% Note that this operator currently only works for single objective problems.
%
% Solutions are compared as described by Deb in "An efficient
% constraint handling method for genetic algorithms":
%   Feasible solutions are compared based on fitness.
%   Infeasible solutions are compared based on penalty. 
%   Feasible solutions will always be preferred to infeasible solutions
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

function [params, outputs, nichePop] = LocalSelection_Tournament(params, outputs, candSolus, nicheSize)

% If there aren't enough solutions to fill the niche then just return the candidate solutions. 
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

K = ceil(length(candSolus)/nicheSize); % Minimum tournament size that allows all solutons to participate at last once
T = zeros(nicheSize, K); % Each row of T will designate the solutiosn to use in each tournament.
T(1:length(candSolus)) = randperm(length(candSolus)); % Randomly put all solutions into the tournament once.

% Some 0 (empty) values may still remain in T. This next block will fill those spots
% with randomly selected solutions such that:
%   -No tournament contains more than one copy of a single solutions
%   -No solution participates in more than two tournaments. 
rem = 1:length(candSolus); % rem tracks solutions that have not participated in two tournaments.
                           % initially this is all solutions. 
for i = 1:nicheSize
  extraPool = setdiff(rem, T(i,:)); % Solutions eligible to be added to this tournament
  extraSolu = extraPool(randperm(length(extraPool), sum(T(i,:)==0))); % Extra solutions, if needed
  T(i,T(i,:)==0) = extraSolu;    % Add solution to tournament, if needed
  rem = setdiff(rem, extraSolu); % Remove the used solutons from our remaining solution pool;
end

% The final block performs tournament selection
sel = zeros(nicheSize,1); % Selected solutions
for i = 1:nicheSize % For each tournament,      
  sel(i) = T(i, find(aFit(T(i,:)) == min(aFit(T(i,:))), 1)); % selection best solution in the tournament pool
end 
nichePop = candSolus(sel); 


