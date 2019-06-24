% Matt Ryerkerk - Michigan State University - June 2019
%
% If a hidden-metavariable representation is used then the hidden-metavariables
% are removed before calculating the dissimilarity, and the hidden-metavariable
% flags are removed from the genome and variable list. 
%
% Once prepared, dissimilarity is calculated by calling the VariableLength 
% dissimilarity function.
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

function [total_dissimilarity, MVDis] = MetavariableDissimilarity_HiddenMetavariable(g1, g2, vRange, vType, params)

g1(g1(:,params.hiddenMetavariableIndex)==0, :) = []; % ...remove the inactive metavariables
g2(g2(:,params.hiddenMetavariableIndex)==0, :) = [];
  
g1(:,params.hiddenMetavariableIndex) = []; % Get rid of the flags as well
g2(:,params.hiddenMetavariableIndex) = []; % Get rid of the flags as well

vType(params.hiddenMetavariableIndex) = [];
vRange(params.hiddenMetavariableIndex) = [];
[total_dissimilarity, MVDis] = MetavariableDissimilarity_VariableLength(g1, g2, vRange, vType, params);