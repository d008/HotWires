function findWall(s,motor)
    zeroEncoder(motor,100000);
isTouching = median(s.startForeground());

if strcmp(motor.Status,'closed')
    fopen(motor);
end
temp = sprintf('/1V%dj%d%c%dR',4000,256,'D',floor(256*800*0.5e-3));
while isTouching  < 3;
    fprintf(motor,temp);
    flushinput(motor);
    isTouching =  median(s.startForeground());
end
disp('WALL FOUND')
STOP(motor)
disp('Encoder zeroed')
zeroEncoder(motor);

end

