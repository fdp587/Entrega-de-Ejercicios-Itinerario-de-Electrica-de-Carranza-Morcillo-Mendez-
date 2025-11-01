%% 3.4 Actividad Guiada — Comparar Diferentes Cargas (MATLAB)
clear; clc;

%% Parámetros comunes
fs = 2000;          % Hz
f0 = 50;            % Hz
T  = 0.5;           % s (25 ciclos a 50 Hz; df = 2 Hz, sin fuga en armónicos)
t  = (0:1/fs:T-1/fs).';

V1 = 325; % amplitud pico fundamental

%% Definición de cargas (armónicos y amplitudes pico)
% Carga Lineal (ideal)
harm_L   = 1;                  amp_L   = V1;

% Carga con Distorsión Moderada
harm_M   = [1 3 5];            amp_M   = [V1 0.10*V1 0.05*V1];

% Carga Altamente Distorsionada
harm_H   = [1 3 5 7];          amp_H   = [V1 0.25*V1 0.15*V1 0.10*V1];

%% Síntesis de señales
xL = synth_signal(t, f0, harm_L, amp_L);
xM = synth_signal(t, f0, harm_M, amp_M);
xH = synth_signal(t, f0, harm_H, amp_H);

%% Análisis con tu función analyze_harmonics(x, fs, f0)
[tblL, THD_L, THD_L_pct] = analyze_harmonics(xL, fs, f0);
[tblM, THD_M, THD_M_pct] = analyze_harmonics(xM, fs, f0);
[tblH, THD_H, THD_H_pct] = analyze_harmonics(xH, fs, f0);

%% Tablas por carga (primeros 10 armónicos)
n = 10;
Tabla10_Lineal   = mk_topN(tblL, n, V1);
Tabla10_Moderada = mk_topN(tblM, n, V1);
Tabla10_Alta     = mk_topN(tblH, n, V1);

disp('=== Tabla: Carga Lineal (primeros 10 armónicos) ===');
disp(Tabla10_Lineal);
disp('=== Tabla: Carga con Distorsión Moderada (primeros 10 armónicos) ===');
disp(Tabla10_Moderada);
disp('=== Tabla: Carga Altamente Distorsionada (primeros 10 armónicos) ===');
disp(Tabla10_Alta);

%% THD teórico (%)
THD_teo_L_pct = 0;
THD_teo_M_pct = sqrt(0.10^2 + 0.05^2)*100;                % ≈ 11.18%
THD_teo_H_pct = sqrt(0.25^2 + 0.15^2 + 0.10^2)*100;       % ≈ 30.41%

%% Tabla comparativa
Carga = categorical({ ...
    'Lineal (ideal)'; ...
    'Distorsión Moderada'; ...
    'Altamente Distorsionada' ...
    });

THD_medido_pct  = [THD_L_pct; THD_M_pct; THD_H_pct];
THD_teorico_pct = [THD_teo_L_pct; THD_teo_M_pct; THD_teo_H_pct];
Supera_8pct     = THD_medido_pct > 8;

Comparativa = table(Carga, THD_medido_pct, THD_teorico_pct, Supera_8pct, ...
    'VariableNames', {'Carga','THD_medido_pct','THD_teorico_pct','Supera_8pct'});

disp('=== Comparativa de THD (%) ===');
disp(Comparativa);

%% Visualización: Espectros (primeros 10 armónicos) en subplots
figure('Name','Espectros de Armónicos (1..10)','Color','w');
tiledlayout(3,1);

% Prepara datos de barras
[hnL, magL] = bars_from(tblL, n);
[hnM, magM] = bars_from(tblM, n);
[hnH, magH] = bars_from(tblH, n);

ymax = 1.05 * max([magL; magM; magH]); % mismo límite para comparar

% Lineal
nexttile;
bar(hnL, magL, 'BarWidth', 0.8);
grid on; xlim([0.5 n+0.5]); xticks(1:n);
xlabel('Número de Armónico'); ylabel('Magnitud (V)');
title(sprintf('Carga Lineal — THD medido: %.2f%% (teórico: %.2f%%)', THD_L_pct, THD_teo_L_pct));
ylim([0 ymax]);

% Moderada
nexttile;
bar(hnM, magM, 'BarWidth', 0.8);
grid on; xlim([0.5 n+0.5]); xticks(1:n);
xlabel('Número de Armónico'); ylabel('Magnitud (V)');
title(sprintf('Distorsión Moderada — THD medido: %.2f%% (teórico: %.2f%%)', THD_M_pct, THD_teo_M_pct));
ylim([0 ymax]);

% Alta
nexttile;
bar(hnH, magH, 'BarWidth', 0.8);
grid on; xlim([0.5 n+0.5]); xticks(1:n);
xlabel('Número de Armónico'); ylabel('Magnitud (V)');
title(sprintf('Altamente Distorsionada — THD medido: %.2f%% (teórico: %.2f%%)', THD_H_pct, THD_teo_H_pct));
ylim([0 ymax]);


%% ==== Funciones locales auxiliares ====
function x = synth_signal(t, f0, harm, amps)
    % Suma senos con amplitud pico 'amps' en armónicos 'harm'
    harm = harm(:).'; amps = amps(:).';
    x = zeros(size(t));
    for k = 1:numel(harm)
        x = x + amps(k) * sin(2*pi*(harm(k)*f0)*t);
    end
end

function TablaN = mk_topN(tbl, n, V1)
    n = min(n, height(tbl));
    h  = tbl.Harm(1:n);
    f  = tbl.Frequency_Hz(1:n);
    m  = tbl.Magnitude(1:n);
    p  = (m / V1) * 100;
    TablaN = table(h, f, m, p, 'VariableNames', ...
        {'Harmonico','Frecuencia_Hz','Magnitud_V','Porcentaje_fund_%'});
end

function [hn, mag] = bars_from(tbl, n)
    n = min(n, height(tbl));
    hn = (1:n).';
    mag = tbl.Magnitude(1:n);
end
