function [Vrms, t] = sliding_rms(x, fs, win_ms)
%SLIDING_RMS  Valor RMS en ventanas deslizantes (muestra a muestra).

    % --- Comprobaciones básicas ---
    if nargin < 3, error('Faltan argumentos: x, fs, win_ms.'); end
    if isempty(x), error('La señal x está vacía.'); end
    if ~isscalar(fs) || fs <= 0, error('fs debe ser escalar positivo.'); end
    if ~isscalar(win_ms) || win_ms <= 0, error('win_ms debe ser escalar positivo (ms).'); end

    x  = x(:);                         % Asegura vector columna
    N  = numel(x);
    L  = max(1, round(win_ms * 1e-3 * fs));   % tamaño ventana en muestras

    if L > N
        error('La ventana (%.0f muestras) es mayor que la señal (%d).', L, N);
    end

    % --- RMS deslizante con convolución (vectorizado y rápido) ---
    % mean(x.^2) sobre cada ventana -> conv con kernel de unos normalizado.
    kernel = ones(L,1) / L;
    Vrms = sqrt( conv(x.^2, kernel, 'valid') );   % longitud N-L+1

    % --- Tiempos asociados al centro de la ventana ---
    % Ventana i cubre x(i : i+L-1). Centro en i + (L-1)/2 (índice 1-based).
    idx0 = (0:numel(Vrms)-1).';                   % 0..(N-L)
    t    = (idx0 + (L-1)/2) / fs;                % segundos (columna)
end
