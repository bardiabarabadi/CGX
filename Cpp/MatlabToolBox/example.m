clear
clc
close all
figure 

dialogBox = uicontrol('Style', 'PushButton', 'String', 'Break','Callback', 'delete(gcbf)');


process = System.Diagnostics.Process();
process.StartInfo.FileName = 'Cpp.exe';
process.StartInfo.UseShellExecute = true;
process.StartInfo.RedirectStandardInput = false;
process.StartInfo.CreateNoWindow = true;
process.Start();
processisrunning = ~process.HasExited;

device=cCGX();

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
    
    [device, A, l] = device.pullEEG();
    newSamplesCount = size(A, 1);
    display_arr(:,1:end-newSamplesCount) = display_arr(:,1+newSamplesCount:end);
    display_arr(:,end+1-newSamplesCount:end) = A';
        
    send(D, display_arr);
        
        
        
        
    pause(0.03)
  

end
process.Kill();
disp ('Done')


