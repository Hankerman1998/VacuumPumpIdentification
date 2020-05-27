function err = SimulationError(real_t, real_p, chamber_volume, dt, S0, p_ultimate)
    %% modeling pumpdown of a constant volume chamber
    % atmospheric pressure
    p0 = 1e5;
    
    % chamber volume, m3
    V = chamber_volume;

    t_final = 60;

    N = ceil(t_final/dt);

    %simulation timesteps and pressure values
    times = ones(N, 1);
    pressures = ones(N, 1);

    current_time = 0;
    current_pressure = p0;
    
    S = @(p) PumpingSpeed(p, S0, p_ultimate);
    
    for i =1:N
        pressures(i) = current_pressure;
        times(i) = current_time;

        dp = S(current_pressure)*current_pressure*dt/V;

        current_pressure = current_pressure - dp;


        current_time = current_time + dt;
    end
    
    real_p_interp = interp1(real_t, real_p, times);
    
    errors = (pressures - real_p_interp).^2;
    
    err = sum(errors);



end