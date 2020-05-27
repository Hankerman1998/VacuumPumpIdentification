function S = PumpingSpeed(p, S0, p_ultimate)
    k = S0/p_ultimate;
    if 1e5 - p > p_ultimate
       S = 0; 
    else
       S = S0 - k*(1e5 - p); 
    end

end