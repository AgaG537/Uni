// #include <stdio.h>
// #include <signal.h>
// #include <string.h>
// #include <sys/types.h>

// int main() {
//     pid_t pid = 1;
//     int sig = SIGKILL;
//     int result = kill(pid,sig);

//     if (result == -1) {
//         printf("Failed to send SIGKILL to PID 1\n");
//     } else {
//         printf("SIGKILL sent to PID 1 successfully (unexpected).\n");
//     }

//     return 0;
// }


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>

int main() {
    printf("Sending SIGKILL to init...\n");
    int result = kill(1, SIGKILL);
    if (result == 0)
    {
        printf("Signal sent succesfully\n");
    } else {
        printf("Signal failed to be sent: ");
        switch (errno) {
            case (EINVAL):
                printf("invalid signal\n");
                exit(EXIT_FAILURE);
                break;
            case (EPERM):
                printf("insufficent permissions\n");
                exit(EXIT_FAILURE);
                break;
            default:
                printf("pid 1 doesn't exist");
                exit(EXIT_FAILURE);
                break;
        }
    }
    result = kill(1, 0);
    if(result == 0)
        printf("Init still alive :)\n");
    else
        printf("Init killed :(\n");
    
    return 0;
}