% Matt Ryerkerk - Michigan State University - June 2019
%
% The Individual class contains all information related to a single
% individual in a population. Typically the population is represented as a
% vector of individuals. 

classdef Individual
  properties (Constant)
    % MUTATION and CROSSOVER are used to track how a child solution was generated
    MUTATION = 2^0;
    CROSSOVER = 2^1;    
  end
  properties
    genome@double;           % Genome values, a matrix with N rows and M columns.
                             % Each row represents a metavariable, with
                             % each column representing a design variable
                             % as defined by the Variable class. 
    
    fitness@containers.Map;  % fitness is assigned by the evaluation function, it is a mapping of
                             % fitness names to values. The fitness names
                             % need to correspond to the objective and
                             % constraint names defined in the problem.
    
    penalty@double;          % 0 if feasible, otherwise penalty depends on constraint violation.
                             % Currently assigned by @EvaluatePopulation
    
    id;                      % A unique value assigned to each individual when they are generated
                             % Value is based on the number of fitness function evaluations, 
                             % an .id of 1 is the first solution evaluated. 
    
    length;                  % Length of solution
    
    fitVals;                 % Objective values from fitness map container are copied to fitVals for faster access
                             % individual.fitVals(1) == individual.fitness(params.objList(1).name)
                             
    changes;                 % Track changes to child (mutation, crossover) that make it different from parent
 end
  
  methods

  end
end