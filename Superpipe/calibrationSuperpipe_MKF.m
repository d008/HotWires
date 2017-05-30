%%%% Superpipe Binary Data Read In %%%%
close all
clc
clear all
%%%%%%%%%%%%%%%%%%%%%%%%
Gain = 64;
Offset = -0.776;
R0=146.8;
Rext = 212;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alpha = 2e-3;
Thot = (Rext/R0-1)./alpha;

disp('Select root directory of Precal and Postcal')
Folder = uigetdir(pwd);
if Folder == 0
    return;
end

% Append slash to folder name
if ismac | isunix
    slash = '/Precal/';  % use '\' on windows
else ispc
    slash = '\Precal\';  % use '\' on windows
end

% slash = '/Precal/';  % use '\' on windows
Folder_pre = strcat(Folder,slash);
clear slash Start_Path
%%
All_TXT_files_struct = dir(fullfile(Folder_pre, '*.txt'));
Folder2 = Folder_pre;
clc
fprintf('Starting Precal\n')

calibrationSuperpipeHelper_MKF

%% Calibration for DAQ:
%Columns are channels, i.e. AI0 = Column 1

%%%% AI 0 - Tunnel Temperature in [Kelvin] %%%%
% ! without subtracting the zero
T_pre = (Meanvalues_DAQ(1:end,1).*100)+273.15;
% Standard Deviation
StD_T_pre(:,1) = ( (stdev_DAQ(:,3)).*100)+273.15;

%%%% AI 1 - Scanivalve Taps Static Pressure in [Pa] %%%%
% 10 V / 10 Torr - Conversion in Pa
% 
% Data_pre(:,2) = (Meanvalues_DAQ(:,2)) .* 133.322;
% % Standard Deviation
% StD_DAQ_pre(:,2) = ( (stdev_DAQ(:,2)).*(4000/10)).*6894.75729 ;

% %%%% AI 2 - Tunnel Static Pressure in [Pa] %%%%
% % ! without subtracting the zero (static pressure was already applied when taking zero)
% Data_pre(:,3) = (Meanvalues_DAQ(:,3).*(4000/10)).*6894.75729;
% 
% StD_DAQ_pre(:,3) = ( (stdev_DAQ(:,3)).*(4000/10)).*6894.75729 ;

%%%% AI 3 - Hotwire %%%%

Data_pre(:,2) =Meanvalues_DAQ(:,2);


%%%% Pitot Probe Pressure Transducers in [Pa]%%%%
% AI 4 (Column 5 in matrix) - 0.2 psi transducer
% AI 5 (Col 6) - 1   psi transducer
% AI 6 (Col 7) - 5   psi transducer
%Transducer = 5;
if Transducer == 0.2
    Col = 5;         %
elseif Transducer == 1
    Col = 6;
elseif Transducer == 5
    Col = 7;
end

Data_pre(:,3) = ((Meanvalues_DAQ(:,3)).*Transducer./5)*6894.75729;
% Standard Deviation
StD_DAQ_pre(:,3) = ( (stdev_DAQ(:,3)).*Transducer./5)*6894.75729;

%clear Col
%%%% AI 7  - Limit Switch Detect %%%%

% % open
% TD_pre(:,1) = ((Meanvalues_DAQ(:,6)).*1.25./5)*6894.75729;
% TD_pre(:,2) = ((Meanvalues_DAQ(:,7)).*5./5)*6894.75729;
% TD_pre(:,3) = ( (stdev_DAQ(:,6)).*1.25./5)*6894.75729;
% TD_pre(:,4) = ( (stdev_DAQ(:,7)).*5./5)*6894.75729;
%% Tunnel static pressure in atm to crosscheck

Tunnel_static_atm_pre = Data_pre(:,3).*9.86923267E-6;
Tunnel_static_psi_pre = Data_pre(:,3).* 0.000145038;

Rho_atm = 1.225;
U_pre = sqrt(2*(Data_pre(:,3)-min(Data_pre(:,3)))./Rho_atm);
V_pre = Data_pre(:,2);
% plot(U_pre,V_pre,'o')
% hold on
% Data_pre(:,1)
%% Select data folder

