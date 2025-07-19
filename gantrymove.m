function gantrymove(s,X,Y,Z,Acc,Dec) 

%% inputs: 
% s = Serial Object; 
% X = X distance in mm (Sign indicates direction); 
% Y = Y distance in mm (Sign indicates direction); 
% Z = Z distance in mm (Sign indicates direction); 

% Acc = boolean for Accelaration; 
% Dec = boolean for Deceleration;

%% NOTE

% Gantry needs to be connected as a serial port object with the baud rate
% of 19200

% Gantry limits from home position
% X -> 0 - 638.5mm
% Y -> 0 - 641.5mm
% Z -> 0 - 133.2mm

% If boolean is set to 1 for acc or dec, they will use the values set using
% the gantryspeed function or the app. The same applies for the speed of
% movement. 

% Please use the gantryspeed function or the Micromotion app for this.

% In its current state(As of the date of this upload) the gantryspeed 
% function is incomplete and does not contain the code for non zero values 
% of acceleration and requires updating. If you do write the code for the 
% same please update that file and this note as well. 

% Thank you for your time and effort.

%% declaring variables
uint8 xdirectionflag ;
uint8 ydirectionflag ;
uint8 zdirectionflag;
uint8 accflag ;
uint8 decflag;
uint32 x ;
uint32 y ;
uint32 z ;

x_byte = uint8(zeros(3));
y_byte = uint8(zeros(3));
z_byte = uint8(zeros(3));

remaining_byte = int8(zeros(3,3));

X = X/0.00125;
Y = Y/0.00125;
Z = Z/0.00125;

%% Movement for X

% Detect direction
if X>0
    xdirectionflag=125;
else
    xdirectionflag=175;
end

% Convert decimal to 6-digit hex
x = dec2hex(abs(X), 6);

% Separate hex into 3 parts of 2 bytes and convert hex parts back to decimal
x_byte(1) = hex2dec(x(1:2));
x_byte(2) = hex2dec(x(3:4));
x_byte(3) = hex2dec(x(5:6));


%% Movement for Y

% Detect direction
if Y>0
    ydirectionflag=125;
else
    ydirectionflag=175;
end

% Convert decimal to 6-digit hex
y = dec2hex(abs(Y), 6);

% Separate hex into 3 parts of 2 bytes and convert hex parts back to decimal
y_byte(1) = hex2dec(y(1:2));
y_byte(2) = hex2dec(y(3:4));
y_byte(3) = hex2dec(y(5:6));


%% Movement for Z

% Detect direction
if Z>0
    zdirectionflag=125;
else
    zdirectionflag=175;
end

% Convert decimal to 6-digit hex
z = dec2hex(abs(Z), 6);

% Convert hex parts back to decimal
z_byte(1) = hex2dec(z(1:2));
z_byte(2) = hex2dec(z(3:4));
z_byte(3) = hex2dec(z(5:6));

if(Acc==1)
    accflag=20;
else
    accflag=0;
end

if(Dec==1)
    decflag=30;
else
    decflag=0;
end

%% Gantry Communication

%initiate communication
writebyte(19,s,10);

%X movement commands
writebyte(x_byte(1,1),s,10);
writebyte(x_byte(2,1),s,10);
writebyte(x_byte(3,1),s,10);
writebyte(xdirectionflag,s,10);

%Y movement commands
writebyte(y_byte(1,1),s,10);
writebyte(y_byte(2,1),s,10);
writebyte(y_byte(3,1),s,10);
writebyte(ydirectionflag,s,10);

%Z movement commands
writebyte(z_byte(1,1),s,10);
writebyte(z_byte(2,1),s,10);
writebyte(z_byte(3,1),s,10);
writebyte(zdirectionflag,s,10);

%Accelaration
writebyte(accflag,s,10);
%Deceleration
writebyte(decflag,s,10);

% Wait for feedback
acknowledge(s,170);

% Initiate feedback
writebyte(163,s,164)

% X feedback
remaining_byte(1,3)=readbyte(10,s);
remaining_byte(1,2)=readbyte(10,s);
remaining_byte(1,1)=readbyte(10,s);

% Y feedback
remaining_byte(2,3)=readbyte(10,s);
remaining_byte(2,2)=readbyte(10,s);
remaining_byte(2,1)=readbyte(10,s);

% Z feedback
remaining_byte(3,3)=readbyte(10,s);
remaining_byte(3,2)=readbyte(10,s);
remaining_byte(3,1)=readbyte(10,s);

completeflag = any(remaining_byte,"all");


if completeflag == 0
    fprintf("Movement Completed\n");
else
    fprintf("Movement Incomplete\n");
end

end

function writebyte(value,s,feedback) 
write(s,value,"uint8");
acknowledge(s,feedback);
end

function feedback = readbyte(value,s)
write(s,value,"uint8");
feedback=read(s,1,"uint8");
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