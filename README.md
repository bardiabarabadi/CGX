# CGX
MATLAB guide for using CGX with FTDI dongle:

There is no way to utilize CGX's FTDI dongle by only using the MATLAB functions. 
Trying to acquire packets from VCO (Virtual COM Port) leaves you with a ton of lost
bytes, let alone lost packets! The intended way to use the dongle is to download and 
install FTDI's driver for the USB port, and use the functions provided shared library in C, C# or C++
to connect, configure and communicate with the FTDI chip on the dongle. 

## Refrences
1. [CGX Wiki](http://cognionics.com/wiki/pmwiki.php/Main/CognionicsRawDataSpec#Bluetooth.2FFTDI_Serial_Port_Interface)
2. [FTDI Programmer's Guide](https://ftdichip.com/wp-content/uploads/2020/08/D2XX_Programmers_GuideFT_000071.pdf)
3. [FTDI d2xx drivers](https://ftdichip.com/drivers/d2xx-drivers/)
4. [MATLAB Shared library argument parsing](https://www.mathworks.com/help/matlab/matlab_external/passing-arguments-to-shared-library-functions.html)

## Steps
1. FTDI Driver
2. MATLAB shared library
3. Configure FT serial port
4. Connect to CGX
5. Decode CGX packets
### Driver

Installing the FTDI driver has two steps. First is using the windows executable 
setup provided in ref [3]. This step is just like installing any other driver. 

The second and more important step for using the driver is to download the shared
library associated with the driver. You can find this library under X86 and X64 columns 
in the same webpage. Extract the contents of those files and put them in a folder called
**libs** in the same directory as your MATLAB script. Make sure you choose the right architecture
and extract the compressed file properly so that the **.h** file exists in **libs** folder.

### MATLAB Shared Library Access
To access and use the shared libraries in MATLAB, you need to load the functions using
**loadlibrary()** method. If the operation is successful, you should be able to see a 
list of the functions in the FTDI library by running the following command:
    
    loadlibrary('ftd2xx') % Loads the library
    libfunctions('ftd2xx') % Prints the available functions

To call the functions in the library, you need to use **callib()** method. Note that 
you have to use the correct input and output variable types (pointers, int, double, ...)
to get a successful execution, see ref [4] for more information on that. Below is
and example:

    FT_OK=0 % Taken from ref[2]
    FT_DEVICE_NOT_OPENED=3  
    deviceHandle=lib.pointer

    success=calllib('ftd2xx','FT_Open',0,a)
    if success==FT_OK
        disp('Connection successful')   
    else if success==FT_DEVICE_NOT_OPENED
        disp('Connection failed')
    end

### Configure FT Serial Port

As note in "Bluetooth/FTDI Serial Port Interface" section of ref [1], the serial
port operates at 3,000,000 baud, 8-N-1, with flow control enabled. This configuration 
is not achievable without employing the FT driver library functions.

    
    