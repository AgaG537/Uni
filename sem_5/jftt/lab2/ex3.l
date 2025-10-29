%{
#include <stdio.h>
#include <stdbool.h>
bool doxygen_mode = true; 
int yywrap(void);
%}

%option noinput nounput

%x IN_C_COMMENT
%x IN_DOXYGEN_COMMENT
%x IN_DOUBLE_QUOTE
%x IN_SINGLE_QUOTE
%x IN_SINGLE_LINE
%x IN_SINGLE_LINE_DOXYGEN


%%

<INITIAL>\"         { BEGIN(IN_DOUBLE_QUOTE); ECHO; }
<INITIAL>'          { BEGIN(IN_SINGLE_QUOTE); ECHO; }

<IN_DOUBLE_QUOTE>\\. { ECHO; }
<IN_SINGLE_QUOTE>\\. { ECHO; }
<IN_DOUBLE_QUOTE>\"   { BEGIN(INITIAL); ECHO; }
<IN_SINGLE_QUOTE>'    { BEGIN(INITIAL); ECHO; }

<IN_DOUBLE_QUOTE>.   { ECHO; }
<IN_SINGLE_QUOTE>.   { ECHO; }



<INITIAL>#.* { ECHO; }

<INITIAL>"/**/" { printf(" "); }



<INITIAL>"/**" {
    if (doxygen_mode) {
        BEGIN(IN_DOXYGEN_COMMENT);
        ECHO;
    } else {
        BEGIN(IN_C_COMMENT);
    }
}

<INITIAL>"/*!" {
    if (doxygen_mode) {
        BEGIN(IN_DOXYGEN_COMMENT);
        ECHO;
    } else {
        BEGIN(IN_C_COMMENT);
    }
}

<INITIAL>"/*" {
    BEGIN(IN_C_COMMENT);
}

<IN_C_COMMENT>"*/" {
    BEGIN(INITIAL);
}
<IN_DOXYGEN_COMMENT>"*/" {
    BEGIN(INITIAL);
    ECHO;
}


<IN_C_COMMENT>\\\n {}
<IN_C_COMMENT>\n { ECHO; }
<IN_C_COMMENT>. {} 

<IN_DOXYGEN_COMMENT>\\\n { ECHO; }
<IN_DOXYGEN_COMMENT>\n { ECHO; }
<IN_DOXYGEN_COMMENT>.  { ECHO; } 



<INITIAL>"///" {
    if (doxygen_mode) {
        BEGIN(IN_SINGLE_LINE_DOXYGEN);
        ECHO;
    } else {
        BEGIN(IN_SINGLE_LINE);
    }
}
<INITIAL>"//!" {
    if (doxygen_mode) {
        BEGIN(IN_SINGLE_LINE_DOXYGEN);
        ECHO;
    } else {
        BEGIN(IN_SINGLE_LINE);
    }
}

<INITIAL>"//" {
    BEGIN(IN_SINGLE_LINE);
}

<IN_SINGLE_LINE>\\\n {} 
<IN_SINGLE_LINE>\n { ECHO; BEGIN(INITIAL); }
<IN_SINGLE_LINE>. {}

<IN_SINGLE_LINE_DOXYGEN>\\\n { ECHO; }
<IN_SINGLE_LINE_DOXYGEN>\n { ECHO; BEGIN(INITIAL); }
<IN_SINGLE_LINE_DOXYGEN>. { ECHO; }


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