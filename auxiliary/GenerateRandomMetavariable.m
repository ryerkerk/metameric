% Matt Ryerkerk - Michigan State University - June 2019
%
% Generate a random metavariable.
%
% inputs: (blank indicates the parameter is not used by this function)
% varList: is a vector of the design variables in the metavariable. See the
%    Variable class for additional information.
% num: The number of metavariables to produce
%
% Outputs:
% metaVariables: A num*length(varList) size matrix with containing the newly
%    generated Metavariables. 


function [metaVariables] = GenerateRandomMetavariable(varList, num)

metaVariables = zeros(num, length(varList)); 

for i = 1:num % For num metavariables
  for k = 1:length(varList) % For each design variable in the metavariable	                          
    if (varList(k).type == Variable.REAL) 
      % If real, choose a random value between lower and upper bounds
      metaVariables(i,k) = rand*(varList(k).upper - varList(k).lower) + varList(k).lower;
    elseif (varList(k).type == Variable.DISCRETE)
      % If discrete, select a random value from list of potential values
      metaVariables(i,k) = varList(k).discValues(randi(length(varList(k).discValues)));        
    elseif (varList(k).type == Variable.INTEGER)
      % If integer, select a random integer between lower and upper bounds
      metaVariables(i,k) = randi([varList(k).lower, varList(k).upper]);      
    elseif (varList(k).type == Variable.ENUMERATED)
      % If enumerated, select a random index between lower/upper bounds. 
      metaVariables(i,k) = randi([varList(k).lower, varList(k).upper]);
    end
  end
end