classdef CGX
    
    properties
        comPort
        baudRate
        serialPort
    end
    
    methods
        function obj = CGX()
            %CGX Construct an instance of this class
            %   Detailed explanation goes here
            obj.baudRate= 3000000;
        end
        
        function singlePacket = getSinglePacket(obj)
            singlePacket=0;
            lastByte = read(obj.serialPort, 1, "uint8");
            while (lastByte ~= 255)
                lastByte = read(obj.serialPort, 1, "uint8");
                singlePacket= lastByte;
            end
            
            
            lastByte=0;
            while (lastByte ~= 255)
                lastByte = read(obj.serialPort, 1, "uint8");
                singlePacket=[singlePacket, lastByte];
            end
            
            
            
        end
        
        
        function obj = findDongle(obj,comPort)
            if nargin == 2
                obj.comPort = comPort;
                disp(['com port provided ' comPort]);
            else
                disp(['No COM port provided, please disconnect your dongle' ...
                      ' and press Enter']);
                keypressed = getkey;
                while keypressed ~= 13   % 13 is the enter key
                    keypressed = getkey;
                end
                serialPorts=serialportlist;
                disp('Now connect your dongle and press Enter again');
                
                keypressed = getkey;
                while keypressed ~= 13   % 13 is the enter key
                    keypressed = getkey;
                end
                newSerialPort=serialportlist;
                
                for i=1:size(newSerialPort,2)
                    isIn=contains(serialPorts, newSerialPort(i));
                    if sum(isIn,'all') == 0
                        obj.comPort = newSerialPort(i);
                    end
                end
                disp (['Your dongle is connected to ' obj.comPort]);
            end
            obj.serialPort = serialport(obj.comPort, obj.baudRate);
            
        end
    end
end

