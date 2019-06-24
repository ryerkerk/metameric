## Crossover operators

Several crossover operators are provided here, a detailed description and comparison of each of these can be found in Chapter 6 of the dissertation. The ```params.crossoverOperator``` field contains the handle to the crossover operator that will be called when forming children.

The spatial, similar-metavariable-, and cut and splice crossovers are meant to be used with variable-length genomes. The n-point crossover is only meant to be used when a hidden- or static-metavariable representation is employed.

### Spatial Crossover (```Crossover_Spatial.m```)
Spatial crossover (Section 6.1.3) uses a random hyperplane to partition the parent solutions. The metavariables are either side of the hyperplane are exchanged to form child solutions.

The design variables used to partition the solutions must be defined by the user in ```params.spatialVariables```. Generally these are variables that define a spatial position for each metavariable (e.g., x- and y- coordinates). If such variables exist then using a spatial crossover is recommended. If the problem is ordered (Section 4.1.2) then an index value is added to each genome and added to the list of spatial variables.  

### Similar-Metavariable Crossover (```Crossover_Spatial.m```)

Similar-metavariable crossover operates by identifying common subsets of metavariables in each parent. See Section 6.1.4 for a detailed explanation. This operator has comparable, by slightly worse, overall performance when compared to the spatial crossover operator. However, it does not require any user-defined parameters and can be more generally applied compared to spatial crossover.

### Cut and Splice Crossover (```Crossover_CutAndSplice.m```)

Cut and splice crossover (Section 6.1.2) operators similarly to an n-point crossover, but does not require the crossover points to match between the parents. This is a highly destructive operator as metavariables are more or less randomly exchanged, its use is not recommended.

### N-point crossover (```Crossover_nPt.m```)

This is the classic genetic algorithm crossover operator (Secton 6.1.1). It should only be used with parents of the same length genomes, and is the only crossover operator here that will work with hidden- or static- metavariable representations. 


### Other functions
```SetChildrenCrossover.m``` is used by each crossover operator. It creates new ```Individual``` objects for each child, assigns their newly created genome, and then compares the children to each parent. It then modifies the ```.changes``` field in each child object if the crossover has resulted in children that are not identical to the parent solutions.