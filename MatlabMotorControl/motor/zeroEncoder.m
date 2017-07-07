function [ loc ] = zeroEncoder(motor,varargin)
if strcmp(motor.Status,'closed')
    fopen(motor);
end
if nargin>1;
    num = varargin{1}*2000;
else 
    num = 0;
end
pos = query(motor,sprintf('/1z%dR',num));
flushinput(motor);
loc = locate(motor);
fclose(motor);
end

