% Matt Ryerkerk - Michigan State University - June 2019
%
% Create a child population from a given input population. This function only 
% forms the genotypes of the child population, no evaluation occurs here.
%
% Children will be generated through crossover and mutation operators. A
% pairing operators determines which parents will be used to form children.
% The pairing operator may simply randomly pair parents together, or might
% restrict pairings based on other criteria such as length. 
%
% A repair operator may also be used. This operator can modify, and hopefully
% improve, children. The repair is typically problem specific. 
%
% The repair operator can also act as a filter. This is in addition to, or in 
% place of, the repair functionality. The filter determines whether or not a 
% solution will be included in the child population. Solutions not accepted will
% be discarded and replaced by new children. 
%
% Some filters are not problem specific. For example it may be desired to filter
% solutions not in the current selection window.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params.pairingOperator: Function handle to the parent pairing function
%  params.crossoverOperator: Function handle to the crossover operator
%  params.mutationOperator: Function handle to the mutation operator
%  params.repairOperator: Function handle to the repair/filter operator.
%  params.popSize: Population size, this will also be the size of the child
%    population
%  params.crossoverRate: A value between [0, 1], the chance that crossover
%    occurs for each pair of parents. 
%  params. : A number of other parameters may be set for use in the various
%    functions called here. See those function headers for informatation
%    related to their input parameters. 
%  outputs: These values may be used or updated by the functions called here.
%  pop: The parent population, a vector of Individuals. 
%
% Outputs: 
%  params: Values may be updated by the functions called here
%  outputs: Values may be updated by the functions called here
%  childPop: The child population, a vector of unevaluated Individuals

function [params, outputs, childPop] = Create_Child_Population(params, outputs, pop)

childPop = Individual.empty; % Start with empty child population

% Get a set of random pairs to be used for recombination
[params, outputs, pairs] = params.pairingOperator(params, outputs, pop); 
pairOrd = randperm(size(pairs, 1)); % Get a random ordering of the pairs.

pairIndex = 0; % This value tracks the current parent pair used to form children
while (length(childPop) ~= params.popSize) % Repeat until the child population is full
  
  pairIndex = pairIndex + 1; % Use next parent pair. 
  
  % Sometimes we will cycle through the entire set of parent pairs without
  % filling the child population. This will occur if the filtering operator
  % is discarding children. In this case we will generate a new set of
  % parent pairs.
  if (pairIndex > size(pairs, 1))
    [params, outputs, pairs] = params.pairingOperator(params, outputs, pop); % Get a set of random pairs to be used for recombination
    pairOrd = randperm(size(pairs, 1)); % Get a random ordering of the pairs.
    pairIndex = 1;
  end
  
  parent1 = pop(pairs(pairOrd(pairIndex),1)); % First parent
  parent2 = pop(pairs(pairOrd(pairIndex),2)); % Second parent
  
  if (rand < params.crossoverRate) % Random chance for crossover to occur.     
    % Call the crossover operator
    [params, outputs, child1, child2] = params.crossoverOperator(params, outputs, parent1, parent2); 
  else % If crossover does not occur then each child will initially be identical to either parent
    child1 = parent1; child2 = parent2; % Set child equal to parents
    child1.changes = 0; child2.changes = 0; % Mark that neither child has been modified yet.
  end

  % The mutation operator will always be called at least once for both
  % children. Depending on the operator used it may not be guaranteed that
  % any mutation occurs with a single operator call. 
  [params, outputs, child1] = params.mutationOperator(params, outputs, child1);
  [params, outputs, child2] = params.mutationOperator(params, outputs, child2);

  % Any changes that occur to the children are marked in the child.changes
  % value. If child.changes == 0 then that child is identical to the
  % parent, which is something we want to avoid. If that is the case then
  % repeatedly call the mutation operator until a change is detected.  
  while (child1.changes == 0)
    [params, outputs, child1] = params.mutationOperator(params, outputs, child1);
  end
  
  while (child2.changes == 0)
    [params, outputs, child2] = params.mutationOperator(params, outputs, child2);
  end
    
  % Call the filter operator for the first child.
  [child1, params, outputs, acceptFlag] = params.filterRepairOperator(params, outputs, pop, childPop, child1);
  if (acceptFlag == 1) % If the child is NOT filtered out    
    childPop(length(childPop)+1) = child1; % Add to the child population       
  end
  
  % Make sure the child population is not full before checking the second
  % child. If it is then break from this loop.
  if (length(childPop) == params.popSize)
    break;
  end
    
  % Call the filter operator for the second child.
  [child2, params, outputs, acceptFlag] = params.filterRepairOperator(params, outputs, pop, childPop, child2);
  if (acceptFlag == 1) % If the child is NOT filtered out    
    childPop(length(childPop)+1) = child2; % Add to the child population    
  end  
end