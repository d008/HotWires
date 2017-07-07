%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
[pathstr,name,ext] = fileparts(mfilename('fullpath'));
cd(pathstr); cd ..;cd ..;
addpath(genpath(pwd));
cd(pathstr);

%% functions
%function motorSetup()
warning('off')
% Connect to motor
%motor = instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', '')
motor = instrfind('Type', 'visa-serial', 'RsrcName', 'ASRL5::INSTR', 'Tag', '')
if isempty(motor)
    motor = visa('NI', 'ASRL5::INSTR');
else
    fclose(motor);
    motor = motor(1);
end
set(motor, 'Terminator', {'CR','CR'});
set(motor, 'Timeout', 0.01);
fopen(motor);
global motor

% Create the serial port object if it does not exist
% otherwise use the object that was found.
%query(motor,'/1?8')
% Flush the data in the input buffer.
flushinput(motor);
% fclose(motor);
locate(motor)
step = 256; speed = 2000*step;


% d = daq.getDevices;
% s = daq.createSession('ni')
% addAnalogInputChannel(s,'Dev4','ai7','Voltage');
% s.Rate = 25000;
% s.IsContinuous = false;
% s.DurationInSeconds = 0.01;


%% Default Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default motor settings
motorSettings = struct();
%running current 0-100% of 3 Amps
motorSettings = setfield(motorSettings,'runningCurrent',30);
% holding current 0-50% of 3 Amps
motorSettings = setfield(motorSettings,'holdingCurrent',0);
%step resolution : 1(Fullstep),2,4,6,8,32,64,128,256
motorSettings = setfield(motorSettings,'stepResolution',1);
%%top velocity range 0 -2^31
motorSettings = setfield(motorSettings,'topVelocity',305175);
%Acceleration : 0-65000
motorSettings = setfield(motorSettings,'acceleration',1000);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


settingsString = @(defsetting) sprintf('/1s0F1m%dh%dj%dV%dL%do%dJ%dR',...
    defsetting.runningCurrent,...
    defsetting.holdingCurrent,...
    defsetting.stepResolution,...
    defsetting.topVelocity,...
    defsetting.acceleration,1500,0);

if strcmp(motor.Status,'closed')
    fopen(motor);
end
out = query(motor,settingsString(motorSettings));
fclose(motor)

%%
