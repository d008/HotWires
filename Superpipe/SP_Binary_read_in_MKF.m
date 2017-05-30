%%%% Superpipe Binary Data Read In %%%%

 close all
 clc
 clear all
%clearvars -except Before After

%% Select data folder

%Start_Path = fullfile('C:\Users\Water Channel\Desktop\Superpipe Labview\Data Folder\');
%Start_Path = uigetdir
% Ask user to confirm or change.

Folder = uigetdir(pwd,'Select the data directory');
if Folder == 0
    return;
end

% Append slash to folder name
% Append slash to folder name
if ismac | isunix
    slash = '/';  % use '\' on windows
else ispc
    slash = '\';  % use '\' on windows
end
Folder = strcat(Folder,slash);
clear slash Start_Path

TXTfiles = fullfile(Folder, '*Actual*.txt');
All_TXT_files_struct = dir(TXTfiles);
filename = strcat(Folder,All_TXT_files_struct(1).name);
delimiter = '\t';
startRow = 5;

formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);
fclose(fileID);

% Create output variable
Actual_Positions = [dataArray{1:end-1}];
% % Clear temporary variables
% clearvars filename delimiter startRow formatSpec fileID dataArray ans;
%
% %% Load in Zeros Before for DAQ:
%
%     [ zfreq, zlimits, zpoints, zfiles] = SP_Zero_finput_DAQ1( Folder, zfident_Before );
%         diffr = max(zlimits)-min(zlimits);
%         minlim = min(zlimits);
%
%     %Loop through all binary files%
%     for ii = 1:numel(zfiles)
%
%         fid = fopen([Folder char(zfiles(ii))],'r','b');
%
%         volts_DAQ1 = fread(fid,[length(diffr),inf],'ubit16')';  % used to read in voltages from bin.files.
%
%         fclose(fid);
%
%         for j=1:length(zlimits)
%             volts_DAQ1(:,j)=volts_DAQ1(:,j)/2^16*diffr(j)+minlim(j);      % Conversion from binary to decimal
%             zeros_Before(ii,j)=mean(volts_DAQ1(:,j));
%         end
%
%         zerovolts_Before = volts_DAQ1;
%         clear volts_DAQ1
%     end
%
%     clear diffr limits minlim fid zpoints ii j ans %zlimits
%
% %% Load in Zeros After for DAQ:
%
%     [ zfreq, zlimits, zpoints, zfiles] = SP_Zero_finput_DAQ1( Folder, zfident_After );
%         diffr = max(zlimits)-min(zlimits);
%         minlim = min(zlimits);
%
%     %Loop through all binary files%
%     for ii = 1:numel(zfiles)
%
%         fid = fopen([Folder char(zfiles(ii))],'r','b');
%
%         volts_DAQ1 = fread(fid,[length(diffr),inf],'ubit16')';  % used to read in voltages from bin.files.
%
%         fclose(fid);
%
%         for j=1:length(zlimits)
%             volts_DAQ1(:,j)=volts_DAQ1(:,j)/2^16*diffr(j)+minlim(j);      % Conversion from binary to decimal
%             zeros_After(ii,j)=mean(volts_DAQ1(:,j));
%         end
%
%         zerovolts_After = volts_DAQ1;
%         clear volts_DAQ1
%     end
%
%     clear diffr limits minlim fid zpoints ii j ans %zlimits
%
% %% Average Zeros
%
% Zeros = (zeros_After + zeros_Before )./2;
%
load('calibration.mat');
%% Load Data for DAQ:

[ freq, limits, points, files, Transducer] = SP_finput_DAQ1_MKF (Folder);

