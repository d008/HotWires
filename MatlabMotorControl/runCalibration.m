% Gather Daq Devices
clc
motor =1;
direc = uigetdir;
addpath(pwd);
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(direc,'Precal');
cd(direc);cd('Precal')
% %%
% d = daq.getDevices;
% daqCal = daq.createSession('ni')
% 
% % Add Channels to daq
% addAnalogOutputChannel(daqCal,'Dev4','ao0','Voltage');  % Motor Controller Voltage
% 
% addAnalogInputChannel(daqCal,'Dev4','ai0','Voltage');   % Temperature
% addAnalogInputChannel(daqCal,'Dev4','ai2','Voltage');   % Tunnel Static Pressure
% addAnalogInputChannel(daqCal,'Dev4','ai3','Voltage');   % Hotwire
% 
% %addAnalogInputChannel(daqCal,'Dev4','ai1','Voltage');   % Scanivalve
% %addAnalogInputChannel(daqCal,'Dev4','ai7','Voltage');   % Limit Switch
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%Select Proper Transducer
transducer = 0.2; %psi
% transducer = 1; %psi
% transducer = 5; %psi
switch(transducer)
    case 0.2
        disp('0.2 psi transducer chosen')
        %addAnalogInputChannel(daqCal,'Dev4','ai4','Voltage');   % 0.2 PSI transducer
    case 1
        disp('1 psi transducer chosen')
        % addAnalogInputChannel(daqCal,'Dev4','ai5','Voltage');   % 1 PSI transducer
    case 5
        disp('5 psi transducer chosen')
        % addAnalogInputChannel(daqCal,'Dev4','ai6','Voltage');   % 5 PSI transducer
    otherwise
        disp('0.2 psi transducer default')
        %addAnalogInputChannel(daqCal,'Dev4','ai4','Voltage');   % 0.2 PSI transducer
end
%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Default motor to 0
% daqCal.outputSingleScan(0)
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calibration Parameters
daqCal.Rate = 10000;    % Data acquisition frequency
sampleDuration = 9;     % Data sample time
N = 4;                 % Number of samples
Vmax = 6.8;             % Max voltage (0-10V)
rampSpeed = .1;       % V/sec


Vout = zeros(sampleDuration*daqCal.Rate,1);
Vs = linspace(Vmax,0,N);
diffVs = [Vs(1), diff(Vs)];
Vset = 0;
% Set the pause criteria
pauseTimes = Vs*0+30;       %Default wait time 30 seconds
pauseTimes(Vs <= 4) = 1;%5*60; %Velocities less than ~10m/s wait 5 min
pauseTimes(Vs > 4) = 1; %20;    %Velocities larger than ~10m/s wait 20 sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Iteration
figure(1)
clf
xlabel('U (m/s)')
ylabel('Voltage')
hold on
for i = 1:N
    %Ramp
    rampTime = abs(diffVs(i))/rampSpeed;
    fprintf('Starting point - %d/%d :\n\tRamping to %0.3f for %0.3f sec \n',i,N,Vs(i),rampTime)
    
    %%% version 0.1 of Ramp
    % %     tic
    % %     while (toc < rampTime)
    % %         Vtemp = Vset + toc*rampSpeed*sign(diffVs(i));
    % %         %daqCal.outputSingleScan(Vtemp)
    % %         pause(.1)
    % %     end
    % %     Vset = Vs(i);
    % %     %daqCal.outputSingleScan(Vtemp)
    
    %%%% Simpler Ramp
    %queueOutputData(daqCal,linspace(Vset,V(i),daqCal.Rate*rampTime))
    %daqCal.startForeground();
    
    fprintf('\tPausing for %d seconds \n',pauseTimes(i))
    pause(pauseTimes(i));
    fprintf('\tTaking data for %d seconds \n',sampleDuration)
    
    
    %%% Data Acquisition
    %queueOutputData(daqCal,Vout+Vset)
    %[captured_data,time] = daqCal.startForeground();
    
    %%% Temporary Data
    captured_data = [Vout+0.225,Vout+0.0368*5,Vout+Vs(i),Vout+Vs(i)/4]; %TEMPORARY
    
    %%% Save the data
    data = struct('TempK',mean(captured_data(:,1))*100+273.15,...
        'Static_Pa',mean(captured_data(:,2)).*(4000/10).*6894.75729,...
        'V',mean(captured_data(:,3)),...
        'Pitot_Pa',mean(captured_data(:,4))*transducer/5*6894.75729,...
        'Raw',captured_data,...
        'Rate',daqCal.Rate,...
        'sampleDuration',sampleDuration);
    data.rho = ZSI(data.TempK,data.Static_Pa);
    if i == 1
        calData{1} = data;
    end
    data.Pitot_Pa = data.Pitot_Pa - calData{1}.Pitot_Pa;
    data.U = sqrt(2/data.rho*data.Pitot_Pa);
    calData{i} = data;
    tempName= sprintf('Raw%d.mat',i);
    fprintf('\tSaving Data as %s \n\n',tempName)
    save(tempName,'data');
    
    plot(data.U,data.V,'o')
    U(i) = data.U;
    V(i) = data.V;
    TempK(i) = data.TempK;
    Static_Pa(i) = data.Static_Pa;
    Pitot_Pa(i) = data.Pitot_Pa;
    
    
end
hold off
save('all.mat','calData')
save('summary.mat','U','V','TempK','Static_Pa','Pitot_Pa')

clearvars -except motor