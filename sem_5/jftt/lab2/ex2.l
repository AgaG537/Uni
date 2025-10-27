%{
#include <stdio.h>
int yywrap(void);
%}

%option noinput nounput

%x IN_SINGLE_QUOTE
%x IN_DOUBLE_QUOTE
%x IN_TRIPLE_SINGLE
%x IN_TRIPLE_DOUBLE


%%

<INITIAL>"\"\"\"" { 
    BEGIN(IN_TRIPLE_DOUBLE); 
    ECHO; 
}

<INITIAL>"'''" { 
    BEGIN(IN_TRIPLE_SINGLE); 
    ECHO; 
}

<IN_TRIPLE_DOUBLE>"\"\"\"" { 
    BEGIN(INITIAL); 
    ECHO; 
}

<IN_TRIPLE_SINGLE>"'''" { 
    BEGIN(INITIAL); 
    ECHO; 
}

<IN_TRIPLE_DOUBLE,IN_TRIPLE_SINGLE>\\.|[^\n] { ECHO; }
<IN_TRIPLE_DOUBLE,IN_TRIPLE_SINGLE>\n { ECHO; } 



<INITIAL>"'" { 
    BEGIN(IN_SINGLE_QUOTE); 
    ECHO; 
}

<IN_SINGLE_QUOTE>"'" { 
    BEGIN(INITIAL); 
    ECHO; 
}

<IN_SINGLE_QUOTE>\\. { ECHO; }
<IN_SINGLE_QUOTE>[^'\n] { ECHO; }



<INITIAL>\" { 
    BEGIN(IN_DOUBLE_QUOTE); 
    ECHO; 
}

<IN_DOUBLE_QUOTE>\" { 
    BEGIN(INITIAL); 
    ECHO; 
}

<IN_DOUBLE_QUOTE>\\. { ECHO; }
<IN_DOUBLE_QUOTE>[^"\n] { ECHO; }



<INITIAL>#.* {}

<INITIAL>. { ECHO; } 
<INITIAL>\n { ECHO; } 

%%


int yywrap(void) {
    return 1;
}

int main(void) {
    yylex();
    return 0;
}