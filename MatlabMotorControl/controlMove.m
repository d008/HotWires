function [ loc,trav ] = controlMove(distance,motor,speed,stepResolution)
%Three move check
    loc = locate(motor);
if -distance > loc/2000;
    trav = 0;
    return
end
if strcmp(motor.Status,'closed')
    fopen(motor);
end
[loc, trav] = move(distance*0.95,motor,speed,stepResolution);
trav
dist = (distance-trav)


[loc, trav1] = move(dist*0.95,motor,speed,stepResolution);

trav = trav + trav1
dist = (distance-trav)

speed = 3000;
stepResolution = 256;
[loc, trav1] = move(dist,motor,speed,stepResolution);

trav = trav + trav1 
clc
fclose(motor);
end

