fs = 1000;
t  = (0:fs*1-1)/fs;
x  = 1 + 0.8*sin(2*pi*5*t) + 2*sin(2*pi*40*t);   % 5 Hz

[idx_after, t_cross, f_est] = detect_zero_crossings_simple(x, fs);
