% Matt Ryerkerk - Michigan State University - June 2019
%
% This is the primary script of the metameric evolutionary algorithm. It is the final script called
% by the setup file, after both the problem and algorithm scripts have been called. 

origParams = params; % Save the original set of parameters, a few are updated during the study

for w = 1:params.numTrial
  params = origParams; % Revert parameters back to original
  params.trialNumber = w; % Mark trial number
  
  % Seeding the RNG will allow studies to be duplicated if desired.
  % Each trial will have a different random seed.
  % params.rngVal should be set to integer values. The formula for the seed is such that any two
  % studies with the same numTrial will have no overlapping seeds. For example, if a study usng 100 trials and 
  % .rngVal = 1 then the seeds will vary from 101-200, if .rngVal = 2 then seeds vary from 201-300.  
  params.rngSeed = w+params.rngVal*params.numTrial; % Record the seed for future reference
  rng(params.rngSeed, 'twister')
  
  inc_save = [params.saveName '_' num2str(w)]; % Incremental save name for this particular trial
  if (exist(['saved_trials/' params.saveName '/' inc_save '.mat'], 'file')) % If this trial has already been run then move onto next.
    disp(['Detected trial: ' num2str(w) ', continuing'])
    continue;
  end
    
  params.evaluationFunction(); % Call evaluation function once to allow it to setup persistent variables
  
  inc_pop = {};        % The population will be periodically stored here for postprocesing or debugging purposes
  inc_pop_evals = [];
  outputs = struct;    % Initialize outputs structure

  params.curGen = 1; % Set current generation count to 1.
  params.curEvalCount = 0; % Set current evaluation count to 0;
  
  pop = Initialize_Random(params);   % Initialize initial population
  [params, pop] = EvaluatePopulation(params, pop); % Evaluate initial opulation
  
  % Run the selection operator, while the population will remain the same
  % there may be some values in the params or output structures that are
  % updated.
  [params, outputs, pop] = params.selectionOperator(params, outputs, pop, []);
  
  % Now, start the main optimization loop.
  while(params.curEvalCount < params.evalLimit) % Continue until we have reached our number of evaluations limit.
    params.curGen = params.curGen + 1;  % Increment generation by 1.
 
    [params, outputs, childPop] = Create_Child_Population(params, outputs, pop); % Create child population
    [params, childPop] = EvaluatePopulation(params, childPop); % Evaluate the child population    
    [params, outputs, pop] = params.selectionOperator(params, outputs, pop, childPop); % Perform selection
    
    % Occasionally record the current population for future reference
    if (mod(params.curGen,100) == 0)
      inc_pop{end+1} = pop; %#ok<SAGROW>
      inc_pop_evals(end+1) = params.curEvalCount; %#ok<SAGROW>
    end
    
    % Display some output. 
    % f*, L*, p* are objective function value, length, and penalty of best solution respectfully
    if (mod(params.curGen,10) == 0)
      fprintf('Trial #: %3i, Evals: %6i, f*: %4.4g, L*: %3i, p*: %4.4g, study name: %s \n', w, params.curEvalCount, ...
        outputs.bestFit(params.curGen), outputs.bestLength(params.curGen), outputs.bestPen(params.curGen), params.saveName)   
    end
    
  end  
  inc_pop{end+1} = pop; %#ok<SAGROW> Record final population
  inc_pop_evals(end+1) =  params.curEvalCount;  %#ok<SAGROW> 
  
  names = {'params', 'outputs', 'inc_pop', 'inc_pop_evals'};
  parsave(params.saveName, inc_save, names, params, outputs, inc_pop, inc_pop_evals);
end