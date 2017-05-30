%%%%% Data processing %%%%%
close all
%%%%% Superpipe Data Processing %%%%%
dpdx_readin_MKF
SP_Binary_read_in_MKF
load('dpdx.mat')
%%
% Density Rho, dynamic viscosity mu

% Parameters for ZSI functio
% TempK = Data(:,1);
% P_Pa = Data(:,3);

% % calls function ZSI, which calculates parameters rho and mu

% 
% 
% % Velocity
% Rho_atm = 1.225;
% U(:,1) = sqrt(2*Data(:,5)./Rho_atm);
% U(:,2) = sqrt(2*TD(:,1)./Rho_atm);
% U(:,3) = sqrt(2*TD(:,2)./Rho_atm);
% % StD Velocity
% UStd(:,1) = sqrt(2*StD_DAQ(:,5)./Rho_atm);
% UStd(:,2) = sqrt(2*TD(:,3)./Rho_atm);
% UStd(:,3) = sqrt(2*TD(:,4)./Rho_atm);
% 
% % Reynolds number
% Pipe_Radius = 0.07;
% Re = (Rho .* Pipe_Radius .* U(:,1))./mu;


%% Plot to check Pitot Velocity
% close all
% figure
% plot(U(:,1),Actual_Positions(:,3)./1000,'-+')
% hold on
% plot(U(:,2),Actual_Positions(:,3)./1000,'-+')
% plot(U(:,3),Actual_Positions(:,3)./1000,'-+')
% xlabel('$U$ [m/s]','Interpreter','LaTex','FontSize',20) 
% ylabel('Distance from wall [mm]','Interpreter','LaTex','FontSize',20)
% grid on
% grid minor
%     legend({'0.2 psid Transducer', ...
%     '1.25 psid Transducer',...
%     '5 psid Transducer'},...
%     'Interpreter','Latex','FontSize',15,'Location','northwest')
% 
% figure
% semilogy(U(:,1),Actual_Positions(:,3),'-+')
% hold on
% plot(U(:,2),Actual_Positions(:,3),'-+')
% plot(U(:,3),Actual_Positions(:,3),'-+')
% xlabel('$U$ [m/s]','Interpreter','LaTex','FontSize',20) 
% ylabel('Distance from wall [$\mu$m]','Interpreter','LaTex','FontSize',20)
% grid on
% grid minor
%     legend({'0.2 psid Transducer', ...
%     '1.25 psid Transducer',...
%     '5 psid Transducer'},...
%     'Interpreter','Latex','FontSize',15,'Location','southeast')

% figure
% errorbar(U(:,1),Actual_Positions(:,3)./1000,UStd(:,1),'horizontal','-+')
% hold on
% errorbar(U(:,2),Actual_Positions(:,3)./1000,UStd(:,1),'horizontal','-+')
% errorbar(U(:,3),Actual_Positions(:,3)./1000,UStd(:,1),'horizontal','-+')
% xlabel('$U$ [m/s]','Interpreter','LaTex','FontSize',20) 
% ylabel('Distance from wall [mm]','Interpreter','LaTex','FontSize',20)
% grid on
% grid minor
%    legend({'0.2 psid Transducer $\pm$ 1 $\sigma$', ...
%    '1.25 psid Transducer $\pm$ 1 $\sigma$',...
%    '5 psid Transducer $\pm$ 1 $\sigma$'},...
%    'Interpreter','Latex','FontSize',15,'Location','northwest')

%%
[Rho, mu] = ZSI(TempK(1),101325);
utau = sqrt((-DPDX./Rho)*(D./4))
nu = mu./Rho;
yplus = nu/utau;
retau = round(D./2./yplus)
yoffset = 200;
load('re150000.mat')
%%

figure(1)

semilogx((Actual_Positions(:,3)+yoffset)/10^6/yplus,varHW./utau^2,'o')
grid on
xlabel('$y^+$','interpreter','latex','fontsize',24)
ylabel('$\overline{u''^2}$','interpreter','latex','fontsize',24)
title('variance')
set(gca,'fontsize',24)
print('var','-dpng')
hold on
semilogx(y_plus,u2_plus,'k-s')
hold off
kappa = 0.39;
B=4.3;

figure(2)
semilogx((Actual_Positions(:,3)+yoffset)/10^6/yplus,meanHW./utau,'o')

hold on
ys = logspace(1.4,3);
semilogx(ys,1./kappa.*log(ys)+B,'-')
grid on
semilogx(y_plus,U_plus,'k-s')
hold off
title('mean profile')
xlabel('$y^+$','interpreter','latex','fontsize',24)
ylabel('$U^+$','interpreter','latex','fontsize',24)
legend('MEAN','\kappa = 0.39,B=4.3','location','southeast')
set(gca,'fontsize',24)
print('mean','-dpng')

%semilogx((Actual_Positions(:,3)+250)/10^6/yplus,meanHW/utau,'o')
%semilogx((Actual_Positions(:,3)+250)./nu.*utau,varHW./utau^2,'o')
%% Check values
% 
% %static_pressure_atm = mean(Data(:,3).*9.87E-6);
% %static_pressure_psi = mean(Tunnel_static_psi);
% Re_mean = mean(Re);
% Rho_mean = mean(Rho);
% TempC = mean(Data(:,1))-273.15;
% %CreateStruct.Interpreter='tex';
% msg = msgbox({['Test Name: ' aaaa_Test_Name] ...
%      ' '...
%     ['Static Pressure: ' num2str(static_pressure_psi, '%1.2f') ' [psi]'] ...
%     ['Static Pressure: ' num2str(static_pressure_atm, '%1.2f') ' [atm]'] ...    
%     ['Reynolds Number: ' num2str(Re_mean, '%1.2e') ' [-]'] ...
%     ['Density: ' num2str(Rho_mean, '%1.2f') ' [kg/m^3]'] ...
%     ['Temperature: ' num2str(TempC, '%1.1f') ' [deg. C]'] ...
%     },'Mean Values');


%%
% Temp_C = mean(TempK-273.15)
% Re_mean = mean(Re)
% U_mean = mean(U_inf)
% Rho_mean = mean (Rho)



save('allData')




