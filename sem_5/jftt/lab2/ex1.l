%{
#include<stdio.h>
int yywrap();
int yylex();
int num_of_lines = 0;
int num_of_words = 0;
int line_had_content = 0;
%}


%%

[[:blank:]]+\n { 
    num_of_lines++;
    if (line_had_content == 1) {
        printf("\n");
    }
    line_had_content = 0;
}

^[[:blank:]]+ ;

[^[:space:]]+ { 
    ECHO;
    num_of_words++; 
    line_had_content = 1;
}

[[:blank:]]+ { 
    printf(" "); 
}

\n { 
    num_of_lines++;
    if (line_had_content == 1) {
        printf("\n");
    }
    line_had_content = 0;
}

%%


int yywrap() {
    if (line_had_content == 1) {
        printf("\n");
    }

    printf("-----\n");
    printf("number of lines: %d\n", num_of_lines);
    printf("number of words: %d\n", num_of_words);
    return 1;
}
int main()
{
    return yylex();
}