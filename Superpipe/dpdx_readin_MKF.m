%%%%%% dpdx Read in %%%%%%%


fprintf('Select Pressure Drop File')

[filename,path] = uigetfile('*dPdX.txt','Select the pressure file');




%% Read in
delimiter = '\t';
formatSpec = '%f%f%f%f%f%[^\n\r]';
fileID = fopen([path filename],'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);
fclose(fileID);
dpdx = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;

%% Torr to Pascal Conversion

dpdx(:,3) = dpdx(:,2) .* 133.322;
%% Plot
D = 0.1298448;
dx = 25*D/19;
figure
plot(dpdx(3:end,1),dpdx(3:end,3),'-+')
grid on
xlabel('Tap [-]','Interpreter','LaTex','FontSize',20)
ylabel('Pressure [Pa]','Interpreter','LaTex','FontSize',20)
title('Streamwise Pressure Gradient - $dpdx$','Interpreter','LaTex','FontSize',15)
mean(diff(dpdx(3:end,3)))./dx
DPDX=fit(dpdx(3:end,1).*dx,dpdx(3:end,3),'poly1');
DPDX = DPDX.p1
save('dpdx.mat','DPDX','D');
clear all