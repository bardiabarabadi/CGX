#include <iostream>
#include "ftd2xx.h"
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

// Need to link with Ws2_32.lib
#pragma comment (lib, "Ws2_32.lib")
// #pragma comment (lib, "Mswsock.lib")


#define DEFAULT_BUFLEN 512
#define DEFAULT_PORT 25565

using namespace std;

int main()
{
    bool exit = false;

    FT_STATUS ftStatus;
    FT_HANDLE ftHandle;
    long int comPort;
    byte* t_data = new byte[10000000];
    byte* commandBuff = new byte[1000];
    int recievedCommands = 0;
    int capturedBytes = 0;
    DWORD sentCommands = 0;
    unsigned long int allBytesRead = 0;

    WSADATA wsa;
    SOCKET s , new_socket;
    struct sockaddr_in server , client;
    int c;
    char message [100];

    printf("\nInitialising Winsock...");
    if (WSAStartup(MAKEWORD(2,2),&wsa) != 0)
    {
        printf("Failed. Error Code : %d",WSAGetLastError());
        return 1;
    }

    printf("Initialised.\n");

    //Create a socket
    if((s = socket(AF_INET , SOCK_STREAM , 0 )) == INVALID_SOCKET)
    {
        printf("Could not create socket : %d" , WSAGetLastError());
    }

    printf("Socket created.\n");

    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( DEFAULT_PORT );

    //Bind
    if( bind(s ,(struct sockaddr *)&server , sizeof(server)) == SOCKET_ERROR)
    {
        printf("Bind failed with error code : %d" , WSAGetLastError());
    }

    puts("Bind done");

    //Listen to incoming connections
    listen(s , 3);

    //Accept and incoming connection
    puts("Waiting for incoming connections...");

    c = sizeof(struct sockaddr_in);
    new_socket = accept(s , (struct sockaddr *)&client, &c);
    if (new_socket == INVALID_SOCKET)
    {
        printf("accept failed with error code : %d" , WSAGetLastError());
    }
    u_long mode = 1;  // 1 to enable non-blocking socket
    ioctlsocket(new_socket, FIONBIO, &mode);

    puts("Connection accepted");


    //FT_DEVICE_LIST_INFO_NODE* ftdiDevList = new FT_DEVICE_LIST_INFO_NODE[numDevs];
    while (true){

        ftStatus = FT_Open(0, &ftHandle);
        cout << "Status: " << ftStatus << endl;
        if (ftStatus == FT_OK)
            break;
        else{
            cout << "Failed to connect to dongle, trying again...";
            usleep(1000000);
        }
    }

    ftStatus = FT_GetComPortNumber(ftHandle, &comPort);
    cout << "Device is connected to COM" << comPort << endl;
    ftStatus = FT_SetDivisor(ftHandle,3);
    cout << "Setting Divisor, Status: " << ftStatus << endl;
    ftStatus = FT_SetFlowControl(ftHandle, FT_FLOW_RTS_CTS, 0x11, 0x13);
    cout << "Setting FlowControl, Status: " << ftStatus << endl;
    ftStatus = FT_SetDataCharacteristics(ftHandle, FT_BITS_8, FT_STOP_BITS_1, FT_PARITY_NONE);
    cout << "Setting Characterestics, Status: " << ftStatus << endl;

    DWORD EventDWord;
    DWORD TxBytes;
    DWORD RxBytes;

    long unsigned int bytesRead = 0;

    byte* herePointer = t_data;
    exit=false;
    cout << "Streaming raw data on TCP channel, \'localhost\', port: " << DEFAULT_PORT << endl;
    cout << "Press Esc to terminate..." << endl;

    double refrate = 0;

    while (refrate == 0){
        capturedBytes = recv(new_socket, (char*)&refrate, sizeof(double), 0);
        cout << capturedBytes << ", " << refrate << endl;
        usleep(10000);
    }
    while (exit==false) {

        if (GetAsyncKeyState(VK_ESCAPE))
        {
            exit = true;
        }
        usleep(refrate*1000000);

        FT_GetStatus(ftHandle,&RxBytes,&TxBytes,&EventDWord);
        ftStatus = FT_Read(ftHandle, herePointer, RxBytes, &bytesRead);
        FT_Purge(ftHandle, FT_PURGE_RX | FT_PURGE_TX);

        send(new_socket , (char*) herePointer , bytesRead , 0);
        //cout << endl << RxBytes << ", " << TxBytes << ", " << EventDWord << endl;
        byte* herePointer = t_data; // Clear buffer
        allBytesRead += bytesRead;
        recievedCommands = recv(new_socket,(char*) commandBuff, sizeof(commandBuff), 0);
        if (recievedCommands > 0){
            FT_Write(ftHandle, (char*)commandBuff, recievedCommands, &sentCommands);
            cout << "Sending " << (char)commandBuff[0] << " to the device";
            if (sentCommands != recievedCommands){
                cout << "Could/'nt send all commads. stopping the program...";
                break;
            }
            recievedCommands = 0;
        }
    }

    cout << "Press any key to close the socket and end the program..." << endl;
    getchar();

    closesocket(s);
    WSACleanup();
    ftStatus = FT_Close(ftHandle);
    cout << ftStatus;
    return 0;
}


