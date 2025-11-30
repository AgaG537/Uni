%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define P 1234577
#define P_EXP 1234576

int yylex(void);

char err_msg[256]; 

void yyerror(const char *s) {
    if (err_msg[0] == 0) {
        snprintf(err_msg, 256, "%s", s);
    }
}

long long norm_p(long long a);
long long norm_exp(long long a);
long long add(long long a, long long b);
long long sub(long long a, long long b);
long long mult(long long a, long long b);
long long power(long long base, long long exp);
long long inverse(long long n);
char* concat_rpn(char* s1, char* s2, char* op);
char* num_to_str(long long val);

%}

%define parse.error verbose

%code requires {
    typedef struct {
        long long val;
        char *rpn;
    } expr_t;
}

%union {
    long long ival;
    expr_t expr;
}

%token <ival> NUM
%token PLUS MINUS MULT DIV POW LPAREN RPAREN EOL ERROR

%left PLUS MINUS
%left MULT DIV
%nonassoc POW
%precedence UMINUS

%type <expr> expr

%%

input:
    | input line
    ;

line:
    EOL
    | expr EOL {
        printf("%s\n", $1.rpn);
        printf("Result: %lld\n", norm_p($1.val)); 
        free($1.rpn);
        err_msg[0] = 0;
    }
    | error EOL {
        printf("Error: %s\n", err_msg);
        err_msg[0] = 0;
        yyerrok;
    }
    ;

expr:
    NUM {
        $$.val = $1; 
        $$.rpn = num_to_str($1);
    }
    | expr PLUS expr {
        $$.val = add($1.val, $3.val);
        $$.rpn = concat_rpn($1.rpn, $3.rpn, "+");
        free($1.rpn); free($3.rpn);
    }
    | expr MINUS expr {
        $$.val = sub($1.val, $3.val);
        $$.rpn = concat_rpn($1.rpn, $3.rpn, "-");
        free($1.rpn); free($3.rpn);
    }
    | expr MULT expr {
        $$.val = mult($1.val, $3.val);
        $$.rpn = concat_rpn($1.rpn, $3.rpn, "*");
        free($1.rpn); free($3.rpn);
    }
    | expr DIV expr {
        if (norm_p($3.val) == 0) {
            snprintf(err_msg, 256, "Division by zero");
            yyerror("Division by zero"); 
            YYERROR;
        }
        $$.val = mult($1.val, inverse($3.val));
        $$.rpn = concat_rpn($1.rpn, $3.rpn, "/");
        free($1.rpn); free($3.rpn);
    }
    | expr POW expr {
        $$.val = power($1.val, $3.val);
        $$.rpn = concat_rpn($1.rpn, $3.rpn, "^");
        free($1.rpn); free($3.rpn);
    }
    | MINUS expr %prec UMINUS {
        $$.val = -($2.val);
        free($2.rpn);
        $$.rpn = num_to_str($$.val); 
    }
    | LPAREN expr RPAREN {
        $$ = $2;
    }
    ;

%%

long long norm_p(long long a) {
    long long res = a % P;
    if (res < 0) res += P;
    return res;
}

long long norm_exp(long long a) {
    long long res = a % P_EXP;
    if (res < 0) res += P_EXP;
    return res;
}

long long add(long long a, long long b) { return norm_p(a + b); }
long long sub(long long a, long long b) { return norm_p(a - b); }
long long mult(long long a, long long b) { return norm_p(a * b); }

long long power(long long base, long long exp) {
    long long res = 1;
    base = norm_p(base);
    exp = norm_exp(exp);
    while (exp > 0) {
        if (exp % 2 == 1) res = mult(res, base);
        base = mult(base, base);
        exp /= 2;
    }
    return res;
}

long long inverse(long long n) {
    long long t = 0, newt = 1;
    long long r = P, newr = norm_p(n);
    while (newr != 0) {
        long long quotient = r / newr;
        long long temp_t = t; t = newt; newt = temp_t - quotient * newt;
        long long temp_r = r; r = newr; newr = temp_r - quotient * newr;
    }
    if (r > 1) return 0;
    if (t < 0) t += P;
    return t;
}

char* concat_rpn(char* s1, char* s2, char* op) {
    size_t len = strlen(s1) + strlen(s2) + strlen(op) + 3;
    char* res = malloc(len);
    if (!res) exit(1);
    sprintf(res, "%s %s %s", s1, s2, op);
    return res;
}

char* num_to_str(long long val) {
    char* res = malloc(32);
    sprintf(res, "%lld", norm_p(val));
    return res;
}

int main() {
    err_msg[0] = 0;
    return yyparse();
}