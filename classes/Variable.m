% Matt Ryerkerk - Michigan State University - June 2019
%
% The variable class contains the definition of each design variable in the
% optimization problem. Generally a set of Variable instances will be
% contained in the 'params' structure.
% 
% The Individual class contains a genome property, which is an array
% containing the design variable values for a particular solution. There is
% no metavariable class, instead each row of the genome is considered a metavariable. 

classdef Variable
   properties(Constant)      
     REAL=1;
     INTEGER=2;
     DISCRETE=3 ;
     ENUMERATED=4;
   end
   properties
      type;              % Type of variable (e.g., Variable.REAL)                         
      name@char;         % Variable name (e.g. 'radius')
      lower@double;      % Lower bound value
      upper@double;      % Upper bound value
      discValues@double; % Only applicable to discrete variables, a set of the applicable values
      range@double;      % Range of variable
   end
   
   methods
     
   end
end