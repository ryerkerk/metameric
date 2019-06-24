% Matt Ryerkerk - Michigan State University - June 2019
% 
% This operator performs muation on a single variable value.
%
% Different variable types are handled differently. All variable types will respect the 
% variable bounds defined by the variable structure. If the variable value is currently equal
% to one of the bounds there is a 50% chance that the variable will "mutate" against those bounds
% and it's value will remain unchanged.
%
% REAL variables can take on any value within the bounds. 
% INTEGER variables are rounded to nearest integer, other than original value, in direction of
%   mutation. 
% DISCRETE variables are rounded to nearest permissible value, other than original value, in
%   direction of mutation
% ENUMERATED variables randomly select a new value. 
%
% inputs: (blank indicates the parameter is not used by this function)
%  var: Variable object for value getting mutated
%  value: value prior to muation
%  mag: mutation magnitude, equal to params.mutationMagnitude
%
% outputs: (blank indicates the value is returned unmodified)
%  new_value: mutated variable value

function new_val = MutateVariable(var, old_val, mag)

d = (var.upper - var.lower)*mag; % Mutation step

% Mutation variable value. The RandNorm function will enforce the variable bounds
new_val = RandNorm(var.lower, var.upper, old_val, d); 


% Certain adjustments may need to be made depending on variable type:
if (var.type == Variable.REAL) 
  % Real valued variables remain as returned by RandNorm.
elseif (var.type == Variable.INTEGER) % If we have an integer value
  % Integer variables are rounded to nearest integer in direction of mutation, other than old_val.
  %
  % If old_val is equal to variable bounds, and mutation is pushing against those bounds, then
  % new_val may remain equal to old_val.
  if (round(new_val) == old_val)
    new_val = old_val + sign(new_val - old_val);
  else % If rounded value is not equal to current value, just place the current value into the genome
    new_val = round(new_val);
  end

elseif (var.type == Variable.DISCRETE) % If we have a discrete value
  % Discrete variables are rounded to nearest permissible value in direction of 
  % mutation, other than old_val.
  %
  % If old_val is equal to variable bounds, and mutation is pushing against those bounds, then
  % new_val may remain equal to old_val
  
  potentialValues = var.discValues(:); % List of potential discrete values
  if (sign(new_val - old_val) == 1) % If new value is greater than current value:
    potentialValues(potentialValues <= old_val) = []; % Only consider values greater than current value
  elseif (sign(new_val - old_val) == -1) % If new value is less than current value:
    potentialValues(potentialValues >= old_val) = []; % Only consider values less than to current value
  elseif (sign(new_val - old_val) == 0) % New value is same as current value:
    potentialValues = new_val; % The value will remain the same, its mutating against the variable bounds
  end

  [~, order] = sort(pdist2(new_val, potentialValues)); % Find potential value closest to new value
  new_val = potentialValues(order(1)); % Assign nearest value

elseif (var.type == Variable.ENUMERATED) % If we have an enumerated value
  % Enumerated variables are simply re-sampled from all permissible (integer) values. 
  % Since we have no information about the relation between variable values this is the best
  % we can do. 
  
  new_val = randi([var.lower, var.upper]);        
end