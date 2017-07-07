
zeroEncoder(motor)
N = 5;

dist  =50;
interval = 5;
in  = zeros(dist./interval,N);
out = zeros(dist./interval,N);
step = 256;
speed =2000*step;
for i = 1:N
    move(0.246, motor,speed,step);
    for j = 1:dist/interval
        [in(j,i),trav] = move(interval,motor,speed,step);
        trav
        
    end
    move(-0.246, motor,speed,step);
    for j = 1:dist/interval
        [out(j,i),trav] = move(-interval,motor,speed,step);
        trav
        
    end
    
end

