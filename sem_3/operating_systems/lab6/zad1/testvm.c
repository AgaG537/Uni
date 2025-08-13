#include "types.h"
#include "stat.h"
#include "user.h"

int main(void) {
  printf(1, "Allocating 5 pages of memory using sbrk() ...\n");

  for (int i = 0; i < 5; i++) {
    if (sbrk(4096) == (void*)-1) {
      printf(1, "Memory allocation failed at iteration %d\n", i);
      exit();
    }
  }

  printf(1, "Memory allocation completed successfully\n");
  exit();
}
