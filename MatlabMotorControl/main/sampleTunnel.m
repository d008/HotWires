%clear
DAQXSetup
%clc
pitot1_zero =  -0.00541;
pitot02_zero = 0.02163;
pitot5_zero = 0.02331;

%transducer = Pitot1;
pitot_zero = pitot5_zero;
% Select Proper Transducer
transducer1 = Pitot5;
%Open valve to pitot transducer
ch = addDigitalChannel(daqCal,transducer1.Ddev,transducer1.DChannel,'OutputOnly');% Motor Controller Voltage
outputSingleScan(daqCal,1);
daqCal.removeChannel(length(daqCal.Channels))

% transducer2 = Pitot02;
% %Open valve to pitot transducer
% ch = addDigitalChannel(daqCal,transducer2.Ddev,transducer2.DChannel,'OutputOnly');% Motor Controller Voltage
% outputSingleScan(daqCal,1);
% daqCal.removeChannel(length(daqCal.Channels))
% pause(1)


%Input channels
ichan =  {Temperature,TunnelStatic,transducer1,hw1,hw2};
%Add input channels
for i = 1:length(ichan)
    ch = addAnalogInputChannel(daqCal,ichan{i}.dev,ichan{i}.Channel,'Voltage');% Motor Controller Voltage
    ch.Name = ichan{i}.Name;
    ch.Range = ichan{i}.Range;
end
daqCal.Rate = 10000;
daqCal.DurationInSeconds =1;

[captured_data,time] = daqCal.startForeground();
data = struct('TempK',Temperature.cal(mean(captured_data(:,1))),...
    'Static_Pa',TunnelStatic.cal(mean(captured_data(:,2))),...
    'Pitot_Pa',transducer1.cal(mean(captured_data(:,3)))- transducer1.cal(pitot_zero),...
    'V1',mean(captured_data(:,4)),...
    'V1_std',std(captured_data(:,4)),...
    'V2',mean(captured_data(:,5)),...
    'V2_std',std(captured_data(:,5)));

if(mean(data.Static_Pa)<100000)
    [Rho, mu] = ZSI(mean(data.TempK),101325);
else
    [Rho, mu] = ZSI(mean(data.TempK),mean(data.Static_Pa)+101325);
end
data.rho = Rho;
data.Mu = mu;
data.U = sqrt(2/data.rho*(data.Pitot_Pa ));

daqCal.removeChannel(1:length(daqCal.Channels))


%%
fprintf('Temp (K): %0.2f \nStatic (psi): %0.2f \nPitot (Pa): %0.2f \nU (m/s): %0.2f\nV1: %0.2f\nV2: %0.2f\n',...
    data.TempK,data.Static_Pa/6894.75729,data.Pitot_Pa,data.U,data.V1,data.V2);
fprintf('Rho (kg/m^3): %0.2f\nMu (Pa s): %d \n',data.rho,data.Mu)
fprintf('Pitot (V): %0.5f\n',mean(captured_data(:,3)))
% fprintf('Pitot1 (V): %0.5f\n',mean(captured_data(:,6)))
% fprintf('U1 (V): %0.5f\n',sqrt(2/data.rho*(transducer2.cal(mean(captured_data(:,6))) - transducer2.cal(pitot1_zero))))


fprintf('Re_D = %i\n', 0.12936*data.U./1.17.*data.rho./data.Mu);
ch = addDigitalChannel(daqCal,transducer1.Ddev,transducer1.DChannel,'OutputOnly');% Motor Controller Voltage
%Close valve to pitot transducer
outputSingleScan(daqCal,0);
% daqCal.removeChannel(1:length(daqCal.Channels))
% ch = addDigitalChannel(daqCal,transducer2.Ddev,transducer.DChannel,'OutputOnly');% Motor Controller Voltage
% %Close valve to pitot transducer
% outputSingleScan(daqCal,0);
daqCal.removeChannel(1:length(daqCal.Channels))

