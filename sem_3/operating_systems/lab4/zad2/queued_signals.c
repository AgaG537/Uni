#include <stdio.h>
#include <signal.h>
#include <unistd.h>

int signal_count = 0;

void handle_signal(int sig) {
    signal_count++;
    printf("Signal %d received. Count: %d\n", sig, signal_count);
}

int main() {
    signal(SIGUSR1, handle_signal);

    printf("Sending SIGUSR1 signals to PID: %d...\n", getpid());

    for (int i = 0; i < 5; i++) {
        kill(getpid(), SIGUSR1);
    }

    sleep(1);

    printf("Total SIGUSR1 signals handled: %d\n", signal_count);

    return 0;
}
