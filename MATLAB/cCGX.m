classdef cCGX
    %CCGX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        port
        tcpClient
        rawBuff
        currentPointer
        maxBuffLen
        refreshRate
        process
        z1
        z2
    end
    
    methods
        function obj = cCGX(refreshRate)
            obj=obj.startExe();
            obj.port = 25565;
            obj.tcpClient = tcpclient("localhost", obj.port);
            obj.resetBuff();
            obj.z1=[];
            obj.z2=[];
            write (obj.tcpClient, (refreshRate));
        end
        
        function obj=startExe(obj)
            obj.process = System.Diagnostics.Process();
            obj.process.StartInfo.FileName = 'Cpp.exe';
            obj.process.StartInfo.UseShellExecute = true;
            obj.process.StartInfo.RedirectStandardInput = false;
            obj.process.StartInfo.CreateNoWindow = true;
            obj.process.Start('Cpp.exe');
        end
        
        function kill(obj)
            obj.process.Kill();
        end
        
        
        function obj = refresh(obj)
            % This functions moves data from C to MATLAB
            newSamples = read(obj.tcpClient);
            if obj.currentPointer + size(newSamples, 2) < obj.maxBuffLen
                obj.rawBuff(obj.currentPointer:obj.currentPointer+size(newSamples, 2)-1) = newSamples;
                obj.currentPointer=obj.currentPointer+size(newSamples, 2);
            else
                disp ("overflow occured, something is wrong. Use resetBuff() to start over.");
            end
        end
        
        function sendValue(obj, toSend)
            toSendByte = uint8(toSend);
            write(obj.tcpClient, toSendByte);
        end
        
        function enableImpedanceCheck(obj)
            obj.sendValue(17);
        end
        
        function disableImpedanceCheck(obj)
            obj.sendValue(18);
        end
        
      
        
        function obj = resetBuff(obj)
            obj.maxBuffLen=10000000;
            obj.rawBuff=zeros([1,obj.maxBuffLen], 'uint8');
            obj.currentPointer = 1;
        end
        
        function [obj, eegArray, lossRate] = pullEEG(obj, doRecover) % This function returns EEG samples and cleares the buff
            if nargin < 2
                doRecover = 0;
            end
            
            [obj, sampleArray, lossRate] = obj.refreshGetSampleArray;
            obj=obj.resetBuff();
            if ~isempty(sampleArray)
                eegArray_tmp = sampleArray(:,1:8)*3.88051e-10;
                if doRecover ~= 0
                    [obj.z1, obj.z2, eegArray] = recoverEEG(eegArray_tmp,obj.z1, obj.z2);
                else
                    eegArray = eegArray_tmp;
                end
            else
                eegArray=[];
            end
        end
        
        function [obj, sampleArray, lossRate] = refreshGetSampleArray(obj)
            obj=obj.refresh();
            [sampleArray, lossRate] = obj.getSampleArray();
        end
        
        function [sampleArray, lossRate] = getSampleArray(obj)
            [packetArray, lossRate] = obj.getPacketArray();
            packetCell=num2cell(packetArray,2);
            sampleCell=cellfun(@decodeCgxPacket, packetCell, 'UniformOutput', false);
            sampleArray=cell2mat(sampleCell);
        end
        
        function [obj, packetArray, lossRate] = refreshGetPacketArray(obj)
            obj=obj.refresh();
            [packetArray, lossRate] = obj.getPacketArray();
        end
        function [packetArray, lossRate] = getPacketArray(obj)
            
            rawPacketsStr = obj.readRawPacketsStr();
            rawPacketsStrSplitted=split(rawPacketsStr, char(255));
            rawPacketStrCleaned=...
                rawPacketsStrSplitted(strlength(rawPacketsStrSplitted)==38);
            lossRate = (size(rawPacketsStrSplitted,1)-...
                size(rawPacketStrCleaned,1))/size(rawPacketsStrSplitted,1);
            packetArray=uint8(char(rawPacketStrCleaned));
            
        end
        
        function [rawPackets] = readRawPackets(obj)
            % This function reads all the packets from the TCP and returns
            % them as is. 
            rawPackets = obj.rawBuff(1:obj.currentPointer);
        end
        
        function [rawPacketsStr] = readRawPacketsStr(obj)
            % This function reads all the packets from the TCP and returns
            % them as is. 
            rawPackets = obj.rawBuff(1:obj.currentPointer);
            rawPacketsStr = string(char(rawPackets));
        end
        
        function [obj, rawPackets] = readRawPacketsAndClear(obj)
            % This function reads all the packets from the TCP and returns
            % them as is. 
            rawPackets = obj.readRawPackets();
            obj=obj.resetBuff();
        end
        
        function [obj, battery] = getBattery(obj)
            battery=0;
            obj=obj.refresh();
            if obj.currentPointer == 1
                disp ('Failed to read packets');
                return
            end
            [obj, rawPackets] = obj.readRawPacketsAndClear();
            
            lastSyncByteLocation = find(rawPackets==255,1,'last');
            lastBattByteLocation = lastSyncByteLocation - 3;
            battery = 100*double(rawPackets(lastBattByteLocation))...
                      /128.0;
            
        end
        
    end
end

