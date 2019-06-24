% Matt Ryerkerk - Michigan State University - June 2019
%
% This script sets up a few additonal parameters prior to beginning the study. 

% If a hidden- or static- metavariable representation is used then an additional
% 'activeFlag' binary variable is added to the variable list. This controls whether
% each metavariable is active or not. 
if (params.hiddenMetavariable == 1 || params.staticMetavariable == 1)
  nV = Variable;
  nV.name = 'activeFlag';
  nV.type = Variable.ENUMERATED;
  nV.lower = 0;
  nV.upper = 1;
  params.varList(end+1) = nV;
  params.hiddenMetavariableIndex = length(params.varList);
  if (params.maxInitialMetavariables > params.hiddenGenomeLength)
    params.maxInitialMetavariables = params.hiddenGenomeLength;
  end
end

% Calculate range for each Variable. Also set .lower and .upper for
% discrete variables
for i = 1:length(params.varList)
  if (params.varList(i).type == Variable.DISCRETE)
    params.varList(i).upper = max(params.varList(i).discValues);
    params.varList(i).lower = min(params.varList(i).discValues);
  end
  
  % Calculate variable range
  params.varList(i).range = params.varList(i).upper - params.varList(i).lower;
end

if isfield(params, 'windowFunction') && isequal(params.windowFunction, @WindowFunction_Fixed)
  disp('A fixed window niching operator was selected. Please make sure that the minimum and maximum number of metavariables are set appropriately')
end

% Save a copy of the initial study workspace for future reference.
save([params.saveName '_Setup'])

