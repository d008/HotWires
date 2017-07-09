% Gather Daq Devices
function [Vset] = runCalibration(varargin)
%%
if nargin<1;
    [pathstr,name,ext] = fileparts(mfilename('fullpath'));
    cd(pathstr);
    direc = uigetdir;
    fname = input('Folder name: ','s');
    [SUCCESS,MESSAGE,MESSAGEID] = mkdir(direc,fname);
    cd(direc);cd(fname)
end
clc
DAQSetup
%% Select Proper Transducer
transducer = Pitot02;
ch = addDigitalChannel(daqCal,'Dev4',transducer.DChannel,'OutputOnly');% Motor Controller Voltage
outputSingleScan(daqCal,1);
daqCal.removeChannel(length(daqCal.Channels))

ochan= MotorOut;
ichan =  {Temperature,TunnelStatic,Dantec,transducer};

%Add motor out
ch = addAnalogOutputChannel(daqCal,'Dev4',MotorOut.Channel,'Voltage');% Motor Controller Voltage
ch.Name = MotorOut.Name;
ch.Range = MotorOut.Range;

%Add input channels
for i = 1:length(ichan)
    ch = addAnalogInputChannel(daqCal,'Dev4',ichan{i}.Channel,'Voltage');% Motor Controller Voltage
    ch.Name = ichan{i}.Name;
    ch.Range = ichan{i}.Range;
end

%% Default motor to 0
daqCal.outputSingleScan(0);

%% Calibration Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daqCal.Rate = 10000;    % Data acquisition frequency
sampleDuration = 90;     % Data sample time
numPoints = 20;          % Number of samples
Vmax = 6.8;             % Max voltage (0-10V)
rampSpeed = .04;         % V/sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Vout = zeros(sampleDuration*daqCal.Rate,1);
Vs = linspace(0,Vmax,numPoints);
diffVs = [Vs(1), diff(Vs)];
Vset = 0;

%% Set the pause criteria
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pauseTimes = Vs*0+30;       %Default wait time 30 seconds
pauseTimes(Vs <= 3) = 60; %Velocities less than ~10m/s wait 5 min
pauseTimes(Vs > 3) = 20;    %Velocities larger than ~10m/s wait 20 sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Iteration
figure(1)
clf
xlabel('U (m/s)')
ylabel('Voltage')
hold on
for i = 1:numPoints
    %Ramp
    rampTime = abs(diffVs(i))/rampSpeed;
    fprintf('Starting point - %d/%d :\n\tRamping to %0.3f for %0.3f sec \n',i,numPoints,Vs(i),rampTime)
    
    %%% Simpler Ramp
    if round(daqCal.Rate*rampTime) > 0
        queueOutputData(daqCal,linspace(Vset,Vs(i),round(daqCal.Rate*rampTime))');
        daqCal.startForeground();
    end
    Vset = Vs(i);
    fprintf('\tPausing for %d seconds \n',pauseTimes(i))
    pause(pauseTimes(i));
    fprintf('\tTaking data for %d seconds \n',sampleDuration)
    
    
    %% Data Acquisition
    queueOutputData(daqCal,Vout+Vset);
    [captured_data,time] = daqCal.startForeground();
    
    %%% Save the data
    data = struct('TempK',mean(captured_data(:,1)),...
        'Static_Pa',mean(captured_data(:,2)),...
        'V',mean(captured_data(:,3)),...
        'Pitot_Pa',mean(captured_data(:,4)),...
        'Raw',captured_data,...
        'Rate',daqCal.Rate,...
        'sampleDuration',sampleDuration);
    data.rho = ZSI(Temperature.cal(data.TempK),TunnelStatic.cal(data.Static_Pa)+101325);
    if i == 1
        calData{1} = data;
    end
    %data.Pitot_Pa = data.Pitot_Pa;% - calData{1}.Pitot_Pa;
    data.U = sqrt(2/data.rho*transducer.cal(data.Pitot_Pa - calData{1}.Pitot_Pa));
    calData{i} = data;
    tempName= sprintf('Raw%d.mat',i);
    fprintf('\tSaving Data as %s \n\n',tempName)
    save(tempName,'data');
    
    plot(data.U,data.V,'bo')
    U(i) = data.U;
    V(i) = data.V;
    TempK(i) = data.TempK;
    Static_Pa(i) = data.Static_Pa;
    Pitot_Pa(i) = data.Pitot_Pa;
    
    
end
hold off
save('all.mat','calData')
save('summary.mat','U','V','TempK','Static_Pa','Pitot_Pa','ichan')

ch = addDigitalChannel(daqCal,'Dev4',transducer.DChannel,'OutputOnly');% Motor Controller Voltage
outputSingleScan(daqCal,0);
daqCal.removeChannel(length(daqCal.Channels))

%DOWN RAMP
% daqCal.Rate = 100;
% rampTime = Vset/rampSpeed;
% queueOutputData(daqCal,linspace(Vset,0,round(daqCal.Rate*rampTime))');
% daqCal.startForeground();
end
