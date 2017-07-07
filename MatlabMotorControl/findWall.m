    %zeroEncoder(motor,100000);

d = daq.getDevices;
s = daq.createSession('ni')
addAnalogInputChannel(s,'Dev4','ai7','Voltage');
s.Rate = 25000;
s.IsContinuous = false;
s.DurationInSeconds = 0.01;


if strcmp(motor.Status,'closed')
    fopen(motor);
end
[p1,p2]= locate(motor)
move(-p2+0.1,motor,400*256,256)
[p1,p2]= locate(motor)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
temp = sprintf('/1V%dj%d%c%dR',500,256,'D',0);
fprintf(motor,temp)
isTouching =s.inputSingleScan;
tic
while isTouching  < 3;
    isTouching = min(s.startForeground())
end
toc
disp('WALL FOUND')
STOP(motor)
disp('Encoder zeroed')

pause(5)

zeroEncoder(motor);
% fopen(motor)
% temp = sprintf('/1V%dj%d%c%dR',400,4,'P',4);
% 
% while isTouching  > 1;
%     fprintf(motor,temp)
%     flushinput(motor);
%     isTouching = median(s.startForeground())
%     %locate(motor);
% end

zeroEncoder(motor);
clearvars -except motor
