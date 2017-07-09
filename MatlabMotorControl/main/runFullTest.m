%% Run Motor Setup
clc
[pathstr,name,ext] = fileparts(mfilename('fullpath'));
addpath(pathstr);
cd(pathstr);

%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPos = 40;        % Number of y points 
ymin = 170e-3;      % Closest point to the wall (mm)
ymax = 67;          % Furthest point to the wall (mm)
ySet = logspace(log10(ymin),log10(ymax),numPos);    %Y - Location set points

Gain = 64;
Offset = -0.776;
R0=146.8;
Rext = 212;
alpha = 2e-3;
Thot = (Rext/R0-1)./alpha;
disp('Are the following testing parameters correct [Y/N]?')
reply = input(sprintf('Gain: %i\nOffset: %0.3f V\nR_0: %0.2f ohms\nRext: %0.2f ohms\n',Gain,Offset,R0,Rext))

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
pos = locate(motor);
disp(sprintf('Current location is %0.4f mm \n',pos))
disp(sprintf('Press enter to move %0.4f mm?',center-pos))
pause

% Move to centerline for Precal
disp('Moving to Centerline')
[pos,trav] = move(center-pos,motor,2000*256,256);
if abs(center - pos) > 0.3
    [pos,trav] = move(center-pos,motor,2000*256,256);
end

%% Start Precal
disp('Starting Precal')
Vtemp = runCalibration(fname)
cd ..
%% DAQ Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MotorOut.Channel = 'ao0'; MotorOut.Name = 'MotorOut';
MotorOut.Range = [-10,10];

Temperature.Channel = 'ai0';        Temperature.cal = @(V) V*100+273.15; %kelvin
Temperature.Name = 'Temperature';   Temperature.Range = [-10,10];

Scanivalve.Channel = 'ai1';         Scanivalve.cal = @(V)   V.* 133.322; %1V/torr
Scanivalve.Name = 'Scanivalve';     Scanivalve.Range = [-10,10];

TunnelStatic.Channel = 'ai2';       TunnelStatic.cal = @(V) V.*4000/10.*6894.75729;
TunnelStatic.Name = 'TunnelStatic'; TunnelStatic.Range = [-10,10];

Dantec.Channel = 'ai3';             Dantec.cal = @(V,P) @(P,V) polyval(P,V);
Dantec.Name = 'Dantec';             Dantec.Range = [-10,10];

% Dantec.Channel = 'ai6';           Dantec.cal = @(V,P) @(P,V) polyval(P,V);
% Dantec.Name = 'Dantec';           Dantec.Range = [-10,10];

Pitot02.Channel = 'ai4';            Pitot02.cal = @(V) V*0.2/5*6894.75729; %0.2psi/5V
Pitot02.Name = 'Pitot02';           Pitot02.Range = [-5,5];

Pitot1.Channel = 'ai5';             Pitot1.cal = @(V) V*1/5*6894.75729; %1psi/5V
Pitot1.Name = 'Pitot1';             Pitot1.Range = [-5,5];

Pitot5.Channel = 'ai6';             Pitot5.cal = @(V) V*5/5*6894.75729; %1psi/5V
Pitot5.Name = 'Pitot5';             Pitot5.Range = [-5,5];

LimitSwitch.Channel = 'ai7';        LimitSwitch.cal = @(V) min(V)>1;
LimitSwitch.Name = 'LimitSwitch';   LimitSwitch.Range = [-10,10];

d = daq.getDevices; daqCal = daq.createSession('ni')
%% Select Proper Transducer
transducer = Pitot02;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daqCal.Rate = 300000;    % Data acquisition frequency
sampleDuration = 90;     % Data sample time sec
Vset = 6.8;              % Voltage Set point
Vout = zeros(sampleDuration*daqCal.Rate,1)+Vset;
rampSpeed = .1;          % V/sec

%% Ramp voltage to test point
queueOutputData(daqCal,linspace(Vtemp,Vset,daqCal.Rate/rampSpeed*abs(Vset-Vtemp)));
daqCal.startForeground();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Data folder
fname = 'Data';mkdir(direc,fname);
cd(direc);cd(fname);
%% Move to wall
[pos, pos2] = locate(motor);
pos = move(-pos2,motor,2000*256,256);
[pos, pos2] = locate(motor);
disp(sprintf('Current location is %0.4f mm \n',pos))
for i = 1:numPos
    if(i > 1)
        pos = move(ySet(i),motor,2000*256,256);
    end
    yActual(i) = pos;
    queueOutputData(daqCal,Vout);
    [data_hw,time] = daqCal.startForeground();
    name = sprintf('V%0.2f_Index%i_YLoc%0.2f.bin',6.8,i,ySet(i)*1000)
    fid = fopen(name,'wb')
    fwrite(fid,[time,data_hw],'ubit16') %
    fclose(fid);
    %fread(fid,[daqSampleTime*daqSampleFreq],'ubit16');
end


%% Generate Postcal file
fname = 'Postcal';mkdir(direc,fname);
cd(direc);cd(fname);
%% Move to centerline for Postcal
disp('Moving to Centerline')
[pos,trav] = move(center-pos,motor,2000*256,256);
if abs(center - pos) > 0.3
    [pos,trav] = move(center-pos,motor,2000*256,256);
end
%% Start Postcal
disp('Starting Postcal')
Vtemp = runCalibration(fname);
%% Ramp voltage down
queueOutputData(daqCal,linspace(Vtemp,0,daqCal.Rate/rampSpeed*abs(Vset-Vtemp)));
daqCal.startForeground();
cd ..
%release(daqCal);
