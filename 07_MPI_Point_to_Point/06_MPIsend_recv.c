//SendRecv is a very useful tool to send and receive in the same line. 
// The user should be a bit careful about the tag. 

#include <stdio.h>
#include <string.h> 
#include <mpi.h> 

int main(int argc, char *argv[]) {

  const char* str0 = "I am process 0 and I am the king.";
  const char* str1 = "I am process 1 and I obey the king.";

  char send_buffer[100];
  char recv_buffer[100];

  int rank;
  MPI_Status status;

  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  if(rank == 0) {
    strcpy(send_buffer, str0);
  
    MPI_Sendrecv(send_buffer, strlen(send_buffer)+1, MPI_CHAR, 1, 42,
                 recv_buffer, 100, MPI_CHAR, 1, 43,
                 MPI_COMM_WORLD, &status);

    printf("Process 0 received: %s\n", recv_buffer);
  }

  else if(rank == 1) {
    strcpy(send_buffer, str1);

    MPI_Sendrecv(send_buffer, strlen(send_buffer)+1, MPI_CHAR, 0, 43,
                 recv_buffer, 100, MPI_CHAR, 0, 42,
                 MPI_COMM_WORLD, &status);

    printf("Process 1 received: %s\n", recv_buffer);
  }

  MPI_Finalize();
  return 0;
}