%Start_Path = fullfile('C:\Users\Water Channel\Desktop\Superpipe Labview\Data Folder\');



% Append slash to folder name
if ismac | isunix
    slash = '/Postcal/';  % use '\' on windows
else ispc
    slash = '\Postcal\';  % use '\' on windows
end

Folder_post = strcat(Folder,slash);
clear slash Start_Path

TXTfiles = fullfile(Folder_post, '*.txt');
All_TXT_files_struct = dir(TXTfiles);
%% Load Data for DAQ:
Folder2 = Folder_post;
clc
fprintf('Starting Postcal\n')

calibrationSuperpipeHelper_MKF

%% Calibration for DAQ:
%Columns are channels, i.e. AI0 = Column 1

%%%% AI 0 - Tunnel Temperature in [Kelvin] %%%%
% ! without subtracting the zero
Data_post(:,1) = (Meanvalues_DAQ(1:end,1).*100)+273.15;
% Standard Deviation
StD_DAQ_post(:,1) = ( (stdev_DAQ(:,3)).*100)+273.15;

T_post = Data_post(:,1);
% 
% %%%% AI 1 - Scanivalve Taps Static Pressure in [Pa] %%%%
% % 10 V / 10 Torr - Conversion in Pa
% 
% Data_post(:,2) = (Meanvalues_DAQ(:,2)) .* 133.322;
% % Standard Deviation
% StD_DAQ_post(:,2) = ( (stdev_DAQ(:,2)).*(4000/10)).*6894.75729 ;


% %%%% AI 2 - Tunnel Static Pressure in [Pa] %%%%
% % ! without subtracting the zero (static pressure was already applied when taking zero)
% Data_post(:,3) = (Meanvalues_DAQ(:,3).*(4000/10)).*6894.75729;
% 
% StD_DAQ_post(:,3) = ( (stdev_DAQ(:,3)).*(4000/10)).*6894.75729 ;
% 
% %%%% AI 3 - Hotwire %%%%

Data_post(:,2) =Meanvalues_DAQ(:,2);


%%%% Pitot Probe Pressure Transducers in [Pa]%%%%
% AI 4 (Column 5 in matrix) - 0.2 psi transducer
% AI 5 (Col 6) - 1   psi transducer
% AI 6 (Col 7) - 5   psi transducer
%Transducer = 5;
if Transducer == 0.2
    Col = 5;         %
elseif Transducer == 1
    Col = 6;
elseif Transducer == 5
    Col = 7;
end

Data_post(:,3) = (Meanvalues_DAQ(:,3).*Transducer./5)*6894.75729;
% Standard Deviation
StD_DAQ_post(:,3) =  ((stdev_DAQ(:,3)).*Transducer./5)*6894.75729;

%clear Col
%%%% AI 7  - Limit Switch Detect %%%%

% open
% TD_post(:,1) = ((Meanvalues_DAQ(:,6)).*1.25./5)*6894.75729;
% TD_post(:,2) = ((Meanvalues_DAQ(:,7)).*5./5)*6894.75729;
% TD_post(:,3) = ( (stdev_DAQ(:,6)).*1.25./5)*6894.75729;
% TD_post(:,4) = ( (stdev_DAQ(:,7)).*5./5)*6894.75729;
%% Tunnel static pressure in atm to crosscheck

Tunnel_static_atm_post = Data_pre(:,3).*9.86923267E-6;
Tunnel_static_psi_post = Data_pre(:,3).* 0.000145038;

Rho_atm = 1.225;
U_post = sqrt(2*(Data_post(:,3)-min(Data_post(:,3)))./Rho_atm);
V_post = Data_post(:,2);
% plot(U_post,V_post,'o')
% Data_post(:,1)
% xlabel('U (m/s)')
% ylabel('V (Volts)')
% legend('Precal','Postcal')
% set(gca,'fontsize',24)


save('calibration.mat', 'U_post','U_pre','V_post','V_pre', 'T_pre','T_post','Thot') 
%%
%clear all
load('calibration.mat')
poly_deg = 4;
U_cutoff = 1;

U_all = [U_pre;U_post];
V_all = [V_pre;V_post];
T_all = [T_pre;T_post];
cal_data = find(U_all>U_cutoff);
plot(U_post,V_post.*sqrt((Thot)./(Thot-T_post(:)+T_pre(1))),'ro')
hold on
plot(U_pre,V_pre.*sqrt((Thot)./(Thot-T_pre(:)+T_pre(1))),'bo')
plot(U_all(cal_data),V_all(cal_data).*sqrt((Thot)./(Thot-T_all(cal_data)+T_pre(1))),'kx')

xlabel('U (m/s)')
ylabel('V (Volts)')
legend('Precal','Postcal','location','southeast')
set(gca,'fontsize',24)


[P,S] = polyfit(V_all(cal_data).*sqrt((Thot)./(Thot-T_all(cal_data)+T_pre(1))),...
    U_all(cal_data),poly_deg);
[Ppre,Spre] = polyfit(V_pre(find(U_pre>U_cutoff)).*sqrt((Thot)./(Thot-T_pre(find(U_pre>U_cutoff))+T_pre(1))),...
    U_pre(find(U_pre>U_cutoff)),poly_deg);
[Ppost,Spost] = polyfit(V_post(find(U_post>U_cutoff)).*sqrt((Thot)./(Thot-T_post(find(U_post>U_cutoff))+T_pre(1))),...
    U_post(find(U_post>U_cutoff)),poly_deg);
f = @(P,V,T) polyval(P,V.*sqrt((Thot)./(Thot-T+T_pre(1))));
%S.normr %=sqrt(sum((U_all(cal_data)-f(P,V_all(cal_data),T_all(cal_data))).^2))
rsq = 1 - S.normr^2 / ((length(U_all(cal_data))-1) * var(U_all(cal_data)))...
    .*(length(cal_data)-1)/(length(cal_data)-length(P))


Vs = linspace(min(V_all),max(V_all),100);
plot(f(P,Vs,T_pre(1)),Vs,'k')
plot(f(Ppre,Vs,T_pre(1)),Vs,'r')
plot(f(Ppost,Vs,T_pre(1)),Vs,'b')
hold off
print('cal','-dpng')
save('calibration.mat', 'f','P','-append') 