function [pos] = STOP(motor)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
flushinput(motor)
pos = query(motor,'/1TR','%s\n','%s\n');
end