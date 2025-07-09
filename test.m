clc;close all; clear;
q_vec = [0,0,0;
         0,0.5,pi/4;
         0,1,pi/2];
t_vec = 1:3;

a = animation;
square = a.createSquare(q_vec,2);
square = a.createSquare(q_vec,1);

% square.drawBody(2)
a.animate(t_vec)
disp(a)