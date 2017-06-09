function [pos] = STOP(motor)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
pos = query(motor,'/1TR');
end