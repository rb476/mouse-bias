function [result y] = consecutives(vector, target)
% [result y] = consecutives(vector, target)
%
% Looks for the integer "target" in "vector" (which can also be a matrix)
% and returns how many times it repeats in "result" and creates a matrix of
% the same size as "vector" with the number of repeats on each element.
%
% if "vector" is a vector it must be 1xN
%
% found on Matlab central file exchange (adapted by rbm)

x = vector==target;
m = size(x,1);
y = [reshape([zeros(1,m);x.'],[],1);0];
p = find(~y);
d = 1-diff(p);
result = nonzeros(abs(d));
y(p) = [0;d];
y = reshape(cumsum(y(1:end-1)),[],m).';
y(:,1) = [];