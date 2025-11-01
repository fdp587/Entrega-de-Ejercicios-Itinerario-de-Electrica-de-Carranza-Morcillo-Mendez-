%% 4.6 Grupo 6 — Sistema Fotovoltaico con Inversores (MATLAB)
clear; clc;

%% Especificaciones
fs = 2000;          % Hz (con T=1 s => df = 1 Hz, armónicos en bins exactos)
T  = 1.0;           % s
f0 = 50;            % Hz (fundamental)
t  = (0:1/fs:T-1/fs).';

V1 = 325;                             % amplitud pico fundamental
ratios = struct( ...                  % proporciones pico respecto al fundamental
    'h3',  0.05, ...                 % 5 %
    'h5',  0.08, ...                 % 8 %
    'h7',  0.06, ...                 % 6 %
    'h11', 0.04, ...                 % 4 %
    'h13', 0.03);                    % 3 %

% Amplitudes pico por armónico
A3  = ratios.h3  * V1;
A5  = ratios.h5  * V1;
A7  = ratios.h7  * V1;
A11 = ratios.h11 * V1;
A13 = ratios.h13 * V1;

%% Señal compuesta
x = V1*sin(2*pi*f0*t) ...
  + A3 *sin(2*pi*3*f0*t) ...
  + A5 *sin(2*pi*5*f0*t) ...
  + A7 *sin(2*pi*7*f0*t) ...
  + A11*sin(2*pi*11*f0*t) ...
  + A13*sin(2*pi*13*f0*t);

%% Análisis
[tbl, THD, THD_percent] = analyze_harmonics(x, fs, f0);

% THD teórico a partir de ratios
THD_teorico_percent = 100*sqrt( ...
    ratios.h3^2 + ratios.h5^2 + ratios.h7^2 + ratios.h11^2 + ratios.h13^2);

%% Mostrar tabla (primeros 15 armónicos) con % sobre fundamental
Nshow = min(15, height(tbl));
Mag   = tbl.Magnitude(1:Nshow);
Harm  = tbl.Harm(1:Nshow);
Pct   = (Mag / V1) * 100;   % % relativo a fundamental

Tabla15 = table(Harm, tbl.Frequency_Hz(1:Nshow), Mag, Pct, ...
    'VariableNames', {'Harmonico','Frecuencia_Hz','Magnitud_V','Porcentaje_fund_%'});

disp('=== Tabla (primeros 15 armónicos) ===');
disp(Tabla15);

%% Identificar los 3 armónicos más significativos (excluyendo el fundamental)
Mag_no1 = tbl.Magnitude(2:Nshow);
Harm_no1 = tbl.Harm(2:Nshow);
Pct_no1 = (Mag_no1 / V1) * 100;

[~, idx_sort] = sort(Mag_no1, 'descend');
top3_idx = idx_sort(1:min(3, numel(idx_sort)));

Top3 = table(Harm_no1(top3_idx), Mag_no1(top3_idx), Pct_no1(top3_idx), ...
    'VariableNames', {'Harmonico','Magnitud_V','Porcentaje_fund_%'});

disp('=== Top 3 armónicos (excluyendo fundamental) ===');
disp(Top3);

%% Verificación de cumplimiento IEEE 519 (típico LV en PCC)
lim_THD_pct = 5;    % THD de tensión <= 5 %
lim_ind_pct = 3;    % Armónico individual de tensión <= 3 %

cumple_THD = (THD_percent <= lim_THD_pct);
cumple_ind = all(Pct_no1 <= lim_ind_pct);

fprintf('THD medido    : %.2f %% (teórico: %.2f %%)\n', THD_percent, THD_teorico_percent);
fprintf('Cumple THD<=5%%?        %s\n', string(cumple_THD));
fprintf('Todos armónicos <=3%%?  %s\n', string(cumple_ind));

%% Visualización: señal (4 ciclos) y barras (1..15)
figure('Name','Grupo 6 — Señal y Armónicos','Color','w');
tiledlayout(2,1);

% Señal temporal (primeros 4 ciclos)
nexttile;
t4 = 4/f0;
mask = t <= t4;
plot(t(mask)*1e3, x(mask), 'LineWidth', 1.2);
grid on; xlabel('Tiempo (ms)'); ylabel('Voltaje (V)');
title('Señal temporal (primeros 4 ciclos)');
xlim([0, t4*1e3]);

% Barras 1..15
nexttile;
bar(Harm, Mag, 'BarWidth', 0.8);
grid on; xlabel('Número de Armónico'); ylabel('Magnitud (V)');
title(sprintf('Espectro (1..%d) — THD: %.2f%%', Nshow, THD_percent));
xlim([0.5, Nshow+0.5]); xticks(1:Nshow);
text(Harm, Mag, compose('%.2f', Mag), ...
    'HorizontalAlignment','center','VerticalAlignment','bottom');

%% Propuesta de filtrado (práctica y alcanzable)
% - Trampas sintonizadas en paralelo para 5ª y 7ª (reducir ~80% cada una)
% - Bloqueo/mitigación de 3ª (delta o zig-zag, o trampa 3ª) (~50%)
% - Atenuación ligera de 11ª y 13ª con LCL/pasivo de alto orden (~25%)

atten = struct( ...
    'h3',  0.50, ...   % queda 50% de la 3ª
    'h5',  0.20, ...   % queda 20% de la 5ª
    'h7',  0.20, ...   % queda 20% de la 7ª
    'h11', 0.75, ...   % queda 75% de la 11ª
    'h13', 0.75);      % queda 75% de la 13ª

% Estimación de THD tras el filtrado (porcentual)
thd_after = 100*sqrt( ...
    (atten.h3  * ratios.h3 )^2 + ...
    (atten.h5  * ratios.h5 )^2 + ...
    (atten.h7  * ratios.h7 )^2 + ...
    (atten.h11 * ratios.h11)^2 + ...
    (atten.h13 * ratios.h13)^2 );

fprintf('\n=== Estimación THD tras filtrado propuesto ===\n');
fprintf('THD estimado: %.2f %%  (objetivo < 5%%)\n', thd_after);

%% Conclusiones rápidas (también en consola)
if ~cumple_THD || ~cumple_ind
    fprintf(['\nConclusión: NO cumple IEEE 519 (LV): THD=%.2f%%, ' ...
             'máx. individual=%.2f%% (lím.: 5%% y 3%%)\n'], ...
             THD_percent, max(Pct_no1));
else
    fprintf('\nConclusión: Cumple IEEE 519 (LV).\n');
end

fprintf('Top 3 armónicos: %s\n', strjoin("H"+string(sort(Top3.Harmonico.','ascend')), ', '));
