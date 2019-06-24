% Matt Ryerkerk - Michigan State University - June 2019
%
% The Objective class contains the definition of each objective in the
% optimization problem. Generally a set of Variable instances will be
% contained in the 'params' structure.
% 
% The objective values for a particular solution will be contained in the
% Individual class. 

classdef Objective
   properties(Constant)
     MINIMIZE = 1                % Enumerated values to track objective type
     MAXIMIZE = 2
   end
   properties
      type;                      % Objective type, either Objective.MINIMIZE or Objective.MAXIMIZE
      
      name@char;                 % User defined name for objective, "mass" or "deflection", for example. 
                                 % The evaluation function needs use the same names defined by the user when returning
                                 % fitness values                                 
   end
   
   methods
       
   end
end