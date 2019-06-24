% Matt Ryerkerk - Michigan State University - June 2019
%
% This pairing function randomly pairs together parents regardless of any
% other criteria.
%
% inputs: (blank indicates the parameter is not used by this function)
%  params:
%  outputs:
%  pop: Parent population, a vector of Individuals
%
% outputs: (blank indicates the value is returned unmodified)
%  params:
%  outputs:
%  pairs: An N/2 x 2 array, where N is the number of solutions in Pop. Each
%    row represents a pair of parents.

function [params, outputs, pairs] = Pairing_Random(params, outputs, pop)

pairs = zeros(ceil(length(pop)/2), 2); % Empty pairs
pairs(1:length(pop)) = randperm(length(pop)); % Randomly place numbers from 1 to length(pop) in the pairs

% If the population size is odd then one solution will be left without a pair.
% In this case we randomly select one more solution to pair with the odd one out.
% We ensure that the randomly selected solution isn't the same as the odd one out.
if (pairs(end,2) == 0)
  s = setdiff(1:length(pop), pairs(end, 1)); % Solutions other than the one remaining
  pairs(end,2) = s(randi([1 length(s)])); % Randomly select solution from this left
end
