% Matt Ryerkerk - Michigan State University - June 2019
%
% Length niching selection, described in Section 7.2 of the dissertation, partitions the combined
% parent/child population based on length. A subset of these lengths, as determined by the window
% function, are then subject to local selection in order to form the new parent population. 
%
% inputs: 
%   params.windowFunction: Handle to function used to form selection window (Section 7.2)
%   params.localSelectionOperator: Handle to function used for local selection of niches
%   params.popSize: Population size
%   outputs: unused here, may be used by window function or local selection
%   parentPop: Parent population
%   childPop: Child population

% outputs:
%   params: unmodified here, may be modified by window function or local selection operator
%   outputs: fitness, length, and penalty of best solution will be updated in RecordBest()
%            other changes may take place in window function or local selection operator
%   pop: selected population

function [params, outputs, pop] = Selection_LengthNiching(params, outputs, parentPop, childPop)

full_pop = [shiftdim(parentPop); shiftdim(childPop)]; % Combine the parent and child population
[outputs] = RecordBest(params, outputs, full_pop);    % Determine best solution, record its fitness, 
                                                      % length, and penalty in outputs

% Call window function to form niches. 
% nichePop will be a set of cells containing the solutions in each niche. 
% nicheSize will give the nmber of solutions to be selected from each niche
[params, outputs, nichePop, nicheSize] = params.windowFunction(params, outputs, parentPop, childPop); % Get the niching windows

pop = Individual.empty; % Start with an empty population

for w = 1:length(nichePop) % For each niche
  if (nicheSize(w) == 0) % If this niche is allocated no solutions then just continue to next niche
    continue; 
  end
  % Perform local selection on niche
  [params, outputs, selectedPop] = params.localSelectionOperator(params, outputs, nichePop{w}, nicheSize(w));
  pop = [shiftdim(pop); shiftdim(selectedPop)]; % Insert the selected individuals into the new population
end

% In some cases the niches may not contain enough solutions to fill the population. In that case the
% remaining solutions will be chosen from the unselected solutions in full_pop.
remainingPopSize = params.popSize - length(pop); % How many solutions are needed to fill the population?
if (remainingPopSize > 0) % If we still need solutions,
  full_popID = [full_pop(:).id]; % Solution IDs in combined parent/child population
  popID = [pop(:).id];  % Solutions already selected
  remainingPop = full_pop(~ismember(full_popID, popID)); % Solutions not already selected
  
  % Perform local selection on remaining solutions, add to selected population
  [params, outputs, selectedPop] = params.localSelectionOperator(params, outputs, remainingPop, remainingPopSize);
  pop = [shiftdim(pop); shiftdim(selectedPop)];
end