%{
#include <stdio.h>
#include <stdlib.h>
#include "calc.tab.h"

void yyerror(const char *s);
extern char err_msg[256];
%}

%option noyywrap
%option yylineno

%%

#.*         {}
\\[ \t]*\n  {}
[0-9]+      {
                yylval.ival = atoll(yytext);
                return NUM;
            }
"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return MULT; }
"/"         { return DIV; }
"^"         { return POW; }
"("         { return LPAREN; }
")"         { return RPAREN; }
\n          { return EOL; }
[ \t\r]+    {}
.           {
                snprintf(err_msg, 256, "Unknown character '%s'", yytext);
                return ERROR; 
            }

%%