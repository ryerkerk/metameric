## Auxiliary functions

This folder contains a number of important functions that are not specific to any one operator. 

- `Create_Child_Population` is called once each generation to create the child population through crossover and mutation. It does not evaluate the child solutions. 
- `EvaluatePopulation` evaluates the given population. This includes adding the static-genotype (if necessary) and removing any inactive metavariables (if necessary). Solution penalty is calculated if any constraints are present. 
- `Filter_None` a filter operator that will never filter out any child solutions.
- `Filter_Window` a filter operator that will signal to `Create_Child_Population` to discard and replace any children that have a solution length outside of the current selection window. Used by fixed-length and static windows.
- `GenerateRandomMetavariable` creates one or more random metavariables. Used to generate initial solutions, or when the mutation operator adds a random metavariable to the genome. 
- `Initialize_Random` randomly generates the initial population.
- `MetavariableDissimilarity` calculates the dissimilarity between the metavariables in two solutions. This returns the total dissimilarity as well as the dissimilarity between all metavariable pairs. Different methodologies are used depending on the representation (variable-length, hidden-metavariable, or static-metavariable):
	- `MetavariableDissimilarity_HiddenMetavariable` Calculate dissimilarity when a hidden-metavariable representation is used.
	- `MetavariableDissimilarity_StaticMetavariable` Calculate dissimilarity when a static-metavariable representation is used. This function assumes the static-genotype is not visible to the optimization algorithm.
	- `MetavariableDissimilarity_VariableLength` Calculate dissimilarity when a hidden-metavariable representation is used.
- `Pairing_Random` creates random pairs of parent solutions to be used by the crossover operator.
  