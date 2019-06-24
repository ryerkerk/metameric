% Matt Ryerkerk - Michigan State University - June 2019
%
% The Constraint class contains the definition of each constraint in the
% optimization problem. Generally a set of Constraint instances will be
% contained in the 'params' structure.
%
% The constraint types are either LESSTHAN, MORETHAN, or EQUALTO a specified limit
% A value equal to the limit is considered to satisfy the constraint, so
% the constraint is either <=, >=, or == the limit. 
%
% Care needs to be taken when using equality constraints. These can be very difficult
% to satisfy and the code does not currently support relaxation. If necessary the 
% equality may be represented as two inequality constraints to provide a defined
% level of relaxation.

classdef Constraint
  properties (Constant)
    LESSTHAN = 1                 % Enumerated variables to track constraint type
    MORETHAN = 2
    EQUALTO = 3
  end
  
   properties
      type;                      % Either Constraint.LESSTHAN, Constraint.MORETHAN, or Constraint.EQUALTO
      
      limit@double;              % The response needs to either less than or greater than (or equal) to the limit value
      
      name@char;                 % The name of the fitness value that the constraint acts on. 
                                 % The evaluation function needs use the same names defined by the user when returning
                                 % fitness values
   end
   
   methods
       
   end
end