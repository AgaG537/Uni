#include "types.h"
#include "user.h"

int main(int argc, char *argv[]) {
    if (argc != 4) {
        printf(2, "Usage: expr <num1> <operator> <num2>\n");
        exit();
    }

    int num1 = atoi(argv[1]);
    int num2 = atoi(argv[3]);
    char op = argv[2][0];
    int result = 0;

    switch (op) {
        case '+':
            result = num1 + num2;
            break;
        case '-':
            result = num1 - num2;
            break;
        case '*':
            result = num1 * num2;
            break;
        case '/':
            if (num2 == 0) {
                printf(2, "Error: Division by zero\n");
                exit();
            }
            result = num1 / num2;
            break;
        default:
            printf(2, "Error: Unsupported operator %c\n", op);
            exit();
    }

    printf(1, "%d\n", result);
    exit();
}
