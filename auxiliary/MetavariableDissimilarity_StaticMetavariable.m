% Matt Ryerkerk - Michigan State University - June 2019
%
% This function assumes the static-genotype is "black-box", and that we do not
% have access to it. As a result we can only meaningfully compare metavariables
% that occupy the same locus of the genome.
%
% inputs: (blank indicates the parameter is not used by this function)
%  g1: The first genome, with length g1L
%  g2: The second genome, with length g2L
%  vars: The design variables defined in each genome, a vector of Variable
%    objects
%
% Outputs:
%  total_dissimilarity: The dissimilarity between the two parents
%  MVDis: A (g1L,gxL) matrix

function [total_dissimilarity, MVDis] = MetavariableDissimilarity_StaticMetavariable(g1, g2, vRange, vType, params)

g1L = size(g1, 1); % Length of first genome
g2L = size(g2, 1); % Length of second genome

if (g1L == 0 || g2L == 0)
  total_dissimilarity = 0; 
  MVDis = [];
  return;
end

MVDis = zeros(g1L,1); % Matrix containing the dissimilarity of every pair of metavariables between the two solutions.
flagIndex = params.hiddenMetavariableIndex;

for j = 1:size(g1,2) % For each variable (size(g1,2) == number of vaiables)
  if (j==flagIndex) % Don't count active flag here, will be handled by next bit
    continue;
  end
  % All metavariables are compared at once for each variable.
  if (vType(j) == 4) % If vType==4 then the variable is enumerated
    MVDis = MVDis + (g1(:,j) ~= g2(:,j)); % Add a "1" for each dissimilar pair.
  else
    MVDis = MVDis + abs(g1(:,j) - g2(:,j))/vRange(j); % Add dissimilarity of each variable pair to matrix
  end
end

MVDis = MVDis/(max(1,size(g1,2) - 1)); % Normalize by number of variables other than flag. If only flag just leave as is.

for i = 1:g1L % For every pair of variables
  if (g1(i,flagIndex) == 0 && g2(i,flagIndex) == 0)
    MVDis(i) = 0; % Don't count differences in two unexpressed metavarables
  elseif (g1(i,flagIndex) == 1 && g2(i,flagIndex) == 1)
    % If both metavariables are expressed do nothing, leave dissimilar equal to what was measured above
  else % Otherwise one is expressed and one isn't set their dissimilarity to the max (1)
    MVDis(i) = 1;
  end
end

total_dissimilarity = sum(MVDis)/(g1L); % Calculate total dissimilarity between metavariables occupying same locus
                                        % Note that we normalize by fixed length here (See equation (4.3) in dissertation)
