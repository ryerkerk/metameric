% Matt Ryerkerk - Michigan State University - June 2019
%
% Create a new value using a normally distributed random number.
% New value is bounded based on input.
%
% inputs: (blank indicates the parameter is not used by this function)
%   lower: Lower bound of new value
%   upper: Upper bound of new value
%   mean: Initial value
%   std: Magnitude of the normally distributed random number
%
% Outputs:
%   val: New value

function val = RandNorm(lower, upper, mean, std)

val = mean + randn*std; % Generate new value

% Ensure that value remains within bounds
if (val > upper)
  val = upper;
end

if (val < lower)
  val = lower;
end
