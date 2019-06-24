% Matt Ryerkerk - Michigan State University - June 2019
%  
% Performs evaluation of a laminate composite using classical laminate theory. Each metavariable is
% expressed as 4 plies in the laminate composite, this is done to ensure a symmetric and balanced
% composite. 
%
% Currently each metavariable needs a ply angle, given as a integer in the range [1, 7], and a
% volume fraction. 
%
% The methodology, and the material properies, are taken primarily from:
% Engineering Mechanics of Composite Materials (2nd ed) by Isaac Daniel and Ori Ishai
%
% inputs:
%    layup (N, 2): Each row is a metavariable (node), each node defined by (angle, volume fraction)
%
% Output: 
%    All fitness values contained in the "fitness" map
%       fitness('Number of plies'): Number of plies in solution. Should be 4 * # of metavariables
%       fitness('Buckling Load Factor'): Load factor due to buckling.
%       fitness('Failure Load Factor'): Load factor due to material failure
%       fitness('Min Load Factor'): Equal to minimum of two load factors above. 
%       fitness('Factor of Safety'): Equivalent to load factor here. 
%       fitness('Mass'): Mass of laminate.

function fitness = Eval_LaminateLayers(layup)

if (nargin == 0)
  return % Doesn't need to be initialized but need to handle this
end
fitness = containers.Map('KeyType', 'char', 'ValueType', 'double');

angle = layup(:,1);        % Angle integer of each ply
V = layup(:,2);            % Volume fraction of each ply
[Vf, ~, Vind] = unique(V); % Vf is list of all volume fractions. Vf(Vind(i)) = V(i); 

% Material properties
% Carbon Fibers (AS-4), Values from Table A.1 and A.2 in Daniel
Ef1 = 235e9; % Pa
Ef2 = 15e9;  % Pa
Gf = 27e9;   % Pa 
nuf = 0.20;  % Poissons
pf = 1.81*1000;   % kg/m^3

% Epoxy (3501-6), From Table A.3 in Daniel
Em1 = 4.3e9; % Pa
Em2 = 4.3e9; % Pa
Gm = 1.6e9;  % Pa
num = 0.35;  % Poissons
pm = 1.27*1000;   % kg/m^3

for i = 1:length(Vf) % Calcuate effective ply properties for each volume fraction
  all_E11(i) = Ef1*Vf(i) + (Em1*(1-Vf(i)));   % Eq (3.23) of Daniel
  all_E22(i) = 1/(Vf(i)/Ef2 + (1-Vf(i))/Em1); % Eq (3.29) of Daniel
  all_G12(i) = 1/(Vf(i)/Gf + (1-Vf(i))/Gm);   % Eq (3.48) of Daniel
  all_v12(i) = nuf*Vf(i) + (num*(1-Vf(i)));      % Eq (3.24) of Daniel
  all_v21(i) = all_v12(i)*all_E22(i)/all_E11(i);
  p(i) = pf*Vf(i) + (pm*(1-Vf(i)));
end

% Material strengths:
% These are taken from Table A.4 of Daniel, which I believe were experimentally obtained from a
% carbon (AS-4) epoxy (3501-6) undirectional laminate. 
% 
% We are assuming these remain unchanged regardless of volume fraction, there will be some error
% here but it should be sufficient for our purposes.
%
% Note that we're assuming tensile and compressive strengths are equal, and setting the ultimate
% strengths equal to the compressive ones. The difference between the tensile and compressive
% strenths is significant in the transverse direction (e2u), but not so much in the longitudinal
% direction. All loads applied here are compressive so this shouldn't not be a bad assumption, but
% for other loading cases this may need to be adjusted.

e1u =  0.0117; % Longitudinal compressive strength / longtinudinal modulus
e2u =  0.0221; % transverse compressive strength / transverse modulus
g12u = 0.0109; % inplane shear strength / inplane shear modulus


% Dimensions of composite, these are arbitrary
a_dist = 500e-3;
b_dist = 100e-3; 
t = 0.1e-3;       % Thickness

% Loading conditions, again arbitrary
Nx = 900e3; % (N/m), applied along edge
Ny = 450e3;
Nxy = 0;

% Required factor of safety
fos = 1;

% Create layup
% Each "ply" in the genome will actually represent 4 plies in the solution, this is done so that we
% can ensure a balanced and symmetric laminate. 

angle_inc = 15; % Setting this to 15 means that the input orientations of [1, 2, 3, 4, 5, 6, 7]
                % are intepreted as [0, 15, 30, 45, 60, 75, 90] degrees respectfully. 
plies = [];
h = 0; % total thickness of composite;
d = 0; % Total density/m^2 of composite; 

