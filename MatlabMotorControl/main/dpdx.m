function [ ] = dpdx(varargin)
if nargin<1;
    taps = 3:21;
else
    taps = varargin{1};
end
D = 0.1298448;  %Pipe diameter in meters
dx = 25*D/19;   %Spacing between the taps in meters
rate =10000;
dur = 10;
P = taps*0;P_std= P;TempK = P;Static_Pa = P;

DAQSetup
homeScani(daqCal,ScaniHome);

ichan =  {Temperature,TunnelStatic,Scanivalve};
%Add input channels
for i = 1:length(ichan)
    ch = addAnalogInputChannel(daqCal,'Dev4',ichan{i}.Channel,'Voltage');% Motor Controller Voltage
    ch.Name = ichan{i}.Name;
    ch.Range = ichan{i}.Range;
end

skipScani(daqCal,ScaniSkip,0)
moves = diff([1,taps]);
for i = 1:length(moves)
    skipScani(daqCal,ScaniSkip,moves(i))
    pause(2)
    daqCal.Rate = rate;    % Data acquisition frequency
    daqCal.DurationInSeconds = dur;     % Data sample time
    [data,time] = daqCal.startForeground();
    figure(1)
    plot(time,data)
    xlabel('Time(s)')
    ylabel('V')
    legend({'Temp','Static','Scani'})
    TempK(i) = Temperature.cal(mean(data(:,1)));
    Static_Pa(i) = TunnelStatic.cal(mean(data(:,2)));
    P(i) = Scanivalve.cal(mean(data(:,3)));
    P_std(i) = std(Scanivalve.cal(data(:,3)));
    figure(2)
    plot(taps(1:i),P(1:i),'bo-')
    xlabel('Tap#')
    ylabel('Scanivalve Pressure (Pa)')
    drawnow
end
homeScani(daqCal,ScaniHome);
DPDX1 = mean(diff(P)./(diff(taps.*dx)))
DPDX2 = fit(taps'.*dx,P','poly1');
DPDX2 = DPDX2.p1

if(mean(Static_Pa)<100000)
[Rho, mu] = ZSI(mean(TempK),101325);
else
[Rho, mu] = ZSI(mean(TempK),mean(Static_Pa));
end
utau = sqrt((-DPDX2./Rho)*(D./4))
eta = mu./Rho./utau;

dpdx.P = P; dpdx.P_std = P_std;dpdx.Static_Pa = Static_Pa;
dpdx.TempK = TempK;dpdx.taps = taps;dpdx.dx = dx;
dpdx.DPDX1 = DPDX1;dpdx.DPDX2 = DPDX2;
dpdx.Rho  = Rho;dpdx.mu = mu;dpdx.eta = eta;dpdx.utau= utau;

save('dpdx.mat','dpdx','utau','eta')

end

function homeScani(daqCal,ScaniHome)
ch = addDigitalChannel(daqCal,'Dev4',ScaniHome.DChannel,'OutputOnly');
outputSingleScan(daqCal,1);
pause(2)
outputSingleScan(daqCal,0);
pause(2)
daqCal.removeChannel(length(daqCal.Channels))
end

function skipScani(daqCal,ScaniSkip,i)
ch = addDigitalChannel(daqCal,'Dev4',ScaniSkip.DChannel,'OutputOnly');
if i > 0
    for p = 1:i
        outputSingleScan(daqCal,1);
        pause(0.5)
        outputSingleScan(daqCal,0);
        pause(0.5)
    end
end
daqCal.removeChannel(length(daqCal.Channels))
end
