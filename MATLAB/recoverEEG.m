  function [zf1, zf2, recoveredEEG ]= recoverEEG (eegArr, zi1, zi2)
            b1=[0, 0.85, 0, 0.85];
            a1=[1, 0, 0.7];
            [y1, zf1]=filter(b1,a1,eegArr,zi1);
            
            b2=[0.8,0.8];
            a2=[1, 0.6];
            [y2, zf2]=filter(b2,a2,y1,zi2);
            
            recoveredEEG = y2;
        end