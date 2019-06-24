params = struct;

% Objectives
Obj1 = Objective;
Obj1.name = 'Weighted Sum Fitness';
Obj1.type = Objective.MINIMIZE;
params.objList = [Obj1];

% Constraints
params.conList = []; % unconstrained

% Variables
Var1 = Variable;
Var1.name = 'x';
Var1.type = Variable.REAL;
Var1.lower = 0;
Var1.upper = 2;

Var2 = Variable;
Var2.name = 'y';
Var2.type = Variable.REAL;
Var2.lower = 0;
Var2.upper = 2;

Var3 = Variable;
Var3.name = 'Range';
Var3.type = Variable.REAL;
Var3.lower = 0.1;
Var3.upper = 0.25;

params.varList = Variable.empty; % No variables, activation flag wll be added
params.staticVarList = [Var1, Var2];
params.varList = [Var3];

rng(1, 'twister'); % Ensure static metavariable is same for all studies
params.staticGenotype = rand(100,2)*2; % Random set of locations for sensors

params.evaluationFunction = @Eval_Coverage;
params.orderedProblem = 0; % Not an ordered problem. Value doesn't matter for static-metavariable representation.

% Initial solution lengths. Also window bounds if fixed-length or static window is used.=
params.minInitialMetavariables = 10;
params.maxInitialMetavariables = 50;

params.spatialVariables = [1, 2]; % Index of variables to be used in spatial crossover. This won't matter for static metavariables

params.hiddenGenomeLength = size(params.staticGenotype, 1);   % Length of hidden metavariable genomes, equal to length of static genotype if one is present
