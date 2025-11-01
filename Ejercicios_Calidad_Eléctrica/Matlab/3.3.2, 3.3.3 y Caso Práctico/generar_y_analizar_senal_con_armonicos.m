%% 3.3.3 Ejercicio 2.3 — Generar y Analizar Señal con Armónicos (MATLAB)
clear; clc;

%% Parámetros de la señal
fs = 2000;          % Hz
f0 = 50;            % Hz (fundamental)
T  = 0.5;           % s (duración)
t  = (0:1/fs:T-1/fs).';  % vector tiempo columna

V1 = 325;                 % amplitud pico fundamental
V3 = 0.15 * V1;           % 3er armónico = 15% del fundamental
V5 = 0.10 * V1;           % 5º armónico = 10% del fundamental

%% Señal compuesta (senos en pico)
x = V1*sin(2*pi*f0*t) + V3*sin(2*pi*3*f0*t) + V5*sin(2*pi*5*f0*t);

%% Análisis armónico 
[tbl, THD, THD_percent] = analyze_harmonics(x, fs, f0);

%% Preparar tabla de salida (primeros 10 armónicos)
n = min(10, height(tbl));
harm = tbl.Harm(1:n);
mag  = tbl.Magnitude(1:n);
pct  = (mag / V1) * 100;

Tabla10 = table(harm, tbl.Frequency_Hz(1:n), mag, pct, ...
    'VariableNames', {'Harmonico','Frecuencia_Hz','Magnitud_V','Porcentaje_fund_%'});

%% Cálculo y comparación de THD
THD_teorico_percent = sqrt(0.15^2 + 0.10^2) * 100;

fprintf('=== Tabla (primeros %d armónicos) ===\n', n);
disp(Tabla10);

fprintf('THD medido   : %.2f %%\n', THD_percent);
fprintf('THD teórico  : %.2f %% (sqrt(0.15^2 + 0.10^2)*100)\n', THD_teorico_percent);
fprintf('Diferencia   : %.2f puntos %%\n\n', THD_percent - THD_teorico_percent);

%% Visualización requerida
% Gráfica superior: señal temporal (primeros 4 ciclos)
t_max_4ciclos = 4 / f0;                 % 4 ciclos a 50 Hz = 0.08 s
mask_4c = t <= t_max_4ciclos;

figure('Name','Ejercicio 3.3.3 - Señal y Armónicos','Color','w');

tiledlayout(2,1);

% --- Superior: señal temporal (ms vs V) ---
nexttile;
plot(t(mask_4c)*1e3, x(mask_4c), 'LineWidth', 1.2);
grid on;
xlabel('Tiempo (ms)');
ylabel('Voltaje (V)');
title('Señal temporal (primeros 4 ciclos)');
xlim([0, t_max_4ciclos*1e3]);

% --- Inferior: barras de los primeros 10 armónicos ---
nexttile;
bar(harm, mag, 'BarWidth', 0.8);
grid on;
xlabel('Número de Armónico');
ylabel('Magnitud (V)');
title(sprintf('Espectro de armónicos (1..%d) — THD medido: %.2f%% | teórico: %.2f%%', ...
      n, THD_percent, THD_teorico_percent));
xlim([0.5, n+0.5]);
xticks(1:n);

% (Opcional) Etiquetas numéricas sobre cada barra
text(harm, mag, compose('%.1f', mag), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');
