function [ freq, limits, points, files, Transducer] = finput_DAQ1_MKF( folder )
%[ freq, limits, points ] = finput( fname )
%Reads in format file and outputs acquisition info
%   
   
    %Find Voltage limits (and # channels)
    TXTfiles = fullfile(folder, '*DAQ*.txt');
    All_TXT_files_struct = dir(TXTfiles);
    filename = strcat(folder,All_TXT_files_struct(1).name);
    fid = fopen(filename,'r');
    Z = textscan(fid ,'%s','Delimiter',{' ','\t'}); 
    
%     dum = strfind(Z{1},'Date:');               % Find Date
%     rows = find(~cellfun('isempty', dum));    % Skip space
%     Date = str2double(char(Z{1}{rows+1}));        % Read in Date
    
    dum = strfind(Z{1},'TRUE');              % Find instance of TRUE to find # channels
    rows = find(~cellfun('isempty', dum)); % Where do limits start
    limits(1,:) = str2num(char(Z{1}{rows+2})); % Use index to find voltages
    limits(2,:) = -limits(1,:);                % used for negative value of limit (always +/- 5V for example)
    clear dum rows %rows2
    
    %Read in sample rates 
    dum = strfind(Z{1},'Sample_Rate[Hz]:');
    rows = find(~cellfun('isempty', dum));
    freq = str2double(char(Z{1}{rows+1}));
    clear dum rows
    
    %Read in Diaphragm type 
    dum = strfind(Z{1},'Transducer:');
    rows = find(~cellfun('isempty', dum));
    Transducer = str2double(char(Z{1}{rows+1}));
    clear dum rows
    
    %Read in data points
    dum = strfind(Z{1},'Desired_Location[µm]:');
    rows = find(~cellfun('isempty', dum));
    points(:,1) = str2num(char(Z{1}{rows+1:2:end}));
    points(:,2) = str2num(char(Z{1}{rows+2:2:end})); 
%     points(:,3) = str2num(char(Z{1}{rows+3:3:end}));
    
    %Generate file names:
    %nmpts = (size(dum,1)-rows)/3;
    nmpts = length(points);
    fname = strsplit(All_TXT_files_struct(1).name,'_');
    fname = fname{1};
    for ii = 1:nmpts
       files(ii,:) = {[fname ...
          '_Index' sprintf('%0.0f',points(ii,1)) ...
          '_YLocation' sprintf('%0.2f',points(ii,2)) 'Superpipe.bin']};
           %'_R' sprintf('%0.1f',points(ii,3)) '.bin']};
    end


        
end


