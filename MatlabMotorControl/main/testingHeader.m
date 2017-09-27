%% Testing Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.numPos =   40;        % Number of y points
data.ymin =     1.772;      % Closest point to the wall (mm)
data.ymax =     67;          % Furthest point to the wall (mm)
data.ySet =     logspace(log10(data.ymin),log10(data.ymax),data.numPos);    %Y - Location set points
data.D =        0.12936;
data.pitot =    6.33;      % Pitot center distance to the wall (mm)
data.cline =    (data.D*1000-data.ymin-data.pitot)/2;

disp('Are the following testing parameters correct [Press Enter]?')
reply = input(sprintf('y_offset: %0.3f mm\ny_max: %0.3f mm\nPitot dist: %0.3f mm\nCenterline: %0.3f mm\n',...
    data.ymin,data.ymax,data.pitot,data.cline));

%Pre-allocated memory
data.yActual = data.ySet*0;meanU = data.ySet*0;varU = data.ySet*0;
data.TempK = [data.yActual,0];data.Static_Pa = data.TempK;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%data.Gain =     64;          %Gain on the Dantec
%data.Offset =   -0.602;    %Voltage

data.R0_1=        108.7;
data.Rext_1 =     138.2;
data.Gain_1 =     32;          %Gain on the Dantec
data.Offset_1 =   -0.743;    %Voltage

data.R0_2=        106.7;
data.Rext_2 =     138.2;
data.Gain_2 =     32;          %Gain on the Dantec
data.Offset_2 =   -0.745;    %Voltage

data.l =     	60e-3;  %mm length of wire

data.alpha =    2e-3;

data.Thot_1 = (data.Rext_1/data.R0_1-1)./data.alpha;
data.Thot_2 = (data.Rext_2/data.R0_2-1)./data.alpha;

disp('Are the following testing parameters correct [Press Enter]?')
reply = input(sprintf('Gain 1: %i\nOffset 1: %0.3f V\nGain 2: %i\nOffset 2: %0.3f V\nR_0_1: %0.2f ohms\nRext_1: %0.2f ohms\nR_0_2: %0.2f ohms\nRext_2: %0.2f ohms\n',...
    data.Gain_1,data.Offset_1,data.Gain_2,data.Offset_2,data.R0_1,data.Rext_1,data.R0_2,data.Rext_2));


%% Sampling Parameters
data.rate =     300000;    % Data acquisition frequency
data.dur =      30;        % Data sample time sec
data.Vset =     6;       % Voltage Set point
rampSpeed =     .1;        % V/sec
Vmax =          7.2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calSet.sampleDuration = 30;     % Data sample time
calSet.Vs = [linspace(0,2,10),linspace(2,Vmax,9)];%linspace(0,Vmax,numPoints);
%calSet.Vs = linspace(0,Vmax,18);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%