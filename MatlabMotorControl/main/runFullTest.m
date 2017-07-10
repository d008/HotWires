%% Run Motor Setup
clc
[pathstr,name,ext] = fileparts(mfilename('fullpath'));
addpath(pathstr);
cd(pathstr);

%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPos = 10;        % Number of y points
ymin = 170e-3;      % Closest point to the wall (mm)
ymax = 50;          % Furthest point to the wall (mm)
ySet = logspace(log10(ymin),log10(ymax),numPos);    %Y - Location set points

yActual = ySet*0;
meanU = ySet*0;
varU = ySet*0;

NSTAP.Gain = 64;          %Gain on the Dantec
NSTAP.Offset = -0.776;    %Voltage
NSTAP.R0=146.8;
NSTAP.Rext = 212;
NSTAP.alpha = 2e-3;
NSTAP.Thot = (NSTAP.Rext/NSTAP.R0-1)./NSTAP.alpha;
disp('Are the following testing parameters correct [Press Enter]?')
reply = input(sprintf('Gain: %i\nOffset: %0.3f V\nR_0: %0.2f ohms\nRext: %0.2f ohms\n',...
    NSTAP.Gain,NSTAP.Offset,NSTAP.R0,NSTAP.Rext));
%% Sampling Parameters
rate = 300000;    % Data acquisition frequency
dur = 90;           % Data sample time sec
Vset = 6.0;              % Voltage Set point
rampSpeed = .1;          % V/sec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate Precal file
direc = uigetdir;
fname = 'Precal';mkdir(direc,fname);
cd(direc);cd(fname)
clc
%% Query centerline
m = traverse();
center = input('Centerline position (mm)? : ');
while isempty(center)
    center = input('\n Empty input: Centerline position (mm)? : ');
end
[pos,~] = m.locate();
fprintf('Current location is %0.4f mm \n\n',pos)
fprintf('Press enter to move %0.4f mm?\n',center-pos)
pause

% Move to centerline for Precal
disp('Moving to Centerline')
[pos,~] = m.move(center-pos);
if abs(center - pos) > 0.3
    [~,~] = m.move(center-pos);
end

%% Start Precal
disp('Starting Precal')
Vtemp = runCalibration(fname);
load('summary.mat','U','V');
poly_deg = 4;U_cutoff = 1;
[P,S] = polyfit(V(U > U_cutoff),U(U > U_cutoff),poly_deg);
cd ..
DAQSetup
%% Ramp tunnel speed to set voltage
%Add motor out
disp('Adding motor channel')
ch = addAnalogOutputChannel(daqCal,'Dev4',MotorOut.Channel,'Voltage');% Motor Controller Voltage
ch.Name = MotorOut.Name;
ch.Range = MotorOut.Range;
%%
%Ramp to setpoint and remove channel
disp('Ramping motor down')
queueOutputData(daqCal,linspace(Vtemp,Vset,daqCal.Rate/rampSpeed*abs(Vset-Vtemp))');
daqCal.startForeground();
daqCal.removeChannel(length(daqCal.Channels));

%Wait for the speed to stabilize
disp('Pausing for 20 seconds')
pause(20);
%% dPdX
disp('Finding dp/dx')
dpdx();
load('dpdx.mat', 'utau', 'eta');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data folder
fname = 'Data';mkdir(direc,fname);
cd(direc);cd(fname);
%% Move to wall
[pos, pos2] = m.locate();
pos = m.move(-pos2);
[pos, pos2] = m.locate();
disp(sprintf('Current location is %0.4f mm \n',pos))
for i = 1:numPos
    fprintf('Starting point - %d/%d :\n\tMoving to %d um\n',i,numPos,round(yActual(i)*1000))
    if(i > 1)
        pos = m.move(ySet(i)-pos);
    end
    yActual(i) = pos;
    
    %Take the Temperature & Static Pressure
    ichan =  {Temperature,TunnelStatic};
    %Add input channels
    for j = 1:length(ichan)
        ch = addAnalogInputChannel(daqCal,'Dev4',ichan{j}.Channel,'Voltage');% Motor Controller Voltage
        ch.Name = ichan{j}.Name;
        ch.Range = ichan{j}.Range;
    end
    daqCal.Rate = 10000;
    daqCal.DurationInSeconds = 10;
    fprintf('\tSampling the temperature and static pressure for %d secs\n',daqCal.DurationInSeconds)
    pre_data = daqCal.startForeground();
    daqCal.removeChannel(1:length(daqCal.Channels))
    
    %Take the hotwire data
    ichan =  {Dantec};
    %Add input channels
    for j = 1:length(ichan)
        ch = addAnalogInputChannel(daqCal,'Dev4',ichan{j}.Channel,'Voltage');% Motor Controller Voltage
        ch.Name = ichan{j}.Name;
        ch.Range = ichan{j}.Range;
    end
    daqCal.Rate = rate;
    daqCal.DurationInSeconds = dur;
    
    fprintf('\tSampling the Dantec for %d secs\n',daqCal.DurationInSeconds)
    [data_hw,time] = daqCal.startForeground();
    daqCal.removeChannel(1:length(daqCal.Channels));
        
    fprintf('\tConverting Data with Precal\n')
    hwdata = Dantec.cal(P,data_hw);
    meanU(i) = mean(hwdata);
    varU(i) = var(hwdata);
    
    %Plots the raw signal
    figure(1)
    semilogx(ySet(1:i)./eta,meanU(1:i),'bo-')
    xlabel('y^+')
    ylabel('U(m/s)')
    
    %Plots the raw signal
    figure(2)
    semilogx(ySet(1:i)./eta,varU(1:i),'bo-')
    xlabel('y^+')
    ylabel('u^2(m/s)')
    
    drawnow
    
    name = sprintf('V%0.2f_Index%i_YLoc%0.2f.bin',Vset,i,ySet(i)*1000);
    fid = fopen(name,'wb');
    fwrite(fid,[time,data_hw],'ubit16'); %
    fclose(fid);
    %fread(fid,[daqSampleTime*daqSampleFreq],'ubit16');
end
%% Ramp down for the Postcal
%Add motor out
disp('Adding motor channel')
ch = addAnalogOutputChannel(daqCal,'Dev4',MotorOut.Channel,'Voltage');% Motor Controller Voltage
ch.Name = MotorOut.Name;
ch.Range = MotorOut.Range;

%Ramp to setpoint and remove channel
disp('Ramping motor down')
daqCal.rate = 1000;
queueOutputData(daqCal,linspace(Vset,0,daqCal.Rate/rampSpeed*abs(Vset)));
daqCal.startForeground();
daqCal.removeChannel(length(daqCal.Channels));

%% Generate Postcal file
fname = 'Postcal';mkdir(direc,fname);
cd(direc);cd(fname);
%% Move to centerline for Postcal
disp('Moving to Centerline')
[pos,~] = m.move(center-pos);
if abs(center - pos) > 0.3
    [~,~] = m.move(center-pos);
end
%% Start Postcal
disp('Starting Postcal')
Vtemp = runCalibration(fname);
%% Ramp voltage down
queueOutputData(daqCal,linspace(Vtemp,0,daqCal.Rate/rampSpeed*abs(Vtemp))');
daqCal.startForeground();
cd ..
%release(daqCal);
