%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define STACK_SIZE 100

long long stack[STACK_SIZE];
int stack_ptr = 0;

int error_flag = 0;

void push(long long val);
long long pop();
void check_stack(int required_args, const char *op_name);
void evaluate_binary_op(char op);
void reset_state();

int yywrap();
%}

%option noinput nounput

DIGIT [0-9]
INT_POSITIVE {DIGIT}+
INT_NEGATIVE -{DIGIT}+
INT ({INT_NEGATIVE}|{INT_POSITIVE})
OPERATOR [+\*^/%]  
MINUS -
WHITESPACE [[:blank:]]+

%%

{WHITESPACE}    { }

{INT}           { 
    if (!error_flag) {
        long long val = atoll(yytext);
        push(val);
    }
}

{OPERATOR}      { 
    if (!error_flag) {
        evaluate_binary_op(yytext[0]);
    }
}

{MINUS}         {
    if (!error_flag) {
        evaluate_binary_op(yytext[0]);
    }
}

\n              { 
    if (error_flag) {
    } else {
        if (stack_ptr == 1) {
            printf("= %lld\n", stack[0]);
        } else if (stack_ptr > 1) {
            fprintf(stderr, "Error: too few operators (remaining %d numbers on stack)\n", stack_ptr);
        } else {
            fprintf(stderr, "Error: empty line or invalid expression\n");
        }
    }
    reset_state();
}

.               {
    if (!error_flag) {
        fprintf(stderr, "Error: bad symbol \"%s\"\n", yytext);
        error_flag = 1;
    }
}

%%
// (Funkcje C pozostają bez zmian)
// ...
// ...

void reset_state() {
    stack_ptr = 0;
    error_flag = 0;
}

void check_stack(int required_args, const char *op_name) {
    if (stack_ptr < required_args) {
        fprintf(stderr, "Error: too few arguments for operator \"%s\"\n", op_name);
        error_flag = 1;
    }
}

void push(long long val) {
    if (stack_ptr >= STACK_SIZE) {
        fprintf(stderr, "Error: stack overflow\n");
        error_flag = 1;
    } else {
        stack[stack_ptr++] = val;
    }
}

long long pop() {
    if (stack_ptr == 0) {
        return 0; 
    }
    return stack[--stack_ptr];
}

void evaluate_binary_op(char op) {
    long long right, left, result;
    const char *op_name = yytext;

    check_stack(2, op_name);
    if (error_flag) return;

    right = pop();
    left = pop();

    switch (op) {
        case '+': result = left + right; break;
        case '-': result = left - right; break;
        case '*': result = left * right; break;
        case '/': 
            if (right == 0) {
                fprintf(stderr, "Error: division by zero\n");
                error_flag = 1;
                return;
            }
            result = left / right;
            break;
        case '%':
            if (right == 0) {
                fprintf(stderr, "Error: modulo by zero\n");
                error_flag = 1;
                return;
            }
            result = left % right;
            break;
        case '^':
            if (right < 0) {
                fprintf(stderr, "Error: negative power (integer only)\n");
                error_flag = 1;
                return;
            }
            result = (long long)pow((double)left, (double)right);
            break;
        default:
            fprintf(stderr, "Error: unknown operator \"%s\"\n", op_name);
            error_flag = 1;
            return;
    }
    push(result);
}

int yywrap() {
    return 1;
}

int main() {
    printf("RPN Calculator. Enter expression (Ctrl+D or Ctrl+C to exit):\n");
    return yylex();
}