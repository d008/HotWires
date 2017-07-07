function [pos,pos2] = locate(motor)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
flushinput(motor)
pos = query(motor,'/1?8','%s\n','%s\n');
pos = str2num(pos(regexp(pos,'\d')))/2000;
pos2 = query(motor,'/1?0','%s\n','%s\n');
pos2 = str2num(pos2(regexp(pos2,'\d')))/800;

step = query(motor,'/1?6','%s\n','%s\n');
step = str2num(step(regexp(step,'\d')));

pos2=pos2/step;

flushinput(motor)
fclose(motor);
end