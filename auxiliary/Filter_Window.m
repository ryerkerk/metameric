% Matt Ryerkerk - Michigan State University - June 2019
%
% The repair operator can act as a repair, a filter, or both.
%
% This particular operator acts as a filter. The solution is not modified.
% If the child lies within the current selecton window then it is accepted, 
% otherwise it is marked to be discarded and replaced by another child.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params.current_window: Current selection window
%  params.hiddenMetavariable: Flag is set to 1 if hidden-metavariable representation is used
%  params.staticMetavariable: Flag is set to 1 if static-metavariable representation is used
%  params.hiddenMetavariableIndex: Index of hidden-metavariable flag, if used.
%  outputs: 
%  pop: 
%  childPop: 
%  child: The child that may or may not be filtered out
%
% outputs: (blank indicates the value is returned unmodified)
%  child:
%  params: 
%  outputs:
%  acceptFlag: A value of 1 indicates the child should be accepted, a
%    value of 0 indicates the child should be discarded

function [child, params, outputs, acceptFlag] = Filter_Window(params, outputs, pop, childPop, child)

if (~isfield(params, 'currentWindow'))
  disp('WARNING (Filter_Window): NO WINDOW SET IN SELECTION, NO FILTERING OCCURING')
  acceptFlag = 1;
  return; 
end

window = params.currentWindow; % Current niching window

% Get child solution length, only count active metavariables if using hidden- or
% static-metavariables
if (params.hiddenMetavariable == 1 || params.staticMetavariable==1)  
  len = sum(child.genome(:, params.hiddenMetavariableIndex));  
else
  len = size(child.genome, 1);
end

if (ismember(len, window))
  acceptFlag = 1; 
else
  acceptFlag = 0; 
end