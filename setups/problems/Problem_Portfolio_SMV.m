params = struct;
Obj1 = Objective;
Obj1.name = 'Return TCost';
Obj1.type = Objective.MAXIMIZE;

params.objList = [Obj1;];

% Constraints
Con1 = Constraint;
Con1.name = 'Number of Assets';
Con1.limit = 1;
Con1.type = Constraint.MORETHAN;

Con2 = Constraint;
Con2.name = 'Risk';
Con2.limit = 0.50e-3;
Con2.type = Constraint.LESSTHAN;

params.conList = [Con1; Con2]; %#ok<*NBRAK>

% Variables
Var1 = Variable;
Var1.name = 'Amount';
Var1.type = Variable.REAL;
Var1.lower = 0;
Var1.upper = 1;

Var2 = Variable;
Var2.name = 'AssetType';
Var2.type = Variable.ENUMERATED;
Var2.lower = 1;
Var2.upper = 98;

params.varList = [Var1]; 
params.staticVarList = [Var2];
params.staticGenotype = [1:98]';

params.evaluationFunction = @Eval_Portfolio;
params.orderedProblem = 0; % Not an ordered problem. Value doesn't matter for static-metavariable representation.

% Initial solution lengths. Also window bounds if fixed-length or static window is used.=
params.minInitialMetavariables= 10;
params.maxInitialMetavariables= 50;

params.hiddenGenomeLength = size(params.staticGenotype, 1);   % Length of hidden metavariable genomes, equal to length of static genotype if one is present

params.spatialVariables = [-1];