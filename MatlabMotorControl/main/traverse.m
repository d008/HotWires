classdef traverse
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        speed = 2000*256;
        ustep = 256;
        motorSettings;
        motor;
    end
    
    methods
        %Builder: Connects the motor and sets default settings
        function obj = traverse()
            %function motorSetup()
            warning('off')
            % Connect to motor
            %motor = instrfind('Type', 'serial', 'Port', 'COM5', 'Tag', '')
            obj.motor = instrfind('Type', 'visa-serial', 'RsrcName', 'ASRL5::INSTR', 'Tag', '');
            if isempty(obj.motor)
                obj.motor = visa('NI', 'ASRL5::INSTR');
            else
                fclose(obj.motor);
                obj.motor = obj.motor(1);
            end
            set(obj.motor, 'Terminator', {'CR','CR'});
            set(obj.motor, 'Timeout', 0.01);
            fopen(obj.motor);
            flushinput(obj.motor);
            obj.ustep = 256;
            obj.speed = 2000*obj.ustep;
            
            %% Default Settings
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Default motor settings
            obj.motorSettings = struct();
            %running current 0-100% of 3 Amps
            obj.motorSettings = setfield(obj.motorSettings,'runningCurrent',30);
            % holding current 0-50% of 3 Amps
            obj.motorSettings = setfield(obj.motorSettings,'holdingCurrent',0);
            %step resolution : 1(Fullstep),2,4,6,8,32,64,128,256
            obj.motorSettings = setfield(obj.motorSettings,'stepResolution',1);
            %%top velocity range 0 -2^31
            obj.motorSettings = setfield(obj.motorSettings,'topVelocity',305175);
            %Acceleration : 0-65000
            obj.motorSettings = setfield(obj.motorSettings,'acceleration',1000);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            settingsString = @(defsetting) sprintf('/1s0F0m%dh%dj%dV%dL%do%dJ%dR',...
                defsetting.runningCurrent,...
                defsetting.holdingCurrent,...
                defsetting.stepResolution,...
                defsetting.topVelocity,...
                defsetting.acceleration,1500,0);
            
            if strcmp(obj.motor.Status,'closed')
                fopen(motor);
            end
            query(obj.motor,settingsString(obj.motorSettings));
            fclose(obj.motor);
        end
        
        %Zero the encoder
        function loc  = zeroEncoder(obj,varargin)
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            if nargin>1
                num = varargin{1}*obj.ustep*800;
            else
                num = 0;
            end
            pos = query(obj.motor,sprintf('/1z%dR',num));
            flushinput(obj.motor);
            loc = obj.locate();
            fclose(obj.motor);
        end
        
        function [pos,pos2] = locate(obj)
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            flushinput(obj.motor)
            pos = query(obj.motor,'/1?8','%s\n','%s\n');
            pos = str2double(pos(regexp(pos,'\d')))/2000;
            pos2 = query(obj.motor,'/1?0','%s\n','%s\n');
            pos2 = str2double(pos2(regexp(pos2,'\d')))/800;
            steps = query(obj.motor,'/1?6','%s\n','%s\n');
            steps = str2double(steps(regexp(steps,'\d')));
            pos2=pos2/steps;
            flushinput(obj.motor)
            fclose(obj.motor);
        end
        
        function [ loc,trav ] = move(obj,distance)
            %move(motor,direction,distance,~params) moves the motor object in a direction(+1,-1) away/toward the wall a set
            %distance (in MILLIMETERS!!!!)
            pos = obj.locate();
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            % disp('located motor')
            if distance > 0
                direction = 1;
                direc = 'P';
            elseif distance < 0
                direction = -1;
                direc = 'D';
            else
                disp('Invalid Direction')
                trav = 0;
                loc = pos;
                return
            end
            distance = abs(distance);
            % disp('dist check')
            steps = floor(obj.ustep*800*distance/10)*10; %800 steps per rotation and 1 thread/mm;
            if steps==0
                disp('bail')
                trav = 0;
                loc = pos;
                return;
            end
            temp = sprintf('/1V%dj%d%c%dR',obj.speed,obj.ustep,direc,steps);
            % disp('temp ok')
            disp(temp);
            
            disp(query(obj.motor,temp,'%s\n','%s\n'))
            flushinput(obj.motor)
            %pause(3)
            loc = obj.locate();
            % disp('pause')
            
            while loc ~= obj.locate()
                loc = obj.locate();
                trav = (loc-pos);
                %fprintf('%0.4 mm \n',trav)
                %disp(loc/2000);
            end
            trav = (loc-pos);
            obj.STOP();
            % disp('stopped motor')
            [loc,loc2] = obj.locate();
            disp([loc,loc2])
            trav = (loc-pos);
            fclose(obj.motor);
            % disp('close motor')
        end
        
        function [pos] = STOP(obj)
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            flushinput(obj.motor)
            pos = query(obj.motor,'/1TR','%s\n','%s\n');
        end
        
        %zeroEncoder(motor,100000);
        function findWall(obj)
            
            daqCal = daq.createSession('ni')
            ch = addAnalogInputChannel(daqCal,'Dev4','ai7','Voltage');
            ch.Name = 'LimitSwitch';
            daqCal.Rate = 25000;
            daqCal.IsContinuous = false;
            daqCal.DurationInSeconds = 0.001;
            
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            [p1,p2]= obj.locate()
            if p2 > 0.5
                obj.move(-p2+0.1)
            end
            [p1,p2]= obj.locate()
            if strcmp(obj.motor.Status,'closed')
                fopen(obj.motor);
            end
            temp = sprintf('/1V%dj%d%c%dR',500,256,'D',0);
            fprintf(obj.motor,temp)
            isTouching =daqCal.inputSingleScan;
            tic
            while isTouching  < 0.2;
                data = daqCal.startForeground();
                isTouching = min(data)
                mean(data)
            end
            toc
            disp('WALL FOUND')
            obj.STOP()
            disp('Encoder zeroed')
            pause(5)
            obj.zeroEncoder();
            
            
        end
    end
    
end
