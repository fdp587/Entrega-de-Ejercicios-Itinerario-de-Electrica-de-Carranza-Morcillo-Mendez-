%% Función Cruces por Cero

function [idx_after, t_cross, f_est] = detect_zero_crossings_simple(x, time_or_fs)

    x = x(:);  % Fuerza el vector columna
    N = numel(x);  % Calcula N

    if isscalar(time_or_fs)  % Si la entrada es frecuencia, te calcula el periodo
        
        fs = time_or_fs;
        t  = (0:N-1).' / fs;

    else

        t  = time_or_fs(:);  % Si la entrada es tiempo, te lo deja así
        
    end


    s = sign(x);  % Te dice el signo de la señal
    ds = diff(s);  % Calcula cuando hay cambio de signo

    idx_after = find(ds ~= 0) + 1;  % índice inmediatamente después del cruce
    i = idx_after - 1;  % índice inmediatamente antes del cruce


    % Interpolación del valor del cruce si la muestra no coincide en cero

    t_cross = t(i) + (t(i+1)-t(i)) .* (-x(i)) ./ (x(i+1)-x(i));


    % Estimación de frecuencia. A partir de los cruces, saca el periodo. A
    % partir del periodo, saca la frecuencia

    if numel(t_cross) >= 2

        f_est = 1 ./ (2*mean(diff(t_cross)));

    else

        f_est = NaN;

    end

    % Representación de los resultados

    figure 
    hold on 
    grid on
    plot(t, x, '-', 'DisplayName','Señal');
    yline(0,'--','DisplayName','y=0');
    plot(t_cross, zeros(size(t_cross)), 'ro', 'DisplayName','Cruces por cero');
    xlabel('Tiempo (s)'); 
    ylabel('Amplitud');

    
    if ~isnan(f_est)
        title(sprintf('Cruces por cero | f_{est} = %.3f Hz', f_est));

    else

        title('Cruces por cero | f_{est} = N/A');

    end

    legend('Location','best');

end
