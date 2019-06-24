% Matt Ryerkerk - Michigan State University - June 2019
%
% Evaluate all solutions in the given population, including calculating
% penalties. If static- or hidden- metavariable representations are used then this function
% will add the static-genotype (if necessary) and remove inactivate metavariables from the
% genotype. 
%
% Penalties are a normalized sum of constraint violations.
%
% inputs: (blank indicates the parameter is not used by this function)
% params.evaluationFunction: Handle to evaluation function
% params.objList: Vector of Objectives (see Objective class)
% params.conList: Vector of Constraints (see Constraint class)
% params.hiddenMetavariable: Set to 1 if hidden-metvariable representation is used
% params.staticMetavariable: Set to 1 if static-metvariable representation is used
% params.staticGenotype: Static-genotype, necessary only if static-metavariable representation is used
% params.hiddenMetavariableIndex: Index used by expression flag, only necessary if hidden- or
%                                 static- metavariable representation is used. 
%
% outputs.evalCount: Count of evaluation calls so far, will be updated and
%                    returned
% pop: Population to be evaluated, a vector of Individuals
%
% Outputs:
% pop: Population with evaluated solutions
%   .fitness, .fitVals, .length, .penalty, .id values set for each individual
% outputs.evalCount: Updated evaluation count

function [params, pop] = EvaluatePopulation(params, pop)

for i = 1:length(pop) % For each solution  
  curGenome = pop(i).genome; % Get the solutions genome
      
  if (params.hiddenMetavariable == 1 || params.staticMetavariable == 1) % Hidden- or Static-metavariable representation used
    if (params.staticMetavariable == 1) % Add static-genotype to genome, if necessary
      curGenome = [curGenome params.staticGenotype];
    end
    curGenome(curGenome(:,params.hiddenMetavariableIndex)==0, :) = []; % Remove the inactive metavariables
    curGenome(:, params.hiddenMetavariableIndex) = []; % Remove the hidden-metavariable flag
  end
  
  pop(i).fitness = params.evaluationFunction(curGenome); % Evaluate solution, assign fitness
  params.curEvalCount = params.curEvalCount + 1; % Increment our count of function evaluations
  pop(i).id = params.curEvalCount; % Set individual .id to current evaluation count
  
  % .fitVals allows faster access to objective values of a solutions
  % compared to using .fitness term which maps objective names to values.
  % i.e. pop(i).fitVals(j) === pop(i).fitness(params.objList(j).name)
  for j = 1:length(params.objList)
    pop(i).fitVals(j) = pop(i).fitness(params.objList(j).name); 
  end
  
  % .length is the length of solution. Note that this only counts the active metavariables in 
  % hidden- or static-metavariable representations
  pop(i).length = size(curGenome, 1);
  
  % Constraints in this algorithm are expected to be defined as:
  %   g(x) <= limit, g(x) >= limit, or h(x) == limit
  % 
  % The constraints are normalized based on their limit value, resulting in
  % constraints of the form:
  %   (g(x)-limit)/limit <= 0, (g(x)-limit)/limit >= 0, or (h(x)-limit)/limit == 0
  %
  % If the limit is 0 then the constraint is not normalized (e.g. g(x) <= 0). 
  %
  % The normalized penalty is calculated as the sum of the absolute values
  % of the LHS of the violated constraints. If all constraints are satisfied
  % the penalty will be zero. 
  %    normalized constraint violation = abs( (g(x)-limit)/limit ) for violated constraints, 0 otherwise
  %    penalty = sum(normalized constraint violations)   
  pop(i).penalty = 0; % Initialize to no penalty
  for j = 1:length(params.conList) % For each constraint
    normVal = params.conList(j).limit; % Get the constraint normalization factor
    normVal(normVal==0) = 1; % If the limit is 0 set normalization to 1. 
    
    % Check if the constraint is violated
    if ( ((params.conList(j).type == Constraint.MORETHAN) && (pop(i).fitness(params.conList(j).name) < params.conList(j).limit)) || ...
         ((params.conList(j).type == Constraint.LESSTHAN) && (pop(i).fitness(params.conList(j).name) > params.conList(j).limit)) || ...
         ((params.conList(j).type == Constraint.EQUALTO) && (pop(i).fitness(params.conList(j).name) ~= params.conList(j).limit)))
      % If constraint is violated, add the normalized constraint violation
      % to the penalty term
      pop(i).penalty = pop(i).penalty + abs( (pop(i).fitness(params.conList(j).name) - params.conList(j).limit)/normVal );
    end    
  end % End loop over constraints
end % End loop over individuals in population