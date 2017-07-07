%% Run Motor Setup
clc
%setup
%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPos = 40;        % Number of y points 
ymin = 170e-3;      % Closest point to the wall (mm)
ymax = 67;          % Furthest point to the wall (mm)
ySet = logspace(log10(ymin),log10(ymax),numPos);    %Y - Location set points
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate Precal file
direc = uigetdir;
fname = 'Precal';mkdir(direc,fname);
cd(direc);cd(fname)
clc
%% Query centerline
center = input('Centerline position (mm)? : ');
while isempty(center)
    center = input('\n Empty input: Centerline position (mm)? : ');
end
% pos = locate(motor);
% disp(sprintf('Current location is %0.4f mm \n',pos))
% disp(sprintf('Press enter to move %0.4f mm?',center-pos))
% pause

%% Move to centerline for Precal
% disp('Moving to Centerline')
% [pos,trav] = move(center-pos,motor,2000*256,256);
% if abs(center - pos) > 0.3
%     [pos,trav] = move(center-pos,motor,2000*256,256);
% end
%% DAQ Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% d = daq.getDevices; daqCal = daq.createSession('ni')
% 
% % Add Channels to daq
% addAnalogOutputChannel(daqCal,'Dev4','ao0','Voltage');          % Motor
% Controller Voltage
% 
% addAnalogInputChannel(daqCal,'Dev4','ai0','Voltage');           % Temperature
% addAnalogInputChannel(daqCal,'Dev4','ai2','Voltage');           % Tunnel Static
% Pressure addAnalogInputChannel(daqCal,'Dev4','ai3','Voltage');  % Hotwire
% 
% %addAnalogInputChannel(daqCal,'Dev4','ai1','Voltage');          % Scanivalve
% %addAnalogInputChannel(daqCal,'Dev4','ai7','Voltage');          % Limit Switch
% %% Default motor to 0
% daqCal.outputSingleScan(0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start Precal
disp('Starting Precal')
Vtemp = runCalibration(fname,daqCal)
%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daqCal.Rate = 300000;    % Data acquisition frequency
sampleDuration = 90;     % Data sample time sec
Vset = 6.8;              % Voltage Set point
Vout = zeros(sampleDuration*daqCal.Rate,1)+Vset;
rampSpeed = .1;          % V/sec

%% Ramp voltage to test point
%queueOutputData(daqCal,linspace(Vtemp,Vset,daqCal.Rate/rampSpeed*abs(Vset-Vtemp)));
%daqCal.startForeground();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Move to wall
% [pos, pos2] = locate(motor);
% pos = move(-pos2,motor,2000*256,256);
% [pos, pos2] = locate(motor);
% disp(sprintf('Current location is %0.4f mm \n',pos))
for i = 1:numPos
    if(i > 1)
        % pos = move(ySet(i),motor,2000*256,256);
    end
    yActual(i) = pos;
    %queueOutputData(daqCal,Vout);
    %[captured_data,time] = daqCal.startForeground();

end


%% Generate Postcal file
fname = 'Postcal';mkdir(direc,fname);
cd(direc);cd(fname)

%% Move to centerline for Postcal
% disp('Moving to Centerline')
% [pos,trav] = move(center-pos,motor,2000*256,256);
% if abs(center - pos) > 0.3
%     [pos,trav] = move(center-pos,motor,2000*256,256);
% end
%% Start Postcal
disp('Starting Postcal')
Vtemp = runCalibration(fname,daqCal)

