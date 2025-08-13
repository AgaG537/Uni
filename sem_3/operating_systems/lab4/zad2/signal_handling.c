#include <stdio.h>
#include <signal.h>
#include <unistd.h>

void handle_signal(int sig) {
    printf("Received signal: %d\n", sig);
}

int main() {
    for (int i = 1; i <= 64; i++) {
        signal(i, handle_signal);
        if (signal(i, handle_signal) == SIG_ERR) {
            printf("Cannot set handler for signal %d\n", i);
        }
    }

    printf("Waiting for signals. PID: %d\n", getpid());

    while (1) {
        pause();
    }

    return 0;
}
