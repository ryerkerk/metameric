% Matt Ryerkerk - Michigan State University - June 2019
%
% This function partitions the population into a number of niches based on
% their solution length. A selection window is formed to determine which
% solution lengths should be used to form niches. The window bounds are
% based on the current best solution length and the window range as set by
% the user.
%
% This function is used for both the fixed-length window and static-window (Sections 7.2.1 and
% 7.2.2)
%
% inputs:
%  params.curGen: Current generation
%  params.minInitialMetavariables: Lower bounds of window
%  params.maxinInitialMetavariables: Upper bounds of window
%  outputs.bestLength: List of best solution length at each generation
%  parent_population: Parent population, a vector of Individuals
%  child_population: Child population, a vector of Individuals
%
% Outputs: 
%  params: Updated .currentWindow
%  outputs: Updated with bias factor and window bounds at this generation
%  nichePop: A set of cells, each containing the Individuals belonging to
%    a length niche population
%  nicheSize: Number of solutions to select from each niche in nichePop

function [params, outputs, nichePop, nicheSize]  = WindowFunction_Fixed(params, outputs, parent_population, child_population)

% Combine the parent and child population
full_pop = [shiftdim(parent_population); shiftdim(child_population)];

len = shiftdim([full_pop.length]); % Length of solutions. Shiftdim to makes sure this is Nx1, not 1xN vector

% Setup the window, the lower and upper bounds of the window are fixed and
% set by the user in the problem definition.
winStart = params.minInitialMetavariables; 
winEnd = params.maxInitialMetavariables; 
window = winStart:winEnd; 

% Sort the window based on proximity to he current best length. Niches that are closest to the 
% current best length will occur earlier in the window vector, this will giving them priority when 
% determining the window niche size. If a tie occurs, the shorter solutions are given priority 
% (the -0.1 term)
winDist = abs(window-(outputs.bestLength(params.curGen)-0.1));
[~, winOrder] = sort(winDist);
window = window(winOrder);

if (any(len > max(window)) || any(len < min(window)))
  disp('Warning: WindowFunction_Fixed: Producing solutions outside of range. Consider using a filter')
end

% Seperate population into length niches
nichePop = cell(length(window), 1); % Create a set of empty niches
for w = 1:length(window) % For each niche in the window
  nichePop{w} = full_pop(len==window(w)); % Assign members with that length to the current niche
end
[nicheSize] = DetermineNicheSize(params.popSize, length(nichePop)); % Determine how large each niche will be

% Record some outputs
params.currentWindow = window;  % Make note of the current window, this will be used in subsequent fucntions
outputs.winStart(params.curGen) = min(window); % Record the start of the current window
outputs.winEnd(params.curGen) = max(window); % Record the end of the current window