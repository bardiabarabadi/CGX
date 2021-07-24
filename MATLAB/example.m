clear
close all
clc

dongle=CGX();
dongle=dongle.findDongle("COM7");

flush(dongle.serialPort);
% p1=dongle.getSinglePacket();
% 
% p2=dongle.getSinglePacket();
 
flush(dongle.serialPort);
tic
q=read(dongle.serialPort, 200, "uint8");
toc



