% Matt Ryerkerk - Michigan State University - June 2019
%
% In score selection each solution is assigned a score based on its objective 
% function value, constraint violation penalty, and dissimilarity to other
% solutions in the niche. This allows for some relaxation of the constraints
% when selecting solutions, and helps to promote a more diverse population in 
% terms of genotypic dissimilarities. 
%
% See Chapter 7.3.2 for a detailed methodology. 
%
% Note that this operator currently only works for single objective problems.
%
% inputs: 
%  params.curGen: Current generation
%  params.objList: List of objectives
%  params.varList: List of variables, used by dissimilarity function
%  params.FDecayRate: Rate of decay of trend in best solution fitness 
%  outputs.F: Objective function value trend of best solution at each generation
%  outputs.bestFit: Objective function value of best solution at each generation
%  outputs.bestPen: Constraint violation penalty of best solution at each generation
%  candSolus: Vector of Individuals from which to select
%  nicheSize: Number of solutions to select from candSolus
%
% outputs: (blank indicates the value is returned unmodified)
%  params: 
%  outputs.dHist: records average dissimilarity between solutions
%  X: The selected set of solutions

function [params, outputs, X] = LocalSelection_Score(params, outputs, candSolus, nicheSize)

% If there are no candidate solutions then return an empty niche population
if (isempty(candSolus))
  X = [];
  return;
end

% Calculate trend in objective function value F. 
% F will be likely calculated and recorded multiple times each generation, since
% this function is called once for each niche. However, each niche will get the
% same value for F during a single generation. 
if (params.curGen > 1 && outputs.bestPen(params.curGen-1) == 0) % Only calculate if the previous generation had feasible solutions
  % Calculate F by equation (7.10)
  F = outputs.F(params.curGen-1)*exp(-params.FDecayRate) + ...
          (outputs.bestFit(params.curGen) - outputs.bestFit(params.curGen-1));
else % For first generation, or if no feasible solutions exist, set F to 0
  F = 0; 
end
outputs.F(params.curGen) = F; % Record the new bias factor value

fit = shiftdim([candSolus(:).fitVals]); % Fitness of candidate solutions
pen = shiftdim([candSolus(:).penalty]); % Penalty of solutions

% Flip sign on objective function value if this is a maximization problem
if (params.objList(1).type == Objective.MAXIMIZE)
  fit = fit*-1;
end

dMat = zeros(length(candSolus)); % Will record dissimilarlity between solutions
X = [];  % Candidate set of selection solutions. 
         % This will contain the index of solutions (i.e., access solutions with candSolus(X) )

vRange = [params.varList.range]; % Used by dissimilarity function
vType = [params.varList.type]; 

for i = 1:1:length(candSolus)
  % Add index of next solution to candidate pool X, forming X' (denoted as Xp here)  
  Xp = [X; i];
  
  % Get dissimilarity between new solution and every other solution in Xp, record in dMat
  for j = 1:length(Xp)-1
    dTemp = MetavariableDissimilarity(candSolus(Xp(j)).genome, candSolus(Xp(end)).genome, vRange, vType, params);
    dMat(Xp(j), Xp(end)) = dTemp;
    dMat(Xp(end), Xp(j)) = dTemp;    
  end  
  
  if (length(Xp) <= nicheSize) % If Xp is smaller than required niche size, set X = Xp and continue 
    X = Xp;
    continue;
  end
  
  % Otherwise, Xp is larger than the niche size, meaning one solution must be removed from Xp
  
  % Get minimum/maximum objective function values and penalties in X
  % Note these values are calculated using only X, not Xp, see Section 7.3.2
  nFitMax = max(fit(X));
  nFitMin = min(fit(X));
  nPenMax = max(pen(X));
  nPenMin = min(pen(X));
  
  % Identify the best solution in Xp (lowest penalty, ties broken by lower 
  % fitness, remaining ties broken randomly)  
  tab = [pen(Xp) fit(Xp) rand(size(Xp))];
  [~, temp] = sortrows(tab);
  bestXp = temp(1);
  
  % Calculate objective function value score sf, equation (7.5)
  if (nFitMax ~= nFitMin)
    sf = ((fit(Xp) - nFitMin)/(nFitMax-nFitMin));
  else
    sf = zeros(size(Xp));
  end
  
  % Calculate constraint violation score sp, equation (7.6)
  if (nPenMax ~= nPenMin)
    sp = ((pen(Xp) - nPenMin)/(nPenMax-nPenMin));
  else
    sp = zeros(size(Xp));
  end

  % Calculate dissimilarity score 
  Dmean = sum(sum(dMat(X, X)))/(length(X)^2 - length(X)); % Average dissimilarity in X, eq. (7.7) 
  % Sum of denominator in eq. (7.8). In this code we include the dissimilarity of each solution to
  % itself (which will equal 0). The -4 term is to offset this. 
  dSum = sum(1./(dMat(Xp, Xp)/Dmean+0.5).^2, 2) - 4;
  sD = dSum*1.6875/nicheSize;  % equation (7.8)                                                   
  
  % Calculate gamma (equation 7.11). Used to balance fitness and penalty scores againt dissimilarity
  % score
  gamma = 2/(1 + abs(F/(nFitMax-nFitMin)));
  if (isnan(gamma)) % Can get nan if F and (nFitMax-nFitMin) both equal zero. 
    gamma = 1; 
  end
    
  % Now, calculate total scores using equation (7.9)
  if (min(pen(Xp)) > 0) % If all solutions in Xp are infeasible
    S = sD + gamma*(sf/8 + sp); % Scores are first case of (7.9)
  else % Otherwise, if at least one solution is feasible
    p = fit(Xp) < fit(Xp(bestXp));  % Solutions with objective function values better than that of 
                                    % best feasible solution
    S = sD + gamma*(sf + sp);       % Calculate all scores using third case of (7.9)
    S(p==1) = sD(p==1) + gamma*(sf(p==1)/2 + sp(p==1) - 0.5); % Replace scores using second case of (7.9) where necessary
  end
  
  S(bestXp) = min(S)-1; % Ensure best solution in Xp will be included in X
  [~, ord] = sort(S); % Sort scores from best (lowest) to worst.
  X = Xp(ord(1:nicheSize)); % Form new X, don't include Xp soluton with worst score
end

% If all solutions are of the same length, record the average dissimilarity of solutions in X.
% This is only used for post processing purposes. 
len = [candSolus.length];
if (all(len==len(1))) % Only record dissimilarity if all solutions are of the same length
  allD = dMat(X, X);
  dSum = sum(allD(:)) - sum(diag(allD));
  outputs.dHist(params.curGen, len(1)) = dSum / (length(X)^2 - length(X));
end

X = candSolus(X); % Get selected population from candidate solutions.

return