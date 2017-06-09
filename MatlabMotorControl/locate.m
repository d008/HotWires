function [pos] = locate(motor)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
pos = query(motor,'/1?8');
pos = str2num(pos(regexp(pos,'\d')));
%fclose(motor);
end