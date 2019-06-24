params = struct;
% Objectives
Obj1 = Objective;
Obj1.name = 'Cost';
Obj1.type = Objective.MAXIMIZE;
params.objList = [Obj1];

% Constraints
Con1 = Constraint;
Con1.name = 'Overlap';
Con1.limit = 1e-6;
Con1.type = Constraint.LESSTHAN;

params.conList = [Con1]; 

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
Var3.type = Variable.INTEGER;
Var3.lower = 0;
Var3.upper = 1;

params.varList = [Var1, Var2, Var3];

params.evaluationFunction = @Eval_Packing;
params.orderedProblem = 0; % Not an ordered problem

% Initial solution lengths. Also window bounds if fixed-length or static window is used.=
params.minInitialMetavariables= 10;
params.maxInitialMetavariables= 50;

params.hiddenGenomeLength = 100;   % Length of hidden metavariable genomes. Set on individual problem basis. 
params.spatialVariables = [1, 2];