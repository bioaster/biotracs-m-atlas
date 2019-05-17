clear; close all; clc;

%% TEST
% Assert that the full LAR model and OLS are equal

n = 100;
p = 25;

X = spasm.normalize(rand(n, p));
y = spasm.center(rand(n,1));

b_lar = spasm.lar(X,y);
b_ols = X\y;

assert(norm(b_lar(:,end) - b_ols) < 1e-12)

