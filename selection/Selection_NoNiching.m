% Matt Ryerkerk - Michigan State University - June 2019
%
% This selection operator does not use length niching. Instead the entire parent/child population is
% passed to the local selection operator. In effect the combined population is considered as a
% single "niche".
%
% inputs:
%   params.localSelectionOperator: Handle to function for selection.
%   params.popSize: Population size
%   outputs: unused here, may be used by local selection
%   parentPop: Parent population
%   childPop: Child population

% Outputs:
%   params: unmodified here, may be modified by local selection operator
%   outputs: fitness, length, and penalty of best solution will be updated in RecordBest()
%            other changes may take place in local selection operator
%   pop: selected population

function [params, outputs, pop] = Selection_NoNiching(params, outputs, parentPop, childPop)

full_pop = [shiftdim(parentPop); shiftdim(childPop)]; % Combine the parent and child population
[outputs] = RecordBest(params, outputs, full_pop);    % Determine best solution, record its fitness, 
                                                      % length, and penalty in outputs
                                                      
% Perform local selection on combined parent/child population.
[params, outputs, pop] = params.localSelectionOperator(params, outputs, full_pop, params.popSize); 
