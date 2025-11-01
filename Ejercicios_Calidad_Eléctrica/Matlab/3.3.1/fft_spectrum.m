function [f, A] = fft_spectrum(x, fs)
%FFT_SPECTRUM  Espectro de una señal (una cara, frecuencias positivas).

    if nargin < 2, error('Uso: [f,A] = fft_spectrum(x, fs)'); end
    if isempty(x), error('x está vacío.'); end
    if ~isscalar(fs) || fs <= 0, error('fs debe ser escalar positivo.'); end

    x = x(:);
    N = numel(x);

    % FFT y magnitud normalizada por N
    X = fft(x);
    P2 = abs(X) / N;

    % Primera mitad (frecuencias positivas). K = floor(N/2)+1 puntos
    K = floor(N/2) + 1;
    A = P2(1:K);
    % Duplicar componentes intermedias (excepto DC y Nyquist si existe)
    if K > 2
        A(2:K-1) = 2*A(2:K-1);
    end

    % Vector de frecuencias
    f = (0:K-1).' * (fs / N);
end

