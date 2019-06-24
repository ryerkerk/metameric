# Optimization Problem Setups

Every study is run by calling it's *setup* script. This performs several steps, including calling a script that defines the optimization *problem* and a script that defines the optimization *algorithm*.

A number of different problem and algorithm scripts are provided here. Studies can be run using most combinations of these scripts. A few exceptions are given in the Problems section below. For example, if the algorithm uses a static-metavariable representation then the problem script must define `params.staticgenotype` and `params.hiddenGenomeLength`. 

## Setups

The setup script first calls the `AddPaths` script to make sure all the necessary scripts and operators are in the search path.

It then calls the problem script, followed by the desired algorithm script. A study name, defined in `params.saveName`, must also be defined. 

If necessary any of the parameters can be altered here. For example, if you want to compare several different mutation magnitudes you can update `params.mutationMagnitude` here rather than creating several new algorithm scripts.

The `Setup` script is then called to perform any necessary pre-processing before beginning the study. Finally, `MEA` is called to begin the study.

The scripts used in the dissertation are provided in `/dissertation_setups/`. Files names are structured as follows:

- The prefix specifies the problem being solved (Section 4.3):
	- `COVC` constrained coverage problem
	- `COVU` unconstrained coverage problem
	- `LAM` laminate composite design
	- `PACK` packing problem
	- `PORT` portfolio problem
	- `WIND` wind farm design
- Next, the window function (or lack thereof) is specified:
	- `Biased_W3` biased window, in this example width = 3
	- `Moving_W5` moving window, in this example width = 5
	- `F24` fixed-length window, in this example L=24
	- `FW23_25` static window, this example contains lengths from 23 to 25
	- `NoWindow` indicates that length niching selection is not used
- This is followed by the type of local selection used:
	- `Score` score selection
	- `Tourn` tournament selection
- Finally, any changes from the standard representation or crossover operators are noted:
	- `cutAndSplice` cut and splice crossover is used
	- `SimilarMetavariable` similar metavariable crossover is used. Note that this is the default operator for the portfolio problem.
	- `mutationOnly` no crossover is used
	- `HMV_30` hidden-metavariable representation is used with a genome length of 30
	- `SMV_50` static-metavariable representation is used with a genome length of 50


## Problems

Every problem script must define the following parameters:

- `params.objList` defines the problem objectives. Note that the provided selection operators are all single-objective. 
- `params.conList` defines all constraints. This needs to be defined as empty for unconstrained problems.
- `params.varList` defines the variables to be contained in each metavariable. If a hidden- or static-metavariable representation used then an additional variable controller metavariable expression will be added automatically.
- `params.evaluationFunction` is the handle to the evaluation function. This function must return values for each objective and constraint defined in this problem. 
- `params.minInitialMetavariables` and `params.maxInitialMetavariables` define the minimum and maximum number of metavariables in the initial population. If a fixed/static window function is used then these are used as the window bounds.
- `params.orderedProblem` is set to 1 if the problem is ordered, 0 otherwise. Note that this value is ignored if a static-metavariable representation is used.

If a spatial crossover operator is used then the following must be defined:

- `params.spatialVariables` gives the indices of the design variables to be used in spatial crossover. 

If a static-metavariable representation is used:

- `params.staticGenotype` defines the static genotype, see Sections 3.2.2.2 and 5.2.2
- `params.hiddenGenomeLength` needs to be set to the length of the static-genotype

If a hidden-metavariable representation is used:

- `params.hiddenGenomeLength` is the length of the genome, and an upper bound on the total number of metavariables that can be contained in a solution. 

## Algorithms

The algorithm script define which evolutionary operators are used, as well as any parameters associated with each operator. The script also defines some non-operator-specific algorithm parameters (e.g., population size, number of evaluations allowed). 

Please see the list of parameters in the `readme` file in the base directory for more information on each parameter.