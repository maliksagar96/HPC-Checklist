#include <stdio.h>
#include <string.h> 
#include <mpi.h> 

int main(int argc, int *argv[]) {

    const char* str = "I am process 0 and I am the king.";
    char buffer[strlen(str)+1]; 
    int rank;
    //Status contains the information source, tag and message size. 
    MPI_Status status;

    MPI_init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if(rank == 0) {
        strcpy(buffer, str);
        //Both send and receive have buffer, message length to send and receive, datatype, Sending to which rank, tag = 42(here), and the communicator.
        MPI_Send(buffer, strlen(str)+1, MPI_CHAR, 1, 42, MPI_COMM_WORLD);
    }

    else if(rank == 1) {
        //receive buffer, lenght of data to be received, data type, rank from which it is coming from, tag, default communicator and status. 
        MPI_Recv(buffer, strlen(str) + 1, MPI_CHAR, 0, 42, MPI_COMM_WORLD, MPI_STATUS_IGNORED);
        //Here the buffer is immedaitely printed below the recieve because it is safe to use now. 
        //The function MPI_recv will return only when the recieved buffer is full.
        printf("The message recieved was = %s\n", buffer);
    }

}