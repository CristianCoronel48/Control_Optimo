clear all; close all;
%% Funcion de Transferencia del Sistema original (teoricamente desconcido)
num = [45 1];
den = conv([0.16 1],[0.4 0.64 1]); %(25s+1)(30s+1)
sys_c = tf(num,den); %bode(sys_c);

% Transformacion del sistema original de continuo a discreto
At = 1/100;%tasa de muestreo
fs = 1/At;
sys_d = c2d(sys_c,At,'zoh');
num_d = sys_d.num{1};
den_d=sys_d.den{1};

%% Se�ales de entrada y salida REALES
% Se�al de entrada Real

tf=20000*At;
t=0:At:tf;
N=length(t); %Puntos de la PRBS para muestrear
el=5;
m=7;
x=ones(m+1,1); %Registro inicial
for k=1:el:N
    for h=m:-1:1
        x(h+1)=x(h);    
    end
    x(1)=xor(x(6),x(5));    %PRBS 7: x^7 + x^6 + 1
    y(k:k+el-1)=x(m+1);
end
x=(2*y(1:N)-1);

%Grafico
%figure;
%plot(t,x,'.-k');title('Funci�n temporal x_t');xlabel('Tiempo [seg.]');
%ylabel('$x_t$','interpreter','latex','Rotation',0);grid on;

% Se�al de Salida REAL
% Ingreso x al sistema lineal discreto

y_D=zeros(size(x));
Orn=length(den_d);
for n=Orn:length(x)
    y_D(n)=...num_d(1)*x(n)+num_d(2)*x(n-1)+num_d(3)*x(n-2)+num_d(4)*x(n-3)-(den_d(2)*y(n-1)+den_d(3)*y(n-2)+den_d(4)*y(n-3));
    num_d(1:Orn)*fliplr(x(n-Orn+1:n))'-den_d(2:Orn)*fliplr(y_D(n-Orn+1:n-1))';
%     y(n)=    num_d(1)*x(n)+num_d(2)*x(n-1)-(den_d(2)*y(n-1));
end

[y_C,t_C]=lsim(sys_c,x,t); % Sistema continuo
[y_D_lsim,t_D]=lsim(sys_d,x,t); % Sistema discreto
y= y_D_lsim;
%% Bode Numerico
% Para tener una nocion del tama�o del sistema

% Autocorrelaci�n x
%Calculo de la correlacion entre se?ales digitalizadas

fmax=fs/2; Af=fmax/(.5*N);w1=0:Af:fmax-Af;
%valor para tao=0: Autocorrelacion de x
fixx=zeros(1,N);
fixx(1)= x*x';
for j=1:N-1
    for ii=1:N-j
        fixx(j+1)=fixx(j+1)+x(ii)*x(ii+j);        
    end
    fixx(j+1)=fixx(j+1);
end
fixxM = xcorr(x,x); %De matlab (Orfianidis)  figure;plot(fixxM(N:2*N-1))

% Densidad de potencia autoespectro x

%%Calculo de la densidad de potencia espectral
M1=fix(0.99*N);%Intervalos de correlacion utiles
j1=0:M1-1;
argu=-i*2*pi*0*j1/M1;
Sx(1)=fixx(1:M1)*exp(argu)';
for k=1:M1
    argu=-i*2*pi*(k)*j1/M1;
    Sx(k+1)=fixx(1:M1)*exp(argu)';
end
Sx=Sx/M1;
Af=2*fmax/M1;
w0=2*pi*(Af:Af:fmax);

% Inter correlaci�n x y
%valor para tao=0:Correlacion cruzada xy
fixy=zeros(1,N);fixy(1)=x*y;
for j=1:N-1
    for ii=1:N-j
        fixy(j+1)=fixy(j+1)+x(ii)*y(ii+j);        
    end
    fixy(j+1)=fixy(j+1);
end

% Densidad de potencia interespectro
%Calculo del interespetro
argu=-i*pi*0*j1/M1;
Sxy(1)=fixy(1:M1)*exp(argu)';
for k=1:M1
    argu=-i*2*pi*(k)*j1/M1;
    Sxy(k+1)=fixy(1:M1)*exp(argu)';
end
Sxy=Sxy/M1;

% Magnitud y Fase, diagrama de Bode num�rico 
%Magnitud
F_jw=(Sxy)./(Sx);
[MAG,PHASE,W]=bode(sys_c,{1e-1,fmax*2*pi});
MAGDB = 20*log10(MAG);H=[];I=[];
for ii=1:length(MAGDB)
    H(ii)=MAGDB(1,1,ii);
    I(ii)=PHASE(1,1,ii);
end

%Fase
fase=-180*angle(F_jw(1:M1/4))/pi;
delta_fase=diff(fase);
for ii=1:length(delta_fase)
    if delta_fase(ii)>150
        delta_fase(ii)=delta_fase(ii)-360;
    end
    if delta_fase(ii)<-150
        delta_fase(ii)=delta_fase(ii)+360;
    end
end
fase_c=[0 cumsum(delta_fase)];


% Graficos Magnitud y fase originales y por bode num�rico
figure (1);
subplot(2,1,1);semilogx(W,H,'b');hold on;
semilogx(w0(1:M1/4),20*log10(abs(F_jw(1:M1/4))),'.k');hold on;
% semilogx(MAG,'r');
title('Valores de F(j\omega)');xlabel('Frec. [rad/seg]');
ylabel('$dB$','interpreter','latex','Rotation',0);grid on;

subplot(2,1,2);semilogx(W,I,'b');hold on;semilogx(w0(1:M1/4),fase,'.k');hold on;
% semilogx(FASE,'r');hold on;.
xlabel('Frec. [rad/seg]');
title('$-\arctan({\frac{Im(F(j\omega))}{Re(F(j\omega))}})$','interpreter','latex','Rotation',0);
ylabel('Fase ');grid on;


