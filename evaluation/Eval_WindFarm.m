% Matt Ryerkerk - Michigan State University - June 2019
%
% Evaluate function for wind farm layouts. Each metavariable represents 
% an x- and y- position of a turbine. 
%
% The parameters and methodology used are based off papers by:
% Mosetti et al. Optimization of wind turbine positioning in large windfarms by means of a genetic algorithm, Journal of Wind Engineering and Industrial Aerodynamics, 1994
% Grady et al. Placement of wind turbines using genetic algorithms, Renewable Energy, 2005
%
% inputs: (blank indicates the parameter is not used by this function) 
%   turbines: A (N,2) sized vector defining the location of each turbine.
% Outputs: 
%   fitness('Power'): Total power produced
%   fitness('Efficiency'): Overall efficiency of the wind farm
%   fitness('Cumulative Distance Violation'): Total spacing violations between turbines. Feasible solutions will be 0
%   fitness('Cost Per Power') : Cost per unit power produced

function fitness = Eval_WindFarm(turbines)

% This problem requires no initial setup, just return an empty fitness
if (nargin == 0) % Nothing to setup for this problem, just return
  fitness = [];
  return; 
end

fitness = containers.Map('KeyType', 'char', 'ValueType', 'double');

% Wind turbine/environmental parameters, taken from the Mosetti and Grady papers
rr = 20; % Radius of turbine rotor (m). Note that Table 1 of Grady incorrectly lists radius as 40m, 
         % but states several times that the diameter is 40m is other parts of the paper
z = 60; % Height of turbine hub (m), taken from Table 1 in Grady et al.
z0 = 0.3; % Ground roughness, value from Section 4 of Grady et al.
CT = 0.88; % Thrust coefficient, taken from Table 1 in Grady et al.
alpha = 0.5/log(z/z0); % Entrainment constant, Eq (4) in Grady et al.
a = (1-sqrt(1-CT))/2; % Axial induction factor, derived from Eq (3) in Grady et al.
r1 = rr*sqrt( (1-a)/(1-2*a)); % Down stream radius, Eq (2) in Grady et al.

% Wind speed parameters
% Case (b) Grady 2005, equal chance of wind in all directions
% Lengths of u0, phi, and freq must match
u0 = 12*ones(1,36);   % The magnitude of the wind speed for each case (m/s)
phi = 0:10:350;         % The direction of the wind (Degrees ccw from +x direction)
freq = 1*ones(1,36);  % The relative frequency that wind has this particular magnitude and direction

% Get unit vectors for each wind direction
phi_unit = [cosd(phi)' sind(phi)'];
phi_unit_perp = [cosd(phi+90)' sind(phi+90)'];

power = 0; % Power in wind farm
max_power = 0; % Power if wind farm was 100% efficient

dist = pdist(turbines) - 10*rr; % Distance between turbines minus 10 times turbine radius. 
                            % Turbines must be at least 10*rr apart for the solution to be feasible
                            % Any negative values here indiciate the constraint is violated.
dist(dist > 0) = 0;         % Set any distances greater than 0 to 0
distViolation = sum(abs(dist));   % Sum together all violations

dx = pdist2(turbines(:,1), turbines(:,1), @minus)'; % dx(i,j) is turbines(i,1) - turbines(j,1), the difference in x-location
dy = pdist2(turbines(:,2), turbines(:,2), @minus)'; % dy(i,j) is turbines(i,2) - turbines(j,2), the difference in y-location

if(size(turbines, 1) == 1)
  dx = 0; dy = 0; % Above couple lines don't work if only one turbine
end

for dir = 1:length(phi) % For each wind case
  d_parallel = dx.*phi_unit(dir,1) + dy.*phi_unit(dir,2); % The distance between turbines in the direction parallel to wind
  d_perp = abs(dx.*phi_unit_perp(dir,1) + dy.*phi_unit_perp(dir,2)); % The distance between turbines in the direction perpindicular to the wind
    
  % Wake flag tracks which turbines are in the wake of other turbines
  % If wakeFlag(i,j) = 1 then turbine j is in the wake of turbine i
  wakeFlag = ones(size(d_parallel)); % Assume all turbines are in each others wake to begin.
  wakeFlag = wakeFlag - eye(size(wakeFlag)); % Mark each turbine such that its not in its own wake.
  wakeFlag(d_perp > (rr + alpha.*d_parallel)) = 0; % Turbines that are located outside the wake of another turbine
  wakeFlag(d_parallel < 0) = 0; % Turbines that are upstream from other turbines.
  
  % Modify effective wind speeds for turbines that are caught in wakes.
  bot = 1./(1+alpha.*(d_parallel./r1)).^2; % Denominator in `Eq(1) of Mosetti and Grady. Note that Grady forgot the ^2 for this term
  u = u0(dir).*(1-2*a*bot);                % Rest of Eq(1).
  u(wakeFlag == 0) = u0(dir);              % Set u back to u0 for cases where wake isn't present
  ui = u0(dir).*(1-sqrt(sum((1-u./u0(dir)).^2))); % Now get effective wind speed for each turbine, Eq (5) in Grady
  ui(ui < 0) = 0;    % In rare cases its possible that a turbine has so much wake that a negative effective wind speed is returned.
                     % When this occus just set the effective wind speed to 0.
  
  power = power + 0.3*sum(ui.^3)*freq(dir)/sum(freq);   % Add together power from turbines. Eq (8) in Grady, note that was scale this based on wind frequency
  max_power = max_power + length(ui)*0.3*(u0(dir)^3)*freq(dir)/sum(freq);  % Power if no wake was present (100% efficiency)
end

cost = size(turbines, 1)*(2/3+1/3*exp(-0.00174*(size(turbines, 1))^2)); % Cost of windfarm. Eq (6) of Grady.

fitness('Power') = power;  % Power generated for this wind case
fitness('Efficiency') = power/max_power; % Overall efficiency of wind farm
fitness('Cumulative Distance Violation') = distViolation; % Culmative distance violation
fitness('Cost Per Power') = cost/power;

   
       