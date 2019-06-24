% Matt Ryerkerk - Michigan State University - June 2019
%
% This function partitions the population into a number of niches based on
% their solution length. A selection window is formed to determine which
% solution lengths should be used to form niches. The window bounds are
% based on a bias factor which is updated based on changes to the best
% solution length. Methodology given in Section 7.2.4
%
% inputs:
%  params.curGen: Current generation
%  params.BDecayRate: Rate at which the bias factor decays toward
%    each generation
%  params.windowRange: Width of window, note the width can increase for
%    large bias factor values.
%  outputs.bestLength: List of best solution length at each generation,
%    used to update the bias factor.
%  parent_population: Parent population, a vector of Individuals
%  child_population: Child population, a vector of Individuals
%
% Outputs: 
%  params: Updated .currentWindow
%  outputs: Updated with bias factor and window bounds at this generation
%  nichePop: A set of cells, each containing the Individuals belonging to
%    a length niche population
%  nicheSize: Number of solutions to select from each niche in nichePop

function [params, outputs, nichePop, nicheSize]  = WindowFunction_Biased(params, outputs, parent_population, child_population)

% Combine the parent and child population
full_pop = [shiftdim(parent_population); shiftdim(child_population)];

len = shiftdim([full_pop.length]); % Length of solutions. Shiftdim to makes sure this is Nx1, not 1xN vector

% Determine bias factor B
if (params.curGen > 1) % Only start calculating the bias factor after the first two generations
  B = outputs.B(params.curGen-1); % Get previous bias factor value
  % Calculate new B value using equation (7.2)
  B = B*exp(-params.BDecayRate*sqrt(abs(B))) + (outputs.bestLength(params.curGen) - ...
      outputs.bestLength(params.curGen-1));  
else % First two generations just set B = 0
  B = 0;     
end
outputs.B(params.curGen) = B; % Record the new bias factor value

winStart = ceil(outputs.bestLength(params.curGen) - abs(params.windowRange/2) + B); % Calculate the start of the selection window
winStart(winStart > outputs.bestLength(params.curGen)) = (outputs.bestLength(params.curGen)); % Ensure best solution length is contained in window
winStart(winStart < 1 ) = 1; % Make sure the window doesn't start at a length less than 1. 

winEnd = floor(outputs.bestLength(params.curGen) + abs(params.windowRange/2) + B); % Calculate the end of the selection window
winEnd(winEnd < outputs.bestLength(params.curGen)) = outputs.bestLength(params.curGen); % Ensure best solution length is contained in window

window = winStart:1:winEnd; % Form window

% WLmit the width of the window to half the population size, so that each niche should have, 
% on average, 2 solutions. 
while (length(window) > params.popSize/2) % If the window width is greater than half the population size
  dist = abs(window-outputs.bestLength(params.curGen)); 
  window(dist==max(dist)) = []; % Remove the niche that is furthest from the current best. 
end

% Sort the window based on proximity to he current best length. Niches that are closest to the 
% current best length will occur earlier in the window vector, this will giving them priority when 
% determining the window niche size. If a tie occurs, the shorter solutions are given priority 
% (the -0.1 term)
winDist = abs(window-(outputs.bestLength(params.curGen)-0.1));
[~, winOrder] = sort(winDist);
window = window(winOrder);

% Seperate population into length niches
nichePop = cell(length(window), 1); % Create a set of empty niches
for w = 1:length(window) % For each niche in the window
  nichePop{w} = full_pop(len==window(w)); % Assign members with that length to the current niche
end
[nicheSize]  = DetermineNicheSize(params.popSize, length(nichePop)); % Determine how large each niche will be

% Record some outputs
params.currentWindow = window;  % Make note of the current window, this will be used in subsequent fucntions
outputs.winStart(params.curGen) = min(window); % Record the start of the current window
outputs.winEnd(params.curGen) = max(window); % Record the end of the current window