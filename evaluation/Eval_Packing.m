% Matt Ryerkerk - Michigan State University - June 2019
%  
% Evaluates the packing problem. Each metavariable defines a small or large circle. This function
% calculates the "cost" of all circles (this is a bit of a misnomer since we want to maximize the
% "cost"), and any overlap between the circles or between the circles and 
% region outside the domain boundary. 
%
% Each node is defined by [x, y, size]. A size of 0 is a circle with a radius of 0.15 and a cost of
% 1, and a size of 1 is a circle with a radius of 0.25 and a cost of 3. 
%
% inputs:
%    nodes (N, 3): Each row is a metavariable (circle), each node defined by (x, y, size)
%
% Output: 
%    All fitness values contained in the "fitness" map
%       fitness('Cost'): "Cost" of set of circles, we want to maximize this.
%       fitness('Overlap'): Overlap between circles or circles and outside of domain

function fitness = Eval_Packing(circles)

fitness = containers.Map('KeyType', 'char', 'ValueType', 'double'); 

if (nargin == 0)
   return;
end

cost = sum(circles(:,3)==0)*1 + sum(circles(:,3)==1)*3; % Calculate "Cost"

circles(circles(:,3)==0,3) = 0.15; % Replace small and large circles (0, and 1 respectively) with
circles(circles(:,3)==1,3) = 0.25; % actual radii

% NOTE: There was a small error in this code when I ran the dissertation. The overlap between two
% circles are counted twice. This means there will be a greater pressure to separate two overlapping
% circles than to shift a circle that is overlaping with the area outside of the allowable domain. 
%
% I've left the error intact to maintain the reproducibility of the dissertation trials. To correct
% this, change the "for j = 1:size(circles, 1)" loop to "for j = i+1:size(circles, 1)"

overlap = 0; % Overlap between two circles
for i = 1:size(circles, 1)
  r1 = circles(i,3);
  for j = 1:size(circles, 1)
    if (i == j)
      continue
    end
    r2 = circles(j,3);
    
    d = sqrt(sum((circles(i,1:2) - circles(j,1:2)).^2));
    if (d < (r1+r2)) % They're touching;
      minr = min([r1 r2]);
      maxr = max([r1 r2]);
      
      if ( ((maxr-d) > minr) || (d == 0) ) % If smaller circle is completely enveloped by larger. Or two circles of the same size are concentric.
        overlap = overlap + pi*minr*minr;
      else
        overlap = overlap + r1^2*acos((d^2+r1^2-r2^2)/(2*d*r1)) + r2^2*acos((d^2+r2^2-r1^2)/(2*d*r2)) - 1/2*sqrt( (-d+r1+r2)*(d+r1-r2)*(d-r1+r2)*(d+r1+r2));
      end
    end    
  end

  r1 = circles(i,3);
  if (abs(2-circles(i,1)) < r1)
    theta = acos(abs(2-circles(i,1))/r1); 
    overlap = overlap + r1*r1*(theta - cos(theta)*sin(theta)); 
  end
  
  if (abs(2-circles(i,2)) < r1)
    theta = acos(abs(2-circles(i,2))/r1); 
    overlap = overlap + r1*r1*(theta - cos(theta)*sin(theta));
  end
  
  if (circles(i,1) < r1)
    theta = acos(abs(circles(i,1))/r1); 
    overlap = overlap + r1*r1*(theta - cos(theta)*sin(theta)); 
  end
  
  if (circles(i,2) < r1)
    theta = acos(abs(circles(i,2))/r1); 
    overlap = overlap + r1*r1*(theta - cos(theta)*sin(theta)); 
  end  
end

fitness('Cost') = cost;
fitness('Overlap') = overlap;