
clear
cd('Precal'); load('summary.mat','U','V','TempK');cd ..
U_pre = U; V_pre= V; T_pre = TempK;
cd('Postcal'); load('summary.mat','U','V','TempK');cd ..
U_post = U; V_post=V; T_post = TempK;
cd('Data');load('acquisition.mat'); cd ..
%%
poly_deg = 4;
U_cutoff = 1;

U_all = [U_pre,U_post];
V_all = [V_pre,V_post];
T_all = [T_pre,T_post];
cal_data = find(U_all>U_cutoff);

T_ref = T_pre(1);
T_w = data.Thot;

V_corr = @(V,Ta) V.*sqrt((T_w-T_ref)./(T_w-Ta));

plot(U_post,V_corr(V_post,T_post),'ro')
hold on
plot(U_pre,V_corr(V_pre,T_pre),'bo')
plot(U_all(cal_data),V_corr(V_all(cal_data),T_all(cal_data)),'kx')

xlabel('U (m/s)')
ylabel('V (Volts)')
legend('Precal','Postcal','location','southeast')
set(gca,'fontsize',24)
%%
[P,S] = polyfit(V_corr(V_all(cal_data),T_all(cal_data)),U_all(cal_data),poly_deg);
[Ppre,Spre] = polyfit(V_corr(V_pre(U_pre>U_cutoff),T_pre(U_pre>U_cutoff)),...
    U_pre(U_pre>U_cutoff),poly_deg);
[Ppost,Spost] = polyfit(V_corr(V_post(U_post>U_cutoff),T_post(U_post>U_cutoff)),...
    U_post(U_post>U_cutoff),poly_deg);
f = @(P,V,T) polyval(P,V_corr(V,T));
%S.normr %=sqrt(sum((U_all(cal_data)-f(P,V_all(cal_data),T_all(cal_data))).^2))
rsq = 1 - S.normr^2 / ((length(U_all(cal_data))-1) * var(U_all(cal_data)))...
    .*(length(cal_data)-1)/(length(cal_data)-length(P));

Vs = linspace(min(V_all),max(V_all),100);
plot(f(P,Vs,T_pre(1)),Vs,'k')
plot(f(Ppre,Vs,T_pre(1)),Vs,'r')
plot(f(Ppost,Vs,T_pre(1)),Vs,'b')
hold off
print('cal','-dpng')

%%
meanU = data.ySet*0;
varU = data.ySet*0;
tic
cd('Data')
for i  = 1:data.numPos
    temp = fread(fopen(data.name{i},'r'),[data.dur*data.rate,2],'single');
    hwData = f(P,temp(:,2),data.TempK(i));
    meanU(i) = mean(hwData);
    varU(i) = var(hwData);
    fprintf('Processed %i/%i - %0.2f sec\n',i,data.numPos,toc)
    
end
cd ..
%%
load('dpdx.mat')

figure(1)
semilogx(data.yActual./eta,meanU./utau,'-bo')
xlabel('y^+')
ylabel('U^+')

figure(2)
semilogx(data.yActual./eta,varU./utau.^2,'-bo')
xlabel('y^+')
ylabel('u^2^+')
%%

figure(1)
hold on
semilogx(y_plus,U_plus,'-')
figure(2)
hold on
semilogx(y_plus,u2_plus,'-')