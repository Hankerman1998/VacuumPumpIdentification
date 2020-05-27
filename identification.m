% this functio takes the pumpdown curve where time is in milliseconds and
% pressure is vacuum gauge pressure in kPa
IN = importdata('suck2.txt');


t = IN(:,1);
t = t-min(t);
gauge_pressure = IN(:,2);


% convert time to milliseconds
t = t/1000;
% convert pressure 
p = 1e5-adc*1000;

% the the pump speed vs. pressure curve is a linear function decreasing
% from S0 at no vacuum to zero at the ultimate gauge vacuum pressure
S0 = 0.01*0.00489144046842162;
p_ultimate = 1e5*0.704912803740142;

S = @(p) PumpingSpeed(p, S0, p_ultimate);



%% modeling pumpdown of a constant volume chamber
% atmospheric pressure
p0 = 1e5;
% simulation timestep
dt = 0.01;
% chamber volume, m3
V = 3e-4;

t_final = 60;

N = ceil(t_final/dt);

%simulation timesteps and pressure values
times = ones(N, 1);
pressures = ones(N, 1);

current_time = 0;
current_pressure = p0;
for i =1:N
    pressures(i) = current_pressure;
    times(i) = current_time;
    
    dp = S(current_pressure)*current_pressure*dt/V;
    
    current_pressure = current_pressure - dp;
    
    
    current_time = current_time + dt;
end

%% plot results and see if curves are similar
hold on;
plot(times, pressures);
plot(t, p);
%%
% identificatio of parameters. Smax varies from 0 to 10, Pult varies from 0
% to 1e5
Smax = 0.01;% this is like 10 l/s maximum 
Pmax = 1e5;% maximum ultimate pressure for 
Volume = 3e-4;% volume of the chamber
f = @(x)SimulationError(t, p, Volume, 0.1, 0.01*x(1), 1e5*x(2));

lb = nan(2, 1);
ub = nan(2, 1);
lb(1:end) = 0;
ub(1:end) = 1;
x0 = nan(2,1);
x0(1:end) = 0.5;

% we wanna look the progress of the optimization function
options = optimoptions(@fmincon,'PlotFcns','optimplotfval');

% run the optimization problem
[x,~,~,output] = fmincon(f,x0,[],[],[],[],lb,ub,[],options);

% run the simulation again to obtain plots of identified pumpdown curve vs.
% real pumpdown curve
S0 = Smax*x(1);
p_ultimate = Pmax*x(2);

S = @(p) PumpingSpeed(p, S0, p_ultimate);

clf;
hold on;
plot(times, pressures);
plot(t, p);
xlabel('time, s');
ylabel('absolute pressure, Pa');
legend({'identification', 'experiment'});