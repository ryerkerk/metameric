% Matt Ryerkerk - Michigan State University - June 2019
%
% This function is a version of Mutation_Random that has been modified to work with 
% fixed-length representations (i.e., hidden- and static- metavariables).
%
% The rate of design variable mutations is calculated only using active metavariables. 
% The activation flag is not subject to design variable mutation. It can only be modified
% by the addMetavariable or removeMetavariable mutations. 
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

function [params, outputs, ind] = Mutation_Random_FixedLength(params, outputs, ind)

vars = params.varList; % For simpler access

genome = ind.genome; % Genome will be the mutated genome. We won't modify ind.genome until the end so we can perform a comparison.
% Mutation rate based on the total number of design variables in the
% genome. On average one design variable will be mutated, although its
% possible that more will be mutated, or none.

flagIndex = params.hiddenMetavariableIndex;

% We don't count the hidden metavarable index when calculating geome size
numExpressed = sum(genome(:,flagIndex)==1); % Number of expressed metavariables
numDesignVariables = size(genome, 2) - 1; % Number of design variables in each metavariable of free genotype, not including flag
designVariableMutationChance = 1/(numExpressed*numDesignVariables);

%%%%% This first loop applies a mutation to the design variables %%%%%%
for j = 1:size(genome, 1) % For each metavariable in the genome
  for v = 1:length(vars) % For each design variable in the genome
    if (v == flagIndex) % We won't apply the standard mutation to the flags
      continue;
    end
    if (rand < designVariableMutationChance) % Random chance of mutation occuring
      genome(j,v) = MutateVariable(vars(v), genome(j,v), params.mutationMagnitude);
    end % End loop over variables
  end % End loop over metavariable chance
end

%%%%% Chance to randomly insert a metavariable %%%%%
if (rand < params.addMetavariableMutateChance || all(genome(:,flagIndex) == 0))
  zeroFlags = find(genome(:,flagIndex) == 0);
  if (~isempty(zeroFlags)) % As long at least one flag is set to 0
    index = zeroFlags(randi([1 length(zeroFlags)])); % Pick one of the flags set to 0 at random
    genome(index,flagIndex) = 1; % Turn on this metavariable
  end
end

%%%%% Chance to randomly remove a metavariable %%%%%
% Only remove a metavariable if the genome length is at least 2, don't want
% empty genomes.
if (rand < params.removeMetavariableMutateChance && sum(genome(:,flagIndex)) >= 2)
  oneFlags = find(genome(:,flagIndex) == 1); % All the flags turned on
  index = oneFlags(randi([1 length(oneFlags)])); % Pick one at random
  genome(index,flagIndex) = 0; % Turn off this metavariable
end

% Permutation operator
if (rand < params.permutationChance && size(genome, 1) >= 2)
  swap = randperm(size(genome,1), 2);  % Pick two random metaravariables
  genome(swap,:) = genome(swap([2, 1]), :); % Swap them
end

% Check if there are any differences between the original and mutated genome. 
% If there are, mark it in ind.changes
d = MetavariableDissimilarity(genome, ind.genome, [params.varList.range], [params.varList.type], params);
if (d > 0) % If c1 is different from both parents then a change has occured
  ind.changes = bitor(ind.changes, Individual.MUTATION); % Mark the change
end

ind.genome = genome; % Assign the new genome back into the individual
