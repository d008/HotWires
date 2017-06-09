function [ loc,trav ] = move(distance,motor,speed,stepResolution)
%move(motor,direction,distance,~params) moves the motor object in a direction(+1,-1) away/toward the wall a set
%distance (in MILLIMETERS!!!!)

pos = locate(motor);
if distance > 0
    direction = 1;
    direc = 'P';
elseif distance < 0
    direction = -1;
    direc = 'D';
else
    disp('Invalid Direction')
    trav = 0;
    loc = pos;
    return
end
distance = abs(distance);
steps = floor(stepResolution*800*distance); %800 steps per rotation and 1 thread/mm;
temp = sprintf('/1V%dj%d%c%dR',speed,stepResolution,direc,steps);
%disp(temp)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
fprintf(motor,temp);
loc = locate(motor);
pause(0.001)
while loc ~= locate(motor)
    loc = locate(motor);
    trav = (loc-pos)/2000;
    %fprintf('%0.4 mm \n',trav)
    disp(loc/2000)
end
STOP(motor);
loc = locate(motor);
trav = (loc-pos)/2000;

end
