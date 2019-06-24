params = struct;

% Objectives
Obj1 = Objective;
Obj1.name = 'Cost Per Power';
Obj1.type = Objective.MINIMIZE;
params.objList = [Obj1];

% Constraints
Con1 = Constraint;
Con1.name = 'Cumulative Distance Violation';
Con1.limit = 0.0;
Con1.type = Constraint.EQUALTO;

params.conList = [Con1]; 

% Variables
Var1 = Variable;
Var1.name = 'x';
Var1.type = Variable.REAL;
Var1.lower = 100;
Var1.upper = 1900;

Var2 = Variable;
Var2.name = 'y';
Var2.type = Variable.REAL;
Var2.lower = 100;
Var2.upper = 1900;

params.varList = [Var1, Var2];

params.evaluationFunction = @Eval_WindFarm;
params.orderedProblem = 0; % Not an ordered problem

% Initial solution lengths. Also window bounds if fixed-length or static window is used.=
params.minInitialMetavariables = 10; % Minimum number of metavariables in initial solution
params.maxInitialMetavariables = 50; % Maximum number of metavariables in initial solution 

params.hiddenGenomeLength = 100;   % Length of hidden metavariable genomes. Set on individual problem


params.spatialVariables = [1, 2]; % Index of variables to be used in spatial crossover
