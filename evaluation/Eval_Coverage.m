  % Matt Ryerkerk - Michigan State University - June 2019
  %  
  % Performs evaluation of the coverage problem. We assume a 2x2 domain to be covered.
  % 
  % Coverage is approximated by creating a grid of points spaced 0.01 apart. The 
  % portion of these points covered is an approximation of coverage of the entire domain.
  %
  % This function needs to be called once with no inputs to initialize the grid.
  %
  % Each node is defined by [x, y, radius]
  % An x- and y- position are always required for each metavariable
  % This function works several ways depending on how radius is defined:
  %   -If all radii are 0 or 1 then we assume:
  %        0 maps to a small sensors, with radius 0.15 and cost 3
  %        1 maps to a large sensor, wth radius 0.25 and cost 25
  %   -If the radii include non-intergers values then each node has a radius
  %         equal to the input value. Cost is equal to the radius.
  %   -If no radii are given then all sensors are assumed to be "large" sensors.
  %
  % inputs:
  %    nodes (N, 2 or 3): Each row is a metavariable (node), each node defined by (x, y, radius)
  %
  % Output: 
  %    All fitness values contained in the "fitness" map
  %       fitness('Coverage'): Proportion of domain covered (between 0 and 1)
  %       fitness('Weighted Sum Fitness'): A weighted sum of total node cost and uncovered area
  %       fitness('Cost'): Proportion of domain covered (between 0 and 1)

function fitness = Eval_Coverage(nodes)

fitness = containers.Map('KeyType', 'char', 'ValueType', 'double'); 
persistent pts;

if (nargin == 0) % If no inputs are given initialize the grid
    step = 0.01;    % Spacing between points
    [x, y] = meshgrid(0:step:2);
    pts = [x(:) y(:)];     
    return;
end

if (size(nodes, 2) == 2) % If no node radii are given ...
  nodes(:,3) = 0;  % ...make them all large
end

% When using static-metavarables the design variables end up ordered as (radius, x, y). 
% If all values in the first column are less than 0.3 then it is likely that the static-metavariable
% representation was used. In that case rearrange the genome such that each metavariable defines 
% (x, y, radius). 
if (all(nodes(:,1) < 0.3) & any(nodes(:,2:3) > 0.3)) % Range appears first
  nodes = nodes(:,[2 3 1]); % Reorder so variables are x,y,radius
end

% If all range values are integers then assume that problem is defning small and large sensors using
% range=0 and range=1 respectively. 
if (all(mod(nodes(:,3), 1) == 0)) % All radii are integer values
  cost = sum(nodes(:,3)==0)*3 + sum(nodes(:,3)==1)*7;
  nodes(nodes(:,3)==0,3) = 0.15; 
  nodes(nodes(:,3)==1,3) = 0.25; % Insert actual node radii to evaluation function.
else  % Otherwise radius is equal to nodes(:,3) 
  cost = sum(nodes(:,3));   
end

flag = zeros(size(pts, 1),1); % flag will track which points are covered by at least one node
for k = 1:size(nodes, 1) % For each node
    c = nodes(k,1:2); % Center of his node
    r2 = nodes(k,3)^2; % Radius of node squared
    d = (pts(:,1)-c(1)).^2 + (pts(:,2)-c(2)).^2; % Squared distance of every pt to this node
    flag = flag | d<r2; % Mark pts within radius of node    
end

in_range = sum(flag); % Number of points covered by at least one node
out_range = sum(flag==0); % Number of points not coverted by at least one node.

% Some problems use a weighted sum of total node cost and portion of domain left uncovered
objective = cost + 50*(1-in_range/(in_range+out_range)); 

fitness('Coverage') = in_range/(in_range+out_range);
fitness('Weighted Sum Fitness') = objective;
fitness('Cost') = cost;
