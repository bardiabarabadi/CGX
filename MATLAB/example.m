clear
close all
clc

dongle=CGX();
dongle=dongle.findDongle("COM7");



flush(dongle.serialPort);
tic
q=read(dongle.serialPort, 1000, "uint8");
toc

flush(dongle.serialPort);
pause(4);
tic
q=read(dongle.serialPort, 1000, "uint8");
toc