diffr = max(limits)-min(limits);
minlim = min(limits);
% Loop through all binary files%
tic
for ii = 1:numel(files)
    fid = fopen([Folder char(files(ii))],'r','b');
    
    
    volts_DAQ1 = fread(fid,[length(diffr),inf],'ubit16')'; %Load binary data
    fclose(fid);
    
    for j=1:length(limits)
        volts_DAQ1(:,j)=volts_DAQ1(:,j)/2^16*diffr(j)+minlim(j);
        Meanvalues_DAQ(ii,j) = mean(volts_DAQ1(:,j)); %Find mean at each point
        stdev_DAQ(ii,j) = std(volts_DAQ1(:,j));      %Find standard dev. at each point
    end
    
    TempK(ii) = (mean(volts_DAQ1(:,1)).*100)+273.15;
    hwV = volts_DAQ1(:,2);
    meanHW(ii) = mean(f(P,hwV,TempK(ii)));
    varHW(ii) = var(f(P,hwV,TempK(ii)));
    
fprintf('File %d/%d : %0.2f/%0.2f sec \n',ii,numel(files),toc,toc*numel(files)/ii)

end
clear volts ans fid ii j diffr minlim points

%% Calibration for DAQ:
%Columns are channels, i.e. AI0 = Column 1

%%%% AI 0 - Tunnel Temperature in [Kelvin] %%%%
% ! without subtracting the zero
% Data(:,1) = (Meanvalues_DAQ(1:end,1).*100)+273.15;
% % Standard Deviation
% StD_DAQ(:,1) = ( (stdev_DAQ(:,1)).*100)+273.15;


% %%%% AI 1 - Scanivalve Taps Static Pressure in [Pa] %%%%
%     % 10 V / 10 Torr - Conversion in Pa
%
%     Data(:,2) = (Meanvalues_DAQ(:,2)-Zeros(1,2)) .* 133.322;
%     % Standard Deviation
%     StD_DAQ(:,2) = ( (stdev_DAQ(:,2)).*(4000/10)).*6894.75729 ;
%

% %%%% AI 2 - Tunnel Static Pressure in [Pa] %%%%
% % ! without subtracting the zero (static pressure was already applied when taking zero)
%     Data(:,3) = (Meanvalues_DAQ(:,3).*(4000/10)).*6894.75729;
%
%     StD_DAQ(:,3) = ( (stdev_DAQ(:,3)).*(4000/10)).*6894.75729 ;

%%%% AI 3 - Hotwire %%%%

%Data(:,4) =


%%%% Pitot Probe Pressure Transducers in [Pa]%%%%
% AI 4 (Column 5 in matrix) - 0.2 psi transducer
% AI 5 (Col 6) - 1   psi transducer
% AI 6 (Col 7) - 5   psi transducer
%Transducer = 5;
% if Transducer == 0.2
%     Col = 5;         %
% elseif Transducer == 1
%     Col = 6;
% elseif Transducer == 5
%     Col = 7;
% end
%
%     Data(:,5) = ((Meanvalues_DAQ(:,Col)-Zeros(1,Col)).*Transducer./5)*6894.75729;
%     % Standard Deviation
%     StD_DAQ(:,5) = ( (stdev_DAQ(:,Col)).*Transducer./5)*6894.75729;
%
% %clear Col
% %%%% AI 7  - Limit Switch Detect %%%%
%
% % open
% TD(:,1) = ((Meanvalues_DAQ(:,6)-Zeros(1,6)).*1.25./5)*6894.75729;
% TD(:,2) = ((Meanvalues_DAQ(:,7)-Zeros(1,7)).*5./5)*6894.75729;
% TD(:,3) = ( (stdev_DAQ(:,6)).*1.25./5)*6894.75729;
% TD(:,4) = ( (stdev_DAQ(:,6)).*5./5)*6894.75729;
%% Tunnel static pressure in atm to crosscheck
%
% Tunnel_static_atm = Data(:,3).*9.86923267E-6;
% Tunnel_static_psi = Data(:,3).* 0.000145038;



%clear zfident_Before zfident_After TXTfiles Folder files All_TXT_files_struct limits stdev_DAQ Test_Name ...
%   zfreq zlimits zfiles

%% Test


