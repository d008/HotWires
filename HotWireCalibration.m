

%% Constants and Air Properties
%Thermal Conductivity Kannuluik and Carman (1951),
k= @(Tf) 418.4*(5.751e-5*(1+0.00317.*Tf-0.0000021.*Tf.^2)); %celsius
dkdT= @(Tf) 0.0240622.*(0.00317 - 4.2.*10^-6.*Tf); %celsius

%Sutherland Formula Viscosity mu
mu_0 = 1.716e-5;T_0 = 273.15;S = 110.4;C1 = 1.458e-6;

%Dynamics Viscosity mu(Celsius)
mu = @(T) mu_0.*((T+T_0)./T_0).^(3/2).*(T_0+S)./((T+T_0)+S); %celsius

%Density
R =287.058;
rho  = @(P,T) P./(R*(T+T_0)); %rho(Pascals,Celsius)

%Kinematic Viscosity
nu = @(P,T) mu(T)./rho(P,T); %nu(Pascals, Celsius)
dnudt = @(P,T) mu_0 .* R.*(S+T_0).*((T+T_0)./T_0).^(3/2).*(5.*S+3.*(T+T_0))./(2*P.*(S+T+T_0).^2);

%%


%try
%load('vel_prof/normalised_mkf2.mat')
%catch
% Manually enter testing paramters
Gain = 16;
Offset = -1.95;
R0=101;
Rext = 140;
alpha = 2e-3;
Thot = (Rext/R0-1)./alpha;

%Experiment Paramters
%Load Data Precal
load(deblank(ls('precal/summary*')))
n_pre = n; P_atm_pre =P_atm; rho_pre = rho; T_pre= T;U_pre= u_tr;
try
    V_pre = hw_volt(:,2);
catch
    V_pre = hw_volt(:,1);
end
%Film Temperature
Tf_pre = (Thot + T_pre)./2;
%Calculate kinematic viscosity
nu_pre = mu(T_pre+T_0)./rho_pre;
%Load Data Precal
load(deblank(ls('poscal/summary*')))
n_post = n;  P_atm_post =P_atm; rho_post = rho; T_post= T;U_post= u_tr;
try
    V_post = hw_volt(:,2);
catch
    V_post = hw_volt(:,1);
end
%Film Temperature
Tf_post = (Thot + T_post)./2;
%Calculate kinematic viscosity
nu_post = mu(T_post+T_0)./rho_post;
%Determine voltage across the wire

%Combine the Data- Pre&Post Cal
n =[n_pre,n_post]; v=[V_pre,V_post]; P_atm=[P_atm_pre, P_atm_post];
rho = [rho_pre,rho_post]; T = [T_pre,T_post]; U = [U_pre,U_post];
T_f = (Thot + T)./2;
nu = mu(T+T_0)./rho;

% %Marcus Calibration similarity
% v  = v./Gain+Offset;
% %Plot data
%  [Ph,Sh] = polyfit(v.^2./(k(T_f).*(Thot-T)),U./nu,4);
%  u = @(V, T, P, Tw) polyval(Ph, V.^2./(k((Tw+T)./2).*(Tw-T))).*nu(P,T);
% figure(1)
% plot(V./sqrt(k(Tf_pre).*(Thot-T_pre)),U_pre./mu(Tf_pre).*rho_pre,'o')
% hold on
% plot(V./sqrt(k(Tf_post).*(Thot-T_post)),U_post./mu(Tf_post).*rho_post,'o')
% hold off



clear n_pre n_post V_pre V_post P_atm_pre P_atm_post nu_pre nu_post
clear rho_pre rho_post T_pre T_post U_pre U_post Tf_pre Tf_post



%%
vel_prof_s = load(deblank(ls('vel_prof/summary*')));
n = vel_prof_s.n;

%try
%    load('vel_prof/normalised_mkf2.mat');
%catch
load('vel_prof/normalised.mat')
N = 4;
[P1a,S1a] = polyfit(v(:,1),U(:,1),N);%y_1 = x(:,1)*0;
[P1b,S1b] = polyfit(v(:,1).*sqrt((Thot-T(1,1))./(Thot-T(:,1))),U(:,1),N);%y_2 = x(:,2)*0;

