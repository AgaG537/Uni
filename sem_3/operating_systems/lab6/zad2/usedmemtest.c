#include "types.h"
#include "stat.h"
#include "user.h"

int main() {
  int used_virtual = usedvp();
  int used_physical = usedpp();

  printf(1, "Liczba uzytych stron wirtualnych: %d\n", used_virtual);
  printf(1, "Liczba uzytych stron fizycznych: %d\n", used_physical);

  // Przydziel pamięć, aby sprawdzić, czy liczniki się zmieniają
  sbrk(4096);
  used_virtual = usedvp();
  used_physical = usedpp();

  printf(1, "Po przydzieleniu jednej strony:\n");
  printf(1, "Liczba uzytych stron wirtualnych: %d\n", used_virtual);
  printf(1, "Liczba uzytych stron fizycznych: %d\n", used_physical);

  exit();
}
