%% Hueco de tensión + RMS deslizante
% Parámetros base
fs   = 2000;        % Hz
Ttot = 0.200;       % s  (200 ms)
f    = 50;          % Hz
Vp   = 325;         % V pico

% Tiempo y seno base
t = (0:1/fs:Ttot-1/fs).';
v_base = Vp * sin(2*pi*f*t);

% Hueco: inicio 50 ms, duración 50 ms, profundidad 50% (amplitud a la mitad)
t0   = 0.050;       % s
dura = 0.050;       % s
env  = ones(size(t));
env(t >= t0 & t < t0 + dura) = 0.5;      % 50% de amplitud en el hueco

% Señal final con hueco
v = env .* v_base;

% --- RMS deslizante (ventana de 20 ms = 1 ciclo) ---
win_ms = 20;  % ms
if exist('sliding_rms','file') ~= 2
    error('No encuentro sliding_rms.m. Asegúrate de tenerla en el path.');
end
[vrms, trms] = sliding_rms(v, fs, win_ms);

% --- Visualización ---
Vnom   = 230;               % V nominal
Vlow10 = 0.9 * Vnom;        % 207 V (-10%)

figure; tiledlayout(2,1);

% 1) Señal temporal
nexttile;
plot(t, v, 'b-', 'LineWidth', 1.1, 'DisplayName','Señal con hueco'); hold on; grid on;
xlabel('Tiempo (s)'); ylabel('Voltaje (V)');
title('Señal temporal (50 Hz), hueco del 50% entre 50 ms y 100 ms');
legend('Location','best');

% 2) RMS deslizante
nexttile;
plot(trms, vrms, 'r-', 'LineWidth', 1.3, 'DisplayName','RMS (ventana 20 ms)'); hold on; grid on;
yline(Vnom,   'k--', '230 V nominal', 'DisplayName','230 V nominal');
yline(Vlow10, 'k:',  '-10% (207 V)',  'DisplayName','-10% (207 V)');
xlabel('Tiempo (s)'); ylabel('V_{RMS} (V)');
title('RMS deslizante (20 ms). Líneas de 230 V y 207 V');
legend('Location','best');

% (Opcional) imprime mínimos para verificar la caída
fprintf('Mínimo VRMS: %.2f V\n', min(vrms));
