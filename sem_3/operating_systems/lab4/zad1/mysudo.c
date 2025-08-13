#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    setuid(0);
    execl("/bin/bash", "bash", NULL);
    return 0;
}
