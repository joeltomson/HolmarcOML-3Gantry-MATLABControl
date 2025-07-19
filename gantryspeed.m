function gantryspeed(s,speed,acc,dec)

%% Inputs
% s = Serial Object; 
% speed = Speed to be set in mm/sec; 
% Acc = boolean for Accelaration;
% Dec = boolean for Deceleration;

%% NOTE

% Gantry needs to be connected as a serial port object with the baud rate
% of 19200

% Safe range for speed -> 0.01875mm/sec - 16mm/sec

% Max value for Acceleration and Deceleration have been hard coded into
% this version. Manually change these values based on requirement as they
% cannot be converted from metric units to code consistently. Each
% acceleration curve is broken down into a staircase form where the number
% of steps, height of each step can be assigned. Hence depending on the
% final movement speed, each acceleration curve will be different.

% Thank you for your effort and time.

%% Main Code
speed=speed/0.00125;


speed_hex=dec2hex(speed,4);
speed_bytes(1)= hex2dec(speed_hex(1:2));
speed_bytes(2)= hex2dec(speed_hex(3:4));

writebyte(34,s,10);
writebyte(speed_bytes(1),s,10);
writebyte(speed_bytes(2),s,10);

if(acc==0 && dec==0)
    writebyte(0,s,10);
    writebyte(0,s,10);
    writebyte(0,s,10);
    writebyte(0,s,10);
    writebyte(0,s,10);
    writebyte(0,s,10);
else
    % SPD - Recommended to keep this at max value of 43
    writebyte(0,s,10);
    writebyte(43,s,10);
    % INCR - Amount of increase in each step. Max value = 40
    writebyte(0,s,10);
    writebyte(40,s,10);
    % STPS - Number of steps. Max value = 10
    writebyte(0,s,10);
    writebyte(10,s,10);
end
end


function writebyte(value,s,feedback) 
write(s,value,"uint8");
acknowledge(s,feedback);
end


function acknowledge(s,feedback)
ack=int8(0);
while(ack~=feedback)
    ack=read(s,1,"uint8");
    if isempty(ack)
        ack=0;
    end
    terminateflag = any(ack == [40,41,42,43,44,45],"all");
    if terminateflag
        writebyte(104,s,105);
        fprintf("Action Terminated: Limits Reached\n");
        return;
    end
end
end