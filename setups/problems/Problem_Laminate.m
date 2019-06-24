params = struct;

% Objectives
Obj1 = Objective;
Obj1.name = 'Mass';
Obj1.type = Objective.MINIMIZE;
params.objList = [Obj1];

% Constraints
Con1 = Constraint;
Con1.name = 'Factor of Safety';
Con1.limit = 5;
Con1.type = Constraint.MORETHAN;

params.conList = [Con1]; 

% Variables
Var1 = Variable;
Var1.name = 'angle';
Var1.type = Variable.INTEGER;
Var1.lower = 1; 
Var1.upper = 7;

Var2 = Variable;
Var2.name = 'volume fraction';
Var2.type = Variable.DISCRETE;
Var2.discValues = [0.3 0.4 0.5 0.6 0.7];

params.varList = [Var1, Var2];

params.evaluationFunction = @Eval_LaminateLayers;
params.orderedProblem = 1; % This is an ordered problem, order of metavariables determine layup order

% Initial solution lengths. Also window bounds if fixed-length or static window is used.=
params.minInitialMetavariables = 10;
params.maxInitialMetavariables = 50;

params.spatialVariables = []; % Index of variables to be used in spatial crossover

params.hiddenGenomeLength = 100;   % Length of hidden metavariable genomes. Set on individual problem basis. 