for i = 1:length(angle) % Each ply is added to stack as a +/- stack of 2 plies to ensure balance
  plies = [plies; [(angle(i)-1)*angle_inc, Vind(i)]; [(angle(i)-1)*angle_inc*-1, Vind(i)]];
  h = h + 4*t; % *2 for balance, *2 for symmetry
  d = d + 4*p(Vind(i))*t; % *2 for balance, *2 for symmetry
end

plies = [plies; plies(end:-1:1,:)]; % Mirror laminate over midplane for symmetry
mass = d*a_dist*b_dist; % Calculate mass of laminate

bot = -h/2; % Bottom of composite

R = [1 0 0; 0 1 0; 0 0 2]; % Reuter’s matrix
iR = [1 0 0; 0 1 0; 0 0 0.5]; % Inverse Reuter’s matrix a
A = zeros(3,3); 
B = A; D = A; 

for i = 1:size(plies,1)
  ang = plies(i,1)*pi/180; % Angle in radians
  c = cos(ang);
  s = sin(ang);
  
  T = [c*c s*s 2*c*s; s*s c*c -2*c*s; -c*s c*s c*c-s*s]; % Transformation Matrix (eq 4.59 of Daniel)
  iT = [c*c s*s -2*c*s; s*s c*c 2*c*s; c*s -c*s c*c-s*s]; % inverse Transformation Matrix (eq 4.62 of Daniel)
   
  E11 = all_E11(plies(i,2)); % Get material properties for this volume fraction calculated earlier
  E22 = all_E22(plies(i,2));
  G12 = all_G12(plies(i,2));
  v12 = all_v12(plies(i,2));
  v21 = all_v21(plies(i,2)); 
  
  % Q is the compliance matrix for this ply in the material coordinate system. 
  % See Section 4.3 of Daniel
  front = 1/(1-v12*v21);     
  Q = front*[E11 v21*E11 0; v12*E22 E22 0; 0 0 G12*(1-v12*v21)]; % Note how the terms in front and the Q66 term cancel, leaving Q66=G12
  
  
  Qxy = iT*Q*R*T*iR; % Transform from material coordinates to global coordinates
  z = bot + (i-1)*t; % z-location of current ply
  
  for j = 1:3 % Equation 7.20 of Daniel to calculate A, B, D
    for k = 1:3
      A(j,k) = A(j,k) + ((z+t)-z)*Qxy(j,k);
      B(j,k) = B(j,k) + 1/2*((z+t)^2 - z^2)*Qxy(j,k);
      D(j,k) = D(j,k) + 1/3*((z+t)^3 - z^3)*Qxy(j,k);
    end
  end
end

a = inv(A); % Get strains from load, see equation 7.39 of Daniel
ex = a(1,1)*Nx + a(1,2)*Ny + a(1,2)*Nxy;
ey = a(2,1)*Nx + a(2,2)*Ny + a(2,3)*Nxy;
exy = a(3,1)*Nx + a(3,2)*Ny + a(3,3)*Nxy;

lc = 1e9; % Assume an absurd material load factor to start
for i = 1:size(plies, 1)
  % For each ply we will calculate the material load factor in each direction. 
  % lc will be set to the minimum value calculated over all plies. 
  
  ang = plies(i, 1)*pi/180; % Angle in radians
  c = cos(ang);
  s = sin(ang);
  
  lx = (c*c*ex + s*s*ey + c*s*exy)/(e1u/fos);
  ly = (s*s*ex + c*c*ey - c*s*exy)/(e2u/fos);
  lxy = (-2*s*c*ex + 2*s*c*ey + (c*c-s*s)*exy)/(g12u/fos);
  lx = 1/abs(lx);
  ly = 1/abs(ly);
  lxy = 1/abs(lxy);
  
  if (lx < lc)
    lc = lx;
  end
  if (ly < lc)
    lc = ly;
  end
  if (lxy < lc)
    lc = lxy;
  end  
end

% Calculate the minimum buckling load factor. 
% See "Improved genetic algorithm for minimum thickness composite laminate design" by Le Riche and
% Haftka (1995) for more information.
lb_hist = zeros(10,10); 
for m = 1:10
  for n = 1:10
     lb_hist(m,n) = pi*pi*(D(1,1)*(m/a_dist)^4 + 2*(D(1,2)+2*D(3,3))*(m/a_dist)^2*(n/b_dist)^2 + D(2,2)*(n/b_dist)^4) / (Nx*(m/a_dist)^2 + Ny*(n/b_dist)^2 + Nxy*(m/a_dist*n/b_dist)); 
     if ((m == 1 && n == 1 ) || (lb_min > lb_hist(m,n)))
       lb_min = lb_hist(m,n); 
     end
  end
end

min_load_factor = min(lb_min, lc);

fitness('Number of Plies') = size(plies,1);
fitness('Buckling Load Factor') = lb_min; 
fitness('Failure Load Factor') = lc; 
fitness('Min Load Factor') = min_load_factor;
fitness('Factor of Safety') = min_load_factor; 
fitness('Mass') = mass; 





