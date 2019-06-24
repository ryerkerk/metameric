# Mutation Operators

Currently only one mutation operator is included here. 	Each call to this operator may perform one or more of the following mutations:

- Each design variable in each metavariable has a small chance of undergoing Gaussian mutation. The mutation rate is equal to the total number of design variables in the genome i.e.,  1/(# metavariables * # variables per metavariable).
	- The standard deviation of the mutations ("mutation magnitude") is the product of the mutated variables bounds and `params.mutationMagnitude`.
	- The variable type affects how mutation is performed. See the comments inside of `MutateVariable.m` for more information.
- One randomly generated metavariable may be inserted at a random location in the genome, rate set by `params.addMetavariableMutateChance`
- One randomly chosen metavariable is removed from the genome, rate set by `params.removeMetavariableMutateChance`
- Two randomly selected metavariables will swap places in the genome, rate set by `permutationChance`

 `Mutation_Random` is used with variable-length genomes. `Mutation_Random_FixedLength` uses the same mutations but is modified to work with hidden- or static-metavariable representations. 

`MutateVariable` is used to mutate individual design variables based on their type. `RandNorm` mutates a given value by sampling a normal distribution.

