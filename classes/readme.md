## Solution, variable, objective, and constraint objects
Each solution and each variable, objective, or constraint definition are stored as objects. None of the classes used contain any methods, I found the overhead of MATLAB methods to be prohibitively high for this project. As a result the objects are effectively structures.

The ```Indvidual``` class is used to store each solution. There is no population class, instead each population is simply an array of `Individual` objects. 

- ```Individual.genome``` an array containing the design variables for this solution. Each row represents a metavariable, and each column a particular design variable.
- ```Individual.fitness``` a map container for any values returned by the evaluation function. These values may be used as objectives or constraints, depending on the problem definition. 
- ```Individual.fitVals``` an array of values taken from ```Individual.fitness``` that correspond to the objectives defined in ```params.objList```. Storing these values here allows for much quicker access then relaying on the map container.
- ```Individual.penalty``` penalty value calculated as the normalized sum of constraint violations (Section 4.3)
- ```Individual.length``` the length of the solution. For hidden- or static- metavariable representations this is the number of activate metavariables rather than genome length.
- ```Individual.id``` a unique id assigned to solutions in the order they are generated.
- ```Individual.changes``` tracks whether or not crossover or mutation has resulted in any changes to this solution relative to the parent solutions.


The ```Variable```, ```Constraint```, and ```Objective``` objects need to be defined by the user, typically in the problem scripts located in ```setups/problems/```. These objects will then be stored in the ```params``` structure to be passed between the various operators.  

```Varable``` class parameters:

- ```Variable.type``` set to either ```Variable.REAL```, ```Variable.INTEGER```, ```Variable.DISCRETE```, ```Variable.ENUMERATED```. The variable type affects how the variation operators are applied and how metavariable dissimilarity is calculated. 
- ```Variable.name``` name of variable.
- ```Variable.lower``` lower bound of variable
- ```Variable.upper``` upper bound of variable
- ```Variable.discValues``` array of permissible values for discrete variables. Not required for real, integer, or enumerated types.
- ```Variables.range``` range of variable. Automatically calculated and not required to be set by user. 

```Constraint``` class parameters:

- ```Constraint.type``` set to either ```Constraint.LESSTHAN```, ```Constraint.GREATERTHAN```, ```Constraint.EQUALTO```
- ```Constraint.limit``` the value that the constraint needs to be less than, greater than, or equal to
- ```Constraint.name``` name of constraint, this must match one of the values in the fitness container returned by the evaluation function. 

```Objective``` class parameters. Note that the provided selection operators only support single-objective problems. 

- ```Objective.type``` set to either ```Objective.MINIMIZE```, ```Objective.MAXIMIZE```
- ```Objective.name``` name of constraint, this must match one of the values in the fitness container returned by the evaluation function. 
