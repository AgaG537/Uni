#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  printf(1, "wynik syscalla hello:\n");
  hello();
  printf(1, "wynik syscalla getppid: %d\n", getppid());
  exit();
}
