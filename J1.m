clc;
clear;
% A=[10,3,1;2,-10,3;1,3,10];
% b=[14,-5,14];
% A=[1 2 3;2 1 2;3 2 1];
% b=[1,1,1];
% B = diag(b);
% x0=[1,1,1];
% N=100;
% p=0.00001;
% [x,h,k] = Jacobiiter(A,b,x0,N,p);
A=[10,3,1;2,-10,3;1,3,10];
b=[14,-5,14];
x0=[0,0,0];
N=10000;
p=0.000001;
[x,h,k] = Jacobiiter(A,b,x0,N,p);