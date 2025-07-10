clc;close all; clear;
q_vec = [0,0,0;
         0,0.5,pi/6;
         0,1,pi/4;
         0,0.7,pi/2;
         0,0.8,pi/1.5;
         0,0.6,pi/1.7;];
t_vec = 1:length(q_vec);

a = animation;
square = a.createSquare(q_vec,2);
square = a.createSquare(q_vec+[1,0,0],1);
circ = a.createCirc(q_vec,5,25,[0;4]);
circ.createHole([-1 -1 2 2; 1 0 0 1])

% square.drawBody(2)
a.animate(t_vec,0.2)
disp(a)