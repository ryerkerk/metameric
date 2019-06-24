% ****** Algorithm Setup ******
params.evalLimit = 100000;
params.numTrial = 200; 
params.popSize = 20;
params.rngVal = 1; % Initial seed for reproducible results
params.hiddenMetavariable = 1; % Not a hidden metavariable setup
params.staticMetavariable = 0; % Not a static metavariable setup

%******* Variation Operators **********
params.pairingOperator = @Pairing_Random; % Pairing Method
params.crossoverOperator = @Crossover_nPt; % Crossover Method
params.crossoverRate = 0.8; 

params.mutationOperator = @Mutation_Random_FixedLength;
params.addMetavariableMutateChance = 0.05;
params.removeMetavariableMutateChance = 0.05;
params.permutationChance = 0.05;
params.mutationMagnitude = 0.05; % Fraction of variable bounds. 
params.filterRepairOperator = @Filter_None; % Repair/filter function

%******* General Selection *********
params.selectionOperator = @Selection_LengthNiching; % This will require a window function and local selection operator be defined

%******* Window function ************
params.windowFunction = @WindowFunction_Biased;
params.windowRange = 3;
params.windowBuffer = 0; 
params.BDecayRate = 0.004;

%******* Local Selection ********
params.localSelectionOperator = @LocalSelection_Score;
params.FDecayRate = 0.004;  % May be required by local selection operator