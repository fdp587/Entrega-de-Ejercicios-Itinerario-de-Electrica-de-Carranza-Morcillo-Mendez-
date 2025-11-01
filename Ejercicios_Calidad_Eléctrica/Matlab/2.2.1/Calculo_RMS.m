%% Ejercicio 2.2.1

clc
clear

% Parámetros de la señal propuesta

f  = 50;  % Frecuencia de la señal
Vp = 325;  % Tensión de pico de la señal
fs = 1000;  % Frecuencia de muestreo
T  = 0.1;  % Periodo de muestreo

t = 0:1/fs:T-1/fs;  % Vector tiempo
v = Vp * sin(2*pi*f*t);  % Señal senoidal propuesta


% Aplicación de la función

Vrms_med = Cal_rms(v);


% Comparación con valor teórico

Vrms_real = 230;  % Valor RMS teórico de la señal                   
err_pct  = abs(Vrms_med - Vrms_real) / Vrms_real * 100;  % Porcentaje de error

% Mostrar resultados
fprintf('Vrms medido = %.6f V\n', Vrms_med);
fprintf('Vrms teórico = %.6f V\n', Vrms_real);
fprintf('Error = %.4f %%\n', err_pct);

if err_pct < 1

    fprintf('El error cumple con lo esperado \n')

else

    fprintf('No se cumple con nuestras expectativas \n')

end