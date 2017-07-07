function [ loc,trav ] = move(distance,motor,speed,stepResolution)
%move(motor,direction,distance,~params) moves the motor object in a direction(+1,-1) away/toward the wall a set
%distance (in MILLIMETERS!!!!)

flip  = 0;
pos = locate(motor);
if strcmp(motor.Status,'closed')
    fopen(motor);
end
% disp('located motor')
if distance > 0
    direction = 1;
    direc = 'P';
elseif distance < 0
    direction = -1;
    if flip  == 1
        query(motor,'/1F0R','%s\n','%s\n');
        direc = 'P';
    else
        direc = 'D';
    end
    
    %     stepResolution = 256;
    %     speed = 40000;
else
    disp('Invalid Direction')
    trav = 0;
    loc = pos;
    return
end
distance = abs(distance);
% disp('dist check')
steps = floor(stepResolution*800*distance/10)*10; %800 steps per rotation and 1 thread/mm;
if steps==0
    disp('bail')
    trav = 0;
    loc = pos;
    return;
end
temp = sprintf('/1V%dj%d%c%dR',speed,stepResolution,direc,steps);
% disp('temp ok')
disp(temp);

disp(query(motor,temp,'%s\n','%s\n'))
flushinput(motor)
%pause(3)
loc = locate(motor);
% disp('pause')

while loc ~= locate(motor)
    loc = locate(motor);
    trav = (loc-pos);
    %fprintf('%0.4 mm \n',trav)
    %disp(loc/2000);
end
trav = (loc-pos);
STOP(motor);
% disp('stopped motor')
[loc,loc2] = locate(motor);
disp([loc,loc2])
trav = (loc-pos);


if direction == -1 & flip == 1
    query(motor,'/1F1R','%s\n','%s\n');
end
fclose(motor);
% disp('close motor')
end
