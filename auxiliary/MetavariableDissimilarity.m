% Matt Ryerkerk - Michigan State University - June 2019
%
% Compares two metameric genomes and returns the total dissimilarity
% between the two. Note that the genomes do not have to be the same length
% for this function to operate.
%
% The methodology for calculating dissimilarity differs depending on whether a 
% variable-length genome, hidden-metavariable representation, or static-metavariable
% representation is used. This function calls the appropriate function.
%
% inputs: 
%  g1: The first genome, with length g1L
%  g2: The second genome, with length g2L
%  vRange: Range of each design variable
%  vType: Type of each design variable (integers associated with enumerate types)
%  params.orderedProblem: Is problem ordered.%  

% Outputs: 
%  total_dissimilarity: The dissimilarity between the two parents
%  MVDis: A (g1L,g2L) matrix with the the dissimilarity between every pair of metavariables

function [total_dissimilarity, MVDis] = MetavariableDissimilarity(g1, g2, vRange, vType, params)

if (params.hiddenMetavariable == 0 && params.staticMetavariable == 0)  % Variable-length genome is used
  [total_dissimilarity, MVDis] = MetavariableDissimilarity_VariableLength(g1, g2, vRange, vType, params);
elseif (params.hiddenMetavariable == 1)
  [total_dissimilarity, MVDis] = MetavariableDissimilarity_HiddenMetavariable(g1, g2, vRange, vType, params);
elseif (params.staticMetavariable == 1)
  [total_dissimilarity, MVDis] = MetavariableDissimilarity_StaticMetavariable(g1, g2, vRange, vType, params);
end