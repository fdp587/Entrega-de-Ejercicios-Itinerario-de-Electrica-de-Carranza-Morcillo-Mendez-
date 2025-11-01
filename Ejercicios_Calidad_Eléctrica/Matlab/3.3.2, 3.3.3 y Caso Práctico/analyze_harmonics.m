function [tbl, THD, THD_percent] = analyze_harmonics(x, fs, f0)
%ANALYZE_HARMONICS Identifica y cuantifica los primeros 15 armónicos y calcula THD.

    % ---- Comprobaciones ----
    if nargin < 3, error('Uso: [tbl,THD,THD_percent] = analyze_harmonics(x, fs, f0)'); end
    if isempty(x), error('La señal x está vacía.'); end
    if ~isscalar(fs) || fs <= 0, error('fs debe ser escalar positivo.'); end
    if ~isscalar(f0) || f0 <= 0, error('f0 debe ser escalar positivo.'); end

    x = x(:);
    N = numel(x);

    % ---- FFT de una cara, normalizada ----
    X  = fft(x);
    P2 = abs(X)/N;                    % normalización por N
    K  = floor(N/2) + 1;              % número de bins positivos (incluye DC y Nyquist si N par)
    A  = P2(1:K);                     % magnitudes de una cara
    if K > 2
        A(2:K-1) = 2*A(2:K-1);        % duplica intermedias (no DC ni Nyquist)
    end
    f = (0:K-1).' * (fs/N);           % vector de frecuencias positivas

    % ---- Armónicos a analizar ----
    n_max_by_fs = floor((fs/2) / f0);     % máximo armónico observable (< Nyquist)
    n_max = min(15, n_max_by_fs);
    if n_max < 1
        error('fs es insuficiente para observar siquiera el fundamental a f0=%.3f Hz.', f0);
    end

    Harm = (1:n_max).';
    FreqTarget = Harm * f0;

    % Índices más cercanos a cada frecuencia objetivo
    df = fs / N;
    idx = round(FreqTarget/df) + 1;       % +1 porque f(1)=0 Hz
    idx = min(max(idx, 1), K);            % límites seguros

    % Frecuencia "exacta" (la del bin) y magnitud
    FreqExact = f(idx);
    Mag       = A(idx);

    % ---- Tabla resultado ----
    tbl = table(Harm, FreqExact, Mag, ...
        'VariableNames', {'Harm','Frequency_Hz','Magnitude'});

    % ---- THD (2..n_max respecto al fundamental 1) ----
    V1 = Mag(1);
    if V1 == 0
        THD = NaN;
        THD_percent = NaN;
        warning('Magnitud del fundamental es cero: THD indeterminado.');
    else
        THD = sqrt(sum(Mag(2:end).^2)) / V1;
        THD_percent = 100 * THD;
    end
end
