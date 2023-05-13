%% Laborat�rio aquisição de dados com a DAQ
clear all, close all, clc

device = daq.getDevices

s = daq.createSession('ni')

device = 'Dev10'

Ts = 0.9; %% tempo de amostragemem segundos
Tsim = 40; %% tempo de simula��o em segundos
nit = round(Tsim/Ts); %% numero de itera��es

% eq. dif. 

%% configura��o da placa de aquisição
s.DurationInSeconds = Ts;
chi = addAnalogInputChannel(s,device,'ai0','Voltage');
chi.TerminalConfig = 'SingleEnded';

cho = addAnalogOutputChannel(s,device,'ao0','Voltage');

%%
entrada = zeros(1,nit);
entrada = (1:nit)/(1:nit);
saida = zeros(1,nit);

figure
h = animatedline;
xlim([0 Tsim]);
ylim([-1 2]);
grid on

%% laco de controle

Eant = 0;
Uant = 0;
RFant = 0;

for i=1:nit
    tic;
    %%% aquisicao de dados
    saida(i) = s.inputSingleScan();
    %laço controle
    RFatual = entrada*0.1207 + 0.8793*RFant;
    
    %Eatual = entrada(i)-saida(i);
    Eatual = RFatual-saida(i);
    Uatual = Uant + 6.13*Eatual - 5.39*Eant;
    
    %%% saturacao
    if(Uatual>10)
        Uatual = 10;
    elseif(Uatual<-10)
        Uatual = -10;
    end
    s.outputSingleScan(Uatual);
    %Atualização Variáveis
    Eant = Eatual;
    Uant = Uatual;
    RFant = RFatual;
    
    addpoints(h,(i-1)*Ts,saida(i));
    drawnow
    toc;
    pause(Ts-toc);
end

% tic
% data = startForeground(s);
% toc