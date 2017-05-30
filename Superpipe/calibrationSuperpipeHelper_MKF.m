%% Load Precal Data for DAQ:
tic
for i = 1:length(All_TXT_files_struct)
    fid = fopen([Folder2 All_TXT_files_struct(i).name],'r');
    Z = textscan(fid ,'%s','Delimiter',{' ','\t'});
    
    dum = strfind(Z{1},'TRUE');              % Find instance of TRUE to find # channels
    rows = find(~cellfun('isempty', dum)); % Where do limits start
    limits(1,:) = str2num(char(Z{1}{rows+2})); % Use index to find voltages
    limits(2,:) = -limits(1,:);                % used for negative value of limit (always +/- 5V for example)
    clear dum rows %rows2
    
    %Read in Diaphragm type
    dum = strfind(Z{1},'Transducer:');
    rows = find(~cellfun('isempty', dum));
    Transducer = str2double(char(Z{1}{rows+1}));
    clear dum rows
    
    diffr = max(limits)-min(limits);
    minlim = min(limits);
    % Loop through all binary files%
    
    % for ii = 1:numel(files)
    binfile = All_TXT_files_struct(i).name;
    binfile = [binfile(1:end-4) '.bin'];
    fclose(fid);
    fid = fopen([Folder2 binfile],'r','b');
    
    
    volts_DAQ1 = fread(fid,[length(diffr),inf],'ubit16')'; %Load binary data
    fclose(fid);
    
    for j=1:length(limits)
        volts_DAQ1(:,j)=volts_DAQ1(:,j)/2^16*diffr(j)+minlim(j);
        Meanvalues_DAQ(i,j) = mean(volts_DAQ1(:,j)); %Find mean at each point
        stdev_DAQ(i,j) = std(volts_DAQ1(:,j));      %Find standard dev. at each point
    end
    fprintf('File %d/%d - %0.2f sec\n',i,length(All_TXT_files_struct),toc )
end
clear volts ans fid ii j diffr minlim points