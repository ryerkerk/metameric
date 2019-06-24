% Matt Ryerkerk - Michigan State University - June 2019
%
% The repair operator can act as a repair, a filter, or both.
%
% This particular operator applies no filter or repair. Instead every child
% provided will be marked as "accepted" to the child population.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params:
%  outputs:
%  pop:
%  childPop:
%  child:
% 
% outputs: (blank indicates the value is returned unmodified)
%  child: 
%  params:
%  outputs:
%  acceptFlag: A value of 1 indicates the child should be accepted, a
%    value of 0 indicates the child should be discarded

function [child, params, outputs, acceptFlag] = Filter_None(params, outputs, pop, childPop, child)

acceptFlag = 1; 
