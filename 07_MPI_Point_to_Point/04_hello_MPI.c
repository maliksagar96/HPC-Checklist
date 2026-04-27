#include <stdio.h>
#include <mpi.h>

int main() {

    MPI_init(NULL, NULL);
    printf("Hello MPI.\n");
    MPI_Finalize();

    return 0;
}