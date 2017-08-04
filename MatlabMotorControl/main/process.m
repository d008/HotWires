clear

%% Load the pre and post calibration files
load('dpdx.mat','utau','eta')
cd('Precal'); load('summary.mat','U','V','TempK');cd ..
U_pre = U; V_pre= V; T_pre = TempK;
cd('Postcal'); load('summary.mat','U','V','TempK');cd ..
U_post = U; V_post=V; T_post = TempK;
cd('Data');load('acquisition.mat'); cd ..
y_plus = data.yActual./eta;
%% Compute the polynomials
poly_deg = 4;U_cutoff = 1;

U_all = [U_pre,U_post]; V_all = [V_pre,V_post]; T_all = [T_pre,T_post];
cal_data = find(U_all>U_cutoff);

T_ref = T_pre(1);   T_w = data.Thot;

V_corr = @(V,Ta) V.*sqrt((T_w-T_ref)./(T_w-Ta));
%Both calibrations
[P,S] = polyfit(V_corr(V_all(cal_data),T_all(cal_data)),U_all(cal_data),poly_deg);
%Precalibration
[Ppre,Spre] = polyfit(V_corr(V_pre(U_pre>U_cutoff),T_pre(U_pre>U_cutoff)),...
    U_pre(U_pre>U_cutoff),poly_deg);
%Postcalibration
[Ppost,Spost] = polyfit(V_corr(V_post(U_post>U_cutoff),T_post(U_post>U_cutoff)),...
    U_post(U_post>U_cutoff),poly_deg);

f = @(P,V,T) polyval(P,V_corr(V,T));
%S.normr %=sqrt(sum((U_all(cal_data)-f(P,V_all(cal_data),T_all(cal_data))).^2))
rsq = 1 - S.normr^2 / ((length(U_all(cal_data))-1) * var(U_all(cal_data)))...
    .*(length(cal_data)-1)/(length(cal_data)-length(P));

%%  Plots the pre and post cals
figure(1)
clf

Vs = linspace(min(V_all),max(V_all),100);
plot(U_post,V_corr(V_post,T_post),'ro')
hold on
plot(U_pre,V_corr(V_pre,T_pre),'bo')
plot(U_all(cal_data),V_corr(V_all(cal_data),T_all(cal_data)),'kx')
set(gca,'fontsize',24)
plot(f(P,Vs,T_pre(1)),Vs,'k')
plot(f(Ppre,Vs,T_pre(1)),Vs,'b')
plot(f(Ppost,Vs,T_pre(1)),Vs,'r')

xlabel('U (m/s)')
ylabel('V (Volts)')
legend('Postcal','Precal','location','southeast')
hold off
print('cal','-dpng')

cal_curve.P = P;        cal_curve.S = S;
cal_curve.Ppre = Ppre;  cal_curve.Spre = Spre;
cal_curve.Ppost = Ppost;  cal_curve.Spost = Spost;

%%
meanU = data.ySet*0;varU = data.ySet*0;skewU = data.ySet*0;
var2U = data.ySet*0;

spec.N = 2^17;            %Number of freq
spec.overlap = 1/4;
spec.dt = 1./data.rate;
spec.T = spec.dt*(spec.N-1);
spec.df = 1./spec.dt;
spec.f = [-spec.N/2:(spec.N-1)./2]./(spec.N.*spec.dt);

%num_bins = floor(2^(floor(log2(data.dur*data.rate/spec.N))) / spec.overlap);
num_bins = floor((data.dur*data.rate/spec.N-1)/(1-spec.overlap));
clear bins
for j = 0:num_bins
    temp = floor(j*(spec.N)*spec.overlap)+1;
    bins(j+1,:) = [temp,temp+spec.N-1];
end
%%
%tic
cd('Data')
%parObj = parpool(4)
tic
%E = zeros(spec.N+1,data.numPos);
%%
for i  = 1:data.numPos
    fl = fopen(data.name{i},'r');
    temp = fread(fl,[data.dur*data.rate,2],'single');
    fclose(fl);
    hwData = f(P,temp(:,2),data.TempK(i));
    meanU(i) = mean(hwData);
    varU(i) = var(hwData);
    skewU(i) = skewness(hwData);
    kurtU(i) = kurtosis(hwData);
    E_bin = zeros(spec.N+1,num_bins);
    Sp(i) = sum(abs(hwData-mean(hwData))<1.5*utau)./length(hwData);
%     for j = 1:num_bins
%         fluc_bin(:,j) = hwData(bins(j,1):bins(j,2))-meanU(i);
%     end
%   X = fftshift(fft(fluc_bin));
%   E(:,i) = mean(X.*conj(X)./(spec.T).*spec.dt^2,2);
    [PXX,F] = pwelch(hwData-mean(hwData),2^17,2^16,2^17,spec.df);
    E(:,i) = PXX;
    fprintf('Processed %i/%i - %0.2f sec\n',i,data.numPos,toc)
    var2U(i) = trapz(F,E(:,i));
end
%delete(parObj);
toc

%%
% figure(2)
% semilogx(data.yActual./eta,meanU./utau,'-bo')
% xlabel('y^+')
% ylabel('U^+')

figure(3)
semilogx(data.yActual./eta,var2U./utau.^2,'-bo')
hold on
semilogy(data.yActual./eta,varU./utau.^2,'-rs')
xlabel('y^+')
ylabel('u^2^+')

% figure(4)
% semilogx(data.yActual./eta,skewU,'-bo')
% xlabel('y^+')
% ylabel('S')
%
% figure(5)
% semilogx(data.yActual./eta,kurtU,'-bo')
% xlabel('y^+')
% ylabel('K')
%
% figure(6)
% semilogx(data.yActual./eta,Sp,'-bo')
% xlabel('y^+')
% ylabel('S')

y_plus = data.yActual./eta;
U_plus = meanU./utau;
u2_plus = varU./utau.^2;
cal_curve.P = P;cal_curve.S = S;
cal_curve.Ppre = Ppre;cal_curve.Spre = Spre;
cal_curve.Ppost = Ppost;cal_curve.Spost = Spost;
save('acquisition.mat','y_plus','meanU','u2_plus','varU','U_plus','skewU','cal_curve','-append')
cd ..
%%
% load('re150000.mat')
% figure(2)
% hold on
% semilogx(y_plus,U_plus,'-')
% figure(3)
% hold on
% semilogx(y_plus,u2_plus,'-')
% %%
% figure(5)
% [ys,fs]= meshgrid(y_plus,spec.f);
% [Us,fs]= meshgrid(meanU,spec.f);
% contourf(ys,(Us./fs./data.D*2).^(1),E./(Us./fs)./utau^2,10);
% shading interp
% colorbar
clf
hold on
for i =1:40
    y_plus(i)
    k1y = F'./meanU(i).*eta/1000;
    loglog(F,medfilt1(E(:,i)./utau.^2,50),'-')
end
% plot(k1y,k1y.^(-5/3)/100)
% plot(k1y,k1y.^(-1)/100)
hold off
ax = gca;
ax.XScale= 'log'
%ax.YScale= 'log'
