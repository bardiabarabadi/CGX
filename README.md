# CGX on MATLAB
MATLAB guide for using CGX with FTDI dongle:

## Requirements
- CGX Dev-Kit
- CGX USB Dongle
- Windows Machine
- MATLAB
- Parallel Computing Toolbox for MATLAB

## Instructions

### Installing the FTDI Driver

The first step is to make sure that the FTDI driver is installed on your device. To make sure
that's the case, connect the dongle to your computer. Right-click on the start menu icon, and select Device Manager option.

Look to see if you can find "USB Serial Port (COMx)" (x can be any number), under "Ports (COM & LPT)". Try removing the dongle
and checking again to make sure (it should disappear when disconnected). If you can't find your device in this menu, try installing FTDI Direct Drivers from ref [3]

### MATLAB Usage

Connect the dongle to the computer and make sure the light turns blue when the CGX dev-kit is turned on. 
To use the MATLAB Class, "CGX", you need to have "Parallel Computing Toolbox" installed on your version of MATLAB.

All you need to do in order to use the cCGX class is the following:

- Create an object off of cCGX class, send the refresh rate as an input (in seconds):
    
    `    refreshRate=0.3;    device=cCGX(refreshRate);`
- Call resetBuff function to clear and initialize the buffer. Note that it needs to get assigned to itself for this function:

    `device=device.refreshBuff()`
- Set the Impedance Check (on the CGX device) Enable or disable using the following commands:

    `
    device.disableImpedanceCheck()
    device.enableImpadanceCheck()  % Not verified yet`
    
- Now you can use the following line to pull in the EEG samples.

    `[device EEG_samples lossRate] = device.pullEEG()`

- Terminate the connection using the following command:

    `device.kill()`

Notes:
1. Everytime you call pullEEG, you'll get all of the samples that was taken since the last call to pullEEG. It is possible to clear the buffer by calling `device=device.resetBuff()`.
2. The lossRate represents the fraction of lost packets on the Bluetooth channel. Ideally should be close to zero.
3. You are free to pull the EEG samples from the device object as often as you want. Although it is better to wait at least for `refreshRate` seconds to avoid getting empty arrays for `EEG_samples`
4. If you wish to have the impedance correction applied to the sampled EEG, use pullEEG function like this: `[device EEG_samples lossRate] = device.pullEEG(1)`. Note that the EEG recovery algorithm is not verified yet. It is possible to alter the algorithm by modifying `recoverEEG.m` function.

  
To see an example, open and run **example.m** to see EEG samples in real-time (in Volts). To get more detail on how this works, read the README.md file in the **docs** directory.


## Refrences
1. [CGX Wiki](http://cognionics.com/wiki/pmwiki.php/Main/CognionicsRawDataSpec#Bluetooth.2FFTDI_Serial_Port_Interface)
2. [FTDI Programmer's Guide](https://ftdichip.com/wp-content/uploads/2020/08/D2XX_Programmers_GuideFT_000071.pdf)
3. [FTDI d2xx drivers](https://ftdichip.com/drivers/d2xx-drivers/)
