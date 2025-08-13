#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
    const char *text = "Hello, World!\n";
    char color_code[2]; // format escape sequence

    for (int color = 0; color <= 15; color++) {
        color_code[0] = '\x1B'; // escape character
        color_code[1] = color;

        write(1, color_code, 2); // ustawienie koloru
        write(1, text, strlen(text)); // wyświetlenie tekstu
    }

    // resetowanie koloru
    char reset_code[2] = { '\x1B', 0x07 };
    write(1, reset_code, 2);
    
    exit();
}

