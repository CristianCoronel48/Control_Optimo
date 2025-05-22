% Densidad espectral de potencia
clear all
K = 1;
T = 1;
Fw = tf([0 K], [T 1]);  % Transformada de Fourier

% Gráfico de Bode
figure(1);
bode(Fw);
title('Diagrama de Bode');
grid on;

% Función de correlación
t = 0:0.01:10;  % vector tiempo
phi_xx = K / T * exp(-t / T);

figure(2);
plot(t, phi_xx);
title('Función de correlación, K=1, T=1');
xlabel('tau [seg]');
ylabel('amplitud');
grid on;

% Analizar la influencia de T en la función de correlación
M = 5;
figure(3);

% Incremento exponencial de T
subplot(2, 1, 1);
title('Función de correlación, K=1');
xlabel('tau [seg]');
ylabel('amplitud');
colors = ['r', 'm', 'c', 'b', 'g'];
hold on;

for i = 1:M
    T = 2^(i);
    plot(t, K / T * exp(-t / T), colors(i));
end
grid on;
legend(arrayfun(@(x) sprintf('T=%d', 2^x), 1:M, 'UniformOutput', false));

% Decremento exponencial de T
subplot(2, 1, 2);
title('Función de correlación, K=1, decremento exponencial de T');
xlabel('tau [seg]');
ylabel('amplitud');
hold on;

for i = 1:M
    T = 2^(-i);
    plot(t, K / T * exp(-t / T), colors(i));
end
grid on;
legend(arrayfun(@(x) sprintf('T=%.2f', 2^(-x)), 1:M, 'UniformOutput', false));

hold off;