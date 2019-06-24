## Evaluation functions

Several evaluation functions are provided here. This includes a coverage, windfarm, portfolio, packing, and laminate composite problem. Users are referred to the comments contained in each evaluation function, as well as Section 4.3 of the dissertation, for more information on each problem. 

### Creating new evaluation functions

New evaluation functions can easily be created and tested. There are only a few requirements, listed below. 

- Only one input argument is used for each function, the solution genome. If a hidden- or static- metavariable representation is used then this will be the genome after the static-metavariables have been added (if necessary) and the inactive metavariables removed. These steps occur in the `EvaluatePopulation` function. 
- The fitness function will be called once with no input arguments at the very start of each trial. This allows the function to load any data and initialize any persistent variables that will be used. Even if these are not needed the function should be able to handle a call with `nargin==0`.
- Fitness is returned using a `containers.Map('KeyType', 'char', 'ValueType', 'double')` object. Any number of fitness values can be stored here, but it must contain a value for all objective and constraint names that are defined in the problem setup.