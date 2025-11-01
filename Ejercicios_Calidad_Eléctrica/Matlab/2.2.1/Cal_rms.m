%% Función Cálculo de RMS

function Vrms = Cal_rms(x)

    x = x(:);  % Pone los elementos del vector en forma de columna

    N = numel(x);  % Saca el valor de N, número de muestras   

    Vrms = sqrt( sum(x.^2) / N );  % Aplica la fórmula de RMS
    
end
