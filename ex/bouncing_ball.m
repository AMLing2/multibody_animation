clc; clear; close all;
addpath(fullfile(".."))

ts = 1e-4; % [s] timestep
g = 9.81; % [m/s^2]
t_end = 10; % [s]
k = 5000; % [kg/s^2] spring coefficient
b = 30; % damper coefficient
mu_k = 0.8; % [kg/s] kinetic coefficient of friction (rubber on concrete)
m = 1; % [kg] mass of ball 
r = 0.1; % [m] radius of ball
i = (m*r^2)/2; % [kg*m^2] mass moment of inertia of ball
s_0 = 1;
v_epsilon = 0.000001; % [m/s] minimum friction vel, prevents div by zero
min_penetration = -5e-3; % [m] distance before applying spring forces

% initialize ball
y = 2; % [m]
yd = 0; % [m/s]
ydd = 0; % [m/s^2]
x = 0;
xd = 1;
xdd = 0;
phi = 0; % [rad/s]
phid = 0;
phidd = 0;

n = 1; % index for saving data
for t = 0:ts:t_end
    fg = g*m; % gravity 
    % slip based friction:
    speed_list = [xd,r*phid,v_epsilon];
    v_0 = max(abs(speed_list));
    s = (-r*phid-xd)/v_0;
    mu = mu_k*tanh(s/s_0);
    if y-r < min_penetration % touching ground
        fk = -(y-r)*k; % bouncing spring force of ground
        fb = -yd*b; %(yd-0) damper force of ground
        [~,max_ind] = max(abs(speed_list),[],'all','linear'); % get index of most dominant speed for sign
        ff = fg*mu; % friction
    else
        fk = 0;
        ff = 0;
        fb = 0;
    end

    crr = (phidd*r)/g;

    fy = -fg + fk + fb;
    fx = ff;
    Mr = ff*r; % [Nm] moment from friction

    % calculate accelerations
    xdd = fx/m;
    ydd = fy/m;
    phidd = Mr/i; % [rad/s^2]
    % save data of simulation
    q_ball(n,:) = [x,y,phi]; 
    t_data(n) = t;
    ff_data(n) = ff;
    xd_data(n) = xd;
    phid_data(n) = phid;
    s_data(n) = s;

    % integrate state variables
    xd = xd + xdd*ts;
    yd = yd + ydd*ts;
    phid = phid + phidd*ts;
    y = y + yd*ts;
    x = x + xd*ts;
    phi = phi + phid*ts;

    n = n + 1;
end

% plot relevant data
figure
plot(t_data,ff_data)
xlabel("time [s]");
ylabel("fricton force [N]")
figure
plot(t_data,xd_data)
xlabel("time [s]");
ylabel("x dot [m/s]")
figure
plot(t_data,phid_data)
xlabel("time [s]");
ylabel("rot speed [rad/s]")
figure
plot(t_data,s_data)
xlabel("time [s]");
ylabel("slip")

% return
% close all
a = animation();
a.setOptions("axis",[-2,7,-1,3],"forceUnit","N")
a.createCircle(q_ball,r);
a.createLine([-2,7;0,0],20,0.1)

% point at ground 
q_p = q_ball;
q_p(:,3) = 0;
p = a.createCustom(q_p,[]);
p.addPoint([0;-r],"gr",5,'x',false);
p.setOptions("drawFrame",false)
p.forceArrowPoint("gr",0,ff_data,"global","towards",0.08,0.1)
a.animate(t_data,0.1,500)