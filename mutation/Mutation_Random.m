% Matt Ryerkerk - Michigan State University - June 2019
%
% Randomly mutates a solution. There is a chance to mutate each design
% variable, as well as a chance to add or remove a metavariable to/from the
% genome. Chance of design variable mutation is determined based on
% solution length.
%
% Note that this function will only work with variable-length genomes. If a
% hidden- or static- metavariable representation is used a different
% mutation function should be employed.
%
% There is a chance that mutation will not occur. The mutation chance used
% here means that approximately 1/e solutions will not have their design
% variables mutated. If a length change or permutation also does not 
% occur then the individual is returned unchanged.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params.varList: Vector of Variables defining the design variables
%  params.addMetavariableMutateChance: Chance of adding a metavariable
%  params.removeMetavariableMutateChance: Chance of removing a metavariable
%  params.permutationChance: Chance of swapping the positions of two metavariables
%  params.params.mutationMagnitude: The magnitude of mutations to the
%    metavariable, magnitude will be this value multiplied by the variable range
%  outputs: 
%  ind: The Individual being mutated
%
% outputs: (blank indicates the value is returned unmodified)
%  params: 
%  outputs:
%  ind: The mutated Individual.

function [params, outputs, ind] = Mutation_Random(params, outputs, ind)

vars = params.varList; % For simpler access

genome = ind.genome; % Genome will be the mutated genome. We won't modify ind.genome until the end so we can perform a comparison.

% Mutation rate based on the total number of design variables in the
% genome. On average one design variable will be mutated, although its
% possible that more will be mutated, or none.
designVariableMutationChance = 1/numel(genome);

%%%%% This first loop applies a mutation to the design variables %%%%%%
for j = 1:size(genome, 1) % For each metavariable in the genome
  for v = 1:length(vars)  % For each design variable in the genome
    if (rand < designVariableMutationChance) % Random chance of mutation occuring      
      genome(j,v) = MutateVariable(vars(v), genome(j,v), params.mutationMagnitude);
    end % End loop over variables
  end % End loop over metavariable chance
end

%%%%% Chance to randomly insert a metavariable %%%%%
if (rand < params.addMetavariableMutateChance || isempty(genome))
  MV = GenerateRandomMetavariable(vars, 1); % Generate a random metavariable
  index = randi([1 size(genome, 1)+1]); % Pick a random location to insert the metavariable
  genome(index+1:end+1, :) = genome(index:end,:); % Shift everything to make room;
  genome(index,:) = MV; % Insert new metavariable
end

%%%%% Chance to randomly remove a metavariable %%%%%
% Only remove a metavariable if the genome length is at least 2, don't want
% empty genomes.
if (rand < params.removeMetavariableMutateChance && size(genome, 1) >= 2)
  index = randi([1 size(genome, 1)]); % Randomly pick a metavariable
  genome(index,:) = []; % Delete it
end

%%%%% Permutation operator %%%%%
if (rand < params.permutationChance && size(genome, 1) >= 2) % Can only permute if there are at least 2 metavariables
  swap = randperm(size(genome,1), 2);  % Pick two random metaravariables
  genome(swap,:) = genome(swap([2, 1]), :); % Swap their positions
end


% This next block of code checks if any changes have occured to the genome, and if so marks it ind
% the ind.changes field.
d = MetavariableDissimilarity(genome, ind.genome, [params.varList.range], [params.varList.type], params);
if (d > 0 || size(genome,1) ~= size(ind.genome,1))
   ind.changes = bitor(ind.changes, Individual.MUTATION); % Mark the change
end

ind.genome = genome; % Assign the new genome back into the individual
