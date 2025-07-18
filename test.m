clc;close all; clear;
q_vec = [0,0,0;
         0,0.5,pi/6;
         0,1,pi/4;
         0,0.7,pi/2;
         0,0.8,pi/1.5;
         0,0.6,pi/1.7;];
t_vec = 1:length(q_vec);

a = animation;
a.setOptions('axis',{[-10.0 10 -10.0 10.0]})
a.createSquare(q_vec,2);
a.createSquare(q_vec+[1,0,0],1);
circ = a.createCirc(q_vec,5,25,[0;4]);
circ.createHole([-1 -1 2 2; 1 0 0 1])
turt = a.createTurtleGraphics(q_vec,[1;2],[0,1,90,1,30,1,120,1]);
sup = a.createSupport([-1;-1],120,1);
turt.addPoint([3;3],'A');
sup.addPoint([0;0],'B',8);
a.createLine([0,5;0,1],20,1);
a.linkPoints(turt.point('A'),...
             sup.point('B'),'line');

a.animate(t_vec,0.2)
disp(a)

%TODO list:
% gears, create 1 segment with turtle and repeat n times probably
% rotational spring and damper
% shape resizing for hydraulics or other visuals? will be very simple to add