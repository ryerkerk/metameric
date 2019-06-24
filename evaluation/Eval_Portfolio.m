% Matt Ryerkerk - Michigan State University - June 2019
%  
% Performs evaluation of the portfolio problem. Each metavariable define an real-valued asset
% amount, and integer valued asset number. Multiple metavariables might define the same asset, in
% which case the amounts are simply summed together. 
%
% The asset amounts relative to other assets are important, but the amounts themselves are
% arbitrary. For example, a genome that defines a portfolio with 1 unit of asset A and 2 units of
% asset B is equivalent to a portfolio with 0.5 units of A and 1 unit of B. 
% 
% The methodology for evaluating the portfolio is taken from "Heuristics for cardinality constrained 
% portfolio optimisation" by Chang et al. (2000). Historical data from S&P 100 is used for the
% assets. This data is contained in port4.mat, the raw data can be found in port4.txt downloaded 
% from http://people.brunel.ac.uk/?mastjjb/jeb/orlib/portinfo.html 
%
%
% inputs:
%    nodes (N, 2): Each row is an asset, defined by an (amount, type)
%
% Output: 
%    All fitness values contained in the "fitness" map
%       fitness('Number of Assets'): Number of unique assets in portfolio
%       fitness('Risk'): Portfolio risk
%       fitness('Return'): Portfolio return
%       fitness('ReturnTCost'): Portfolio return while assuming a small transaction cost (see below)
  
function fitness = Eval_Portfolio(assets)

fitness = containers.Map('KeyType', 'char', 'ValueType', 'double');

persistent corr; 
persistent ret;
persistent std;

if (nargin == 0) % Load asset data
  load('port4', 'corr_saved', 'ret_saved', 'std_saved')  
  corr = corr_saved;
  ret = ret_saved;
  std = std_saved;
  return;
end

if (isempty(assets))
  fitness('Number of Assets') = 0;
  fitness('Return') = 0;
  fitness('Return TCost') = 0;
  fitness('Risk') = 0;
  return
end

% s will contain the total amount of each asset
s = zeros(1,length(ret));
for i = 1:size(assets, 1) % Add asset amounts from each metavariable into s
  s(assets(i,2)) = s(assets(i,2)) + assets(i,1);
end

tots = sum(s);
count = sum(s > 0);

% w is the proportion of the portfolio held in each asset, calculated from s such that sum(w) = 1
w = zeros(1,length(ret));
for i = 1:length(w)
  if (s(i) > 0)
    w(i) = s(i)/tots;
  end
end

nzw = find(w > 0); % Non-zero assets
R = 0; % Return
risk = 0;
for i = 1:length(nzw) % For each asset in the portfolio
  R = R + w(nzw(i))*ret(nzw(i)); % Equation (2) of Chang  
  for j = 1:length(nzw)          % Plus covariance risk
    % Equation (1) of chang
    risk = risk + w(nzw(i))*w(nzw(j))*corr(nzw(i),nzw(j))*std(nzw(i))*std(nzw(j));
  end
    
end

% 'Return TCost' below is the return whle assuming a small transaction cost for each asset, applying
% a pressure toward shorter solutions. Each metavariable is assumed to incur a transaction cost,
% even if two metavariables represent the same asset. An optimal solution will use only one
% metavariable for each asset in the portfolio when assuming this transaction cost.
fitness('Number of Assets') = count;
fitness('Return') = R;
fitness('Return TCost') = R - size(assets, 1)*2e-5;
fitness('Risk') = risk;
