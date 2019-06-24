% Matt Ryerkerk - Michigan State University - June 2019
%
% Forms a population of individuals with a random number of metavariables
% and design variables.
%
% inputs:
%   params.popSize: Number of individuals to create
%   params.minInitialMetvariables: Minimum number of metavariables in each solution
%   params.maxInitialMetvariables: Maximum number of metavariables in each solution
%   params.varList: List of variables for each metavariable (see Variable Class)
%
% Outputs:
%   pop: Randomly initialized population

function [pop] = Initialize_Random(params)

pop(1:params.popSize) = Individual; % List of empty individuals
for i = 1:params.popSize
  % Randomly choose number of metavariables to include
  numMetavariables = randi([params.minInitialMetavariables, params.maxInitialMetavariables]);  
  
  % Generate a genome with random design variable values. 
  if (params.hiddenMetavariable == 1 || params.staticMetavariable == 1) 
    % If we use hidden metavariable make a genome equal to the user-specified fixed genome length.
    genome = GenerateRandomMetavariable(params.varList, params.hiddenGenomeLength);
    
    
    genome(:,params.hiddenMetavariableIndex) = 0; % Set all hidden metavariable flags to 0,
    % And then randomly turn on a random number of metavariables to achieve desired length
    genome(randperm(params.hiddenGenomeLength, numMetavariables),params.hiddenMetavariableIndex) = 1; 
  
  else % If not hidden- or static- metavariable representation create genome of desired length
    genome = GenerateRandomMetavariable(params.varList, numMetavariables);
  end
  
  pop(i).genome = genome; 
end