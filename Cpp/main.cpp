#include <iostream>
#include "ftd2xx.h"
#include <windows.h>


using namespace std;

int main()
{
    FT_STATUS ftStatus;
    FT_HANDLE ftHandle;
    long int comPort;
    byte* t_data = new byte[1000000];
    unsigned long int allBytesRead = 0;

    ftStatus = FT_Open(0, &ftHandle);
    cout << "FT_Open status: " << ftStatus << endl;

    ftStatus = FT_GetComPortNumber(ftHandle, &comPort);
    cout << "Device is connected to COM" << comPort << endl;

    //FT_DEVICE_LIST_INFO_NODE* ftdiDevList = new FT_DEVICE_LIST_INFO_NODE[numDevs];

    ftStatus = FT_SetDivisor(ftHandle,3);
    cout << ftStatus << endl;
    ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0x11, 0x13);
    cout << ftStatus << endl;
    ftStatus = FT_SetDataCharacteristics(ftHandle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE);
    cout << ftStatus << endl;
    //ftStatus = FT_SetLatencyTimer(ftHandle, 4);
    cout << ftStatus << endl;

    DWORD EventDWord;
    DWORD TxBytes;
    DWORD RxBytes;

    long unsigned int bytesRead = 0;

    byte* herePointer = t_data;

    for (int i=0; i<3; i++) {
        Sleep(100);

        FT_GetStatus(ftHandle,&RxBytes,&TxBytes,&EventDWord);
        ftStatus = FT_Read(ftHandle, herePointer, RxBytes, &bytesRead);
        FT_Purge(ftHandle, FT_PURGE_RX | FT_PURGE_TX);
        herePointer += bytesRead;
        allBytesRead += bytesRead;

        cout << endl << RxBytes << ", " << TxBytes << ", " << EventDWord << endl;
    }


    for (int j=0; j<allBytesRead; j++) {
            cout << +(uint8_t)(t_data[j]) << " ";
            if (t_data[j]==255) cout << endl;

    }
    /*
    long unsigned int bytesRead = 0;
    byte* t_data = new byte[10000];
    ftStatus = FT_Read(ftHandle, t_data, 10000, &bytesRead);

    for (int i=0; i<10000; i++) {
            cout << +(uint8_t)(t_data[i]) << " ";
            if (t_data[i]==255) cout << endl;

    }
    cout << endl << bytesRead << endl;
    */
    ftStatus = FT_Close(ftHandle);
    cout << ftStatus;
    return 0;
}
