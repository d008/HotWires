%%

ymin = 0.07;
ymax = 60;
N = 40;
reps = 4;

viewProgress = 1;
% % cd(uigetdir)
% % mkdir(pwd,'Data')
% % cd('Data')
% % filename = 'testing'
%
% % daqCondTime = 10;
% % daqSampleTime = 90;
% % daqSampleFreq = 300000;
%
% % s = daq.createSession('ni')
% % addAnalogInputChannel(s,'Dev4',['ai3'],'Voltage');
% % s.Rate = daqSampleFreq;
% % s.IsContinuous = false;
% % s.DurationInSeconds = daqCondTime;
%%
ySet = logspace(log10(ymin),log10(ymax),N);
yTarget = meshgrid(ySet, ones(1,reps))';
yActual = yTarget*0;
pos = locate(motor);
step = 256;
speed =1600*step;
for j = 1:reps
    move(-0.246, motor,speed,step);
    pos = locate(motor);
     (ymin - pos)
    move((-pos+ymin), motor,speed,step);
    pos = locate(motor);
    move((-pos+ymin), motor,speed,step);
    pos = locate(motor);
    move(0.246, motor,speed,step);
    pos = locate(motor);
    yActual(1,j) = pos;
    disp(sprintf('Difference of %0.4f mm',pos-yTarget(1,j)))
    
    %         %addAnalogInputChannel(s,'Dev4',['ai0','ai2'],'Voltage');
    %         %s.DurationInSeconds = daqCondTime;
    %         %[data_cond,timeStamps_cond,triggerTime_cond] = startForeground(s);
    %
    %         %removeChannel(s,3);
    %         %removeChannel(s,2);
    %         % s.DurationInSeconds = daqSampleTime;
    %         %[data_hw,timeStamps_hw,triggerTime_hw] = startForeground(s);
    %y = pos;
    y_set = yTarget(1,j);
    %y=yTarget(i,j)
    
    if viewProgress
        clf
        semilogy(yTarget,'bs-')
        hold on
        semilogy(yActual,'ro-')
        hold off
        drawnow
    end
    for i = 2:N
        %         %clc
        %         if (yTarget(i,j)) <1
        %             uStep = 8;
        %             speed = 1600;
        %         elseif (yTarget(i,j)) < 4
        %             uStep = 4;
        %         else
        %             speed = 800;
        %             uStep = 2;
        %             speed = 800;
        %         end
        disp(sprintf('Currently at %0.4f mm',pos))
        
        
        disp(sprintf('Round %d - %d/%d: Moving to %0.4f mm',j,i,N,yTarget(i,j)))
        move((yTarget(i,j) - pos), motor,speed,step);
        pause(0.1)
        pos = locate(motor);
        yActual(i,j) = pos;
        disp(sprintf('Difference of %0.4f mm',pos-yTarget(i,j)))
        
        %         %addAnalogInputChannel(s,'Dev4',['ai0','ai2'],'Voltage');
        %         %s.DurationInSeconds = daqCondTime;
        %         %[data_cond,timeStamps_cond,triggerTime_cond] = startForeground(s);
        %
        %         %removeChannel(s,3);
        %         %removeChannel(s,2);
        %         % s.DurationInSeconds = daqSampleTime;
        %         %[data_hw,timeStamps_hw,triggerTime_hw] = startForeground(s);
        %y = pos;
        y_set = yTarget(i,j);
        %y=yTarget(i,j)
        
        if viewProgress
            clf
            semilogy(yTarget,'bs-')
            hold on
            semilogy(yActual,'ro-')
            hold off
            drawnow
        end
        
        % %         cl = clock;
        % %         name  = strcat(filename,num2str(j),'_',date,'_',num2str(cl(4)),num2str(cl(5)),...
        % %             '_y=',sprintf('%0.0d',round(y*1000)))
        % %
        % %         save(name,'data_cond','timeStamps_cond','y','y_set','data_hw','timeStamps_hw')
        % %
        % %         fid = fopen(strcat(name,'.bin'),'wb')
        % %         fwrite(fid,[data_hw,timeStamps_hw],'single')
        % %         fclose(fid);
        %         %fread(fid,[daqSampleTime*daqSampleFreq],'single');
        
    end
    
end
