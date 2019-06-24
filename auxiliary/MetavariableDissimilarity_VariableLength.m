% Matt Ryerkerk - Michigan State University - June 2019
%
% Compares two metameric genomes and returns the total dissimilarity
% between the two. Note that the genomes do not have to be the same length
% for this function to operate.
%
% First, the distance between all metavariables in each of the genomes is
% calculated. The distance is the sum of the absolute difference for
% each design variable, normalized by the defined vRange of that
% variable
%
% Then, for each metavariable in each genome the most similar (or least
% dissimilar) metavariable in the other genome is identified. The total
% dissimilarity between two solutions is the sum of the the dissimilarity
% between each metavariable and its least disimilar counterpart. This sum
% is then normalized by the total number of design variables in each of the
% genomes (# metavariables * # design variables per metavariable).
%
% inputs: 
%  g1: The first genome, with length g1L
%  g2: The second genome, with length g2L
%  vRange: Range of each design variable
%  vType: Type of each design variable (integers associated with enumerate types)
%  params.orderedProblem: Is problem ordered.
%
% Outputs: 
%  total_dissimilarity: The dissimilarity between the two parents
%  MVDis: A (g1L,g2L) matrix with the the dissimilarity between every pair of metavariables

function [total_dissimilarity, MVDis] = MetavariableDissimilarity_VariableLength(g1, g2, vRange, vType, params)

g1L = size(g1, 1); % Length of first genome
g2L = size(g2, 1); % Length of second genome

% If length of either genome is 0 then distance cannot be measured. 
if (g1L == 0 || g2L == 0)
  total_dissimilarity = 0; 
  MVDis = [];
  return;
end

if (params.orderedProblem == 1) % If its an ordered problem
  g1(:,end+1) = linspace(0,1,g1L); % Add an order index to end of genomes
  g2(:,end+1) = linspace(0,1,g2L);
  vType(end+1) = 1; % Treat index as a real variable
  vRange(end+1) = 1; % Index has a range of 1.
end

MVDis = zeros(g1L,g2L); % Matrix containing the dissimilarity of every pair of 
                        % metavariables between the two solutions.

for j = 1:size(g1,2) % For each design variable
  % All metavariables are compared at once for each variable.
  if (vType(j) == 4) % If vType==4 then the variable is enumerated
    MVDis = MVDis + (g1(:,j) ~= g2(:,j)'); % Add a "1" for each dissimilar pair. 
  else   % For all other variables
	     % Add dissimilarity of each variable pair to matrix    
    MVDis = MVDis + abs(g1(:,j) - g2(:,j)')/vRange(j); 
  end
end

% Calculate total dissimilarity by summing the dissimilarity between each 
% metavariable and its most similar counterpart
total_dissimilarity = (sum(min(MVDis, [], 1)) + sum(min(MVDis, [], 2)));

% Normalize by number of variables and number of metavariables
total_dissimilarity = total_dissimilarity/size(g1,2)/(g1L+g2L); 