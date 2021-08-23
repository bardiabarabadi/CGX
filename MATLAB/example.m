clear
clc
close all
figure 

dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break','Callback', 'delete(gcbf)');


refreshRate = 0.3; % refresh rate, in seconds

device=cCGX(refreshRate);

display_arr = zeros ([8,1000]);

A = zeros([6,1]);
prv_A = 0;

Channels = display_arr;

p_1 = subplot(2,4,1);
p_2 = subplot(2,4,2);
p_3 = subplot(2,4,3);
p_4 = subplot(2,4,4);
p_5 = subplot(2,4,5);
p_6 = subplot(2,4,6);
p_7 = subplot(2,4,7);
p_8 = subplot(2,4,8);
hold (p_1, 'on')
hold (p_2, 'on')
hold (p_3, 'on')
hold (p_4, 'on')
hold (p_5, 'on')
hold (p_6, 'on')
hold (p_7, 'on')
hold (p_8, 'on')
pl_1 = plot(p_1, Channels(1,:));
pl_2 = plot(p_2, Channels(2,:));
pl_3 = plot(p_3, Channels(3,:));
pl_4 = plot(p_4, Channels(4,:));
pl_5 = plot(p_5, Channels(5,:));
pl_6 = plot(p_6, Channels(6,:));
pl_7 = plot(p_7, Channels(7,:));
pl_8 = plot(p_8, Channels(8,:));

D = parallel.pool.DataQueue;
D.afterEach(@(display_arr) updateSurface(pl_1, pl_2, pl_3, pl_4, pl_5, pl_6, pl_7, pl_8, display_arr));
device=device.resetBuff();

while (ishandle(dialogBox))
    
    pause(refreshRate)
    [device, A, l] = device.pullEEG(0);
    newSamplesCount = size(A, 1);
    display_arr(:,1:end-newSamplesCount) = display_arr(:,1+newSamplesCount:end);
    display_arr(:,end+1-newSamplesCount:end) = A';
    %disp(l);
    send(D, display_arr);
end
device.kill();


