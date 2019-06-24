% Matt Ryerkerk - Michigan State University - June 2019
%
% Determine the desired size of each niche in the new populations. 
%
% The size of each niche niche is kept as even as possible. If this is not
% possible then first niches given an additional solutionallocation. It is 
% expected that the ordering of niches reflects their priority for the 
% additional solutions (i.e. lengths closest to optimal occur first)
%
% inputs:
%   popSize: Size of new population
%   numNiche: Number of niches 
%
% Outputs:
%   nicheSize: The number of selected solutions allocated to each niche

function [nicheSize]  = DetermineNicheSize(popSize, numNiche)

% Distribute allocations as evenly as possible to begin.
nicheSize = ones(numNiche, 1)*floor(popSize/numNiche); 

% Number of allocations that couldn't be distributed
numLeft = mod(popSize, numNiche);

% Distribute remaining allocations.
nicheSize(1:numLeft) = nicheSize(1:numLeft) + 1; 