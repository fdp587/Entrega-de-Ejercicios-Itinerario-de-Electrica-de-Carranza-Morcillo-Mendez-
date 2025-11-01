% Parámetros de la señal
fs = 2000;           % Hz
T  = 1.0;            % s
f0 = 50;             % Hz
Vp = 325;            % V pico

t = (0:1/fs:T-1/fs).';
x = Vp * sin(2*pi*f0*t);

% Espectro
[f, A] = fft_spectrum(x, fs);

% Visualización hasta 500 Hz
figure;
stem(f, A, 'filled'); grid on;
xlim([0 500]);
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (V)');
title('Espectro de una cara (normalizado): seno de 50 Hz, V_p = 325 V');

% Verificación: pico único en 50 Hz
[peakA, idx] = max(A);
fprintf('Pico en f = %.2f Hz, magnitud = %.2f V\n', f(idx), peakA);

% Debe haber un pico (≈ 325 V) exactamente en 50 Hz (resolución = 1 Hz)
df = fs/numel(x);
assert(abs(f(idx) - f0) <= df/2, 'El pico principal no está en 50 Hz.');
