% Matt Ryerkerk - Michigan State University - June 2019
%  
% This function creates the child Individual objects, assigns them their new 
% genome, and compare that genome to the parent solutions.
%
% inputs: (blank indicates the parameter is not used by this function)
%   params.varList: Used to compare the resulting children to parent solutions
%   outputs: Unused
%   c1, c2: New child genotypes created by crossover
%   parent1, parent2: Parent Individual objects
%
% Outputs:
%   params, outputs: Unchanged by this function
%   child1, child2: Resulting child objects

function [params, outputs, child1, child2] = SetChildrenCrossover(params, outputs, c1, c2, parent1, parent2)

% Create child individuals
child1 = Individual; 
child2 = Individual;

% Insert newly formed genotypes
child1.genome = c1; 
child2.genome = c2; 

% Mark children as unmodified at the moment, will update this in a moment
child1.changes = 0;
child2.changes = 0;

% Finally, check if the children are different from either parent. If they
% are, then update the child.changes value. 
[d1] = MetavariableDissimilarity(child1.genome, parent1.genome, [params.varList.range], [params.varList.type], params);
[d2] = MetavariableDissimilarity(child1.genome, parent2.genome, [params.varList.range], [params.varList.type], params);

if (d1 > 0 && d2 > 0) % If c1 is different from both parents then a change has occurred
  child1.changes = bitor(child1.changes, Individual.CROSSOVER);
  child2.changes = bitor(child2.changes, Individual.CROSSOVER);  
end

return