[P2a,S2a] = polyfit(v(:,2),U(:,2),N);%y_1 = x(:,1)*0;
[P2b,S2b] = polyfit(v(:,2).*sqrt((Thot-T(1,1))./(Thot-T(:,2))),U(:,2),N);%y_2 = x(:,2)*0;


f = @(P,V) polyval(P,V);
clf
variance = zeros(length(z_corr),4);
T_data = zeros(length(z_corr),4);
warning('off','MATLAB:daqread:legacySupportDeprecated')
h =waitbar(0,'Please Wait');
for i = 1:length(z_corr);
    waitbar(i/length(z_corr),h,trials(j).name);
    [data,time] = daqread(strcat('vel_prof/data_',num2str(i),'.daq'));
    T_data(i) = mean(data(:,2))*10;
    variance(i,1) = var(f(P1a,data(:,end)))./u_tau.^2;
    variance(i,2) = var(f(P1b,data(:,end).*sqrt((Thot-T(1,1))./(Thot-T_data(i)))))./u_tau.^2;
    variance(i,3) = var(f(P2a,data(:,end)))./u_tau.^2;
    variance(i,4) = var(f(P2b,data(:,end).*sqrt((Thot-T(1,1))./(Thot-T_data(i)))))./u_tau.^2;
end
close(h);
%end

%end

%%
figure(1)

subplot(3,1,1)
plot(U,T,'-o')
set(gca,'FontSize',20);
xlabel('U(m/s)', 'fontsize', 24);
ylabel('T (^o C)', 'fontsize', 24);
legend({'Pre','Post'},'location','southeast')

subplot(3,1,2)
plot(U,v,'o')
legend({'Pre','Post'},'location','southeast')
set(gca,'FontSize',20);
xlabel('U(m/s)', 'fontsize', 24);
ylabel('Volts', 'fontsize', 24);

subplot(3,1,3)
set(gca,'DefaultTextInterpreter','latex');
plot(U,v.*sqrt((Thot-T(1,1))./(Thot-T)),'o')
legend({'Pre','Post'},'location','southeast')
set(gca,'FontSize',20);
xlabel('U(m/s)', 'fontsize', 24);
ylabel('Volts $\left(\frac{T_h-T_r}{T_w -T_a} \right)$', 'fontsize', 24,'interpreter','latex');

figure(3)
plot(v.^2./(k(T_f).*(Thot-T)),U./nu,'o')


figure(2)
temp  = (variance(:,1)-variance(:,2))./variance(:,1)*100;
max(temp)-min(temp);

semilogx(z_corr.*u_tau./nu,variance(:,1),'ro-');
hold on
semilogx(z_corr.*u_tau./nu,variance(:,2),'bo-');
semilogx(z_corr.*u_tau./nu,variance(:,3),'rx-');
semilogx(z_corr.*u_tau./nu,variance(:,4),'bx-');
semilogx(z_plus(u_ini_ind:end),...
    u_var_plus(u_ini_ind:end),'gs-');
hold off
ax =gca;
ax.XScale = 'log';
set(ax,'DefaultTextInterpreter','latex');
set(ax,'TickLabelInterpreter', 'latex')
set(gca,'FontSize',20);

grid on
xlabel('$z^+$', 'fontsize', 24);
ylabel('$\overline{{u^2}^+}$', 'fontsize', 24);
legend({'Pre w/o Temp','Pre w/ Temp',...
    'Post w/o Temp','Post w/ Temp','MelbourneCode'},'location','bestoutside')

clear data time
PWD = pwd;
filepath = regexp(pwd,'/');
filepath = strcat(PWD(filepath(end-1)+1:filepath(end)-1),'_var');
set(figure(1), 'Position', [1200 1000  600 1200])
set(figure(2), 'Position', [50 1000  1000 500])
print(figure(2),filepath,'-depsc2')
save('vel_prof/normalised_mkf2.mat');

drawnow
pause(2)