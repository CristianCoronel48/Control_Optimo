%%TP3, Fourier de tren de pulsos
clear all, close all, clc;
% Definir par�metros
T = 1;          % Per�odo (segundos)
tau = 0.5;      % Ancho del pulso (segundos)
A = 1;          % Amplitud
fs = 1000;      % Frecuencia de muestreo (Hz)
t_max = 5;      % Tiempo total (segundos)

% Crear vector de tiempo
t = 0:1/fs:t_max;
N = length(t);  % N�mero de muestras

% Generar el tren de pulsos rectangulares
y = zeros(size(t));  % Inicializar la se�al
for i = 1:length(t)
    % Ajustar mod(t, T) para que el pulso est� centrado
    t_mod = mod(t(i) + T/2, T) - T/2;  % Desplazar para centrar el pulso
    if abs(t_mod) <= tau/2
        y(i) = A;
    else
        y(i) = 0;
    end
end

% Calcular la transformada de Fourier
Y = fft(y);  % Transformada r�pida de Fourier
f = (0:N-1)*(fs/N);  % Vector de frecuencias
Y_magnitude = abs(Y)/N;  % Magnitud normalizada
Y_phase = angle(Y);      % Fase

% Ajustar el espectro para frecuencias positivas
f = f(1:floor(N/2));
Y_magnitude = Y_magnitude(1:floor(N/2));
Y_phase = Y_phase(1:floor(N/2));
Y_magnitude(2:end) = 2 * Y_magnitude(2:end);  % Duplicar magnitudes (excepto DC) por simetr�a

% Frecuencia fundamental
f0 = 1/T;  % Frecuencia fundamental (Hz)

% Reconstruir la se�al con las componentes cosenoidales
num_harmonics = 20;  % N�mero de arm�nicos a considerar (ajustable)
y_reconstructed = zeros(size(t));  % Se�al reconstruida

% Componente DC (frecuencia 0)
y_reconstructed = y_reconstructed + Y_magnitude(1) * cos(2 * pi * 0 * t + Y_phase(1));

% Sumar los arm�nicos
for k = 1:num_harmonics
    idx = find(abs(f - k*f0) == min(abs(f - k*f0)), 1);  % Encontrar �ndice de la frecuencia k*f
    if ~isempty(idx)
        amplitude = Y_magnitude(idx);
        phase = Y_phase(idx);
        y_reconstructed = y_reconstructed + amplitude * cos(2 * pi * (k*f0) * t + phase);
    end
end

% Graficar la se�al original y la reconstruida superpuestas
%figure 1;
plot(t, y,'r', 'LineWidth', 1, 'DisplayName', 'Se�al Cuadrada Original');
hold on; grid on;
plot(t, y_reconstructed, 'LineWidth', 1, 'DisplayName', sprintf('Reconstrucci�n (%d arm�nicos)', num_harmonics));
xlabel('Tiempo (s)');
ylabel('Amplitud');
title('Se�al Cuadrada y Reconstrucci�n con Componentes Cosenoidales');
legend('show');