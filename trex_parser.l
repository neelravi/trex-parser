/* Include a licence here */


/* Definitions */
%{
#include <stdio.h>          // not sure if stdio is needed here
#include <stdlib.h>         // standard library to process strings and numbers
#include <math.h>           // math functions 

#include "trex_parser.h"
#include "y.tab.h"          // This is generated automatically

void yyerror(char *);
%}


/* Rules */
%%

[a-zA-Z]+       { yylval.str = *yytext - 'a'; return STR; }         /* one or more copies of characters */
[a-zA-Z0-9]+    { yylval.str = *yytext - 'a'; return STR; }         /* Review :: any alphanumeric string */
[1-9][0-9]*     { yylval.val = atoi(yytext); return NUM; }          /* any number of any lenght */
.               yyerror("Character not in the alphabet");           /* Note there is a dot at the beginning */
[ \t\n]+        ;                                                   /* tabs and whitespaces are ignored */

"print"     return PRT;
"write"     return PRT;
"while"		return WHILE;
"if"		return IF;
"else"		return ELSE;
"endif"		return ENDIF;

[-/%*=+;()]       { return *yytext; }

[NEGATION] 	{return *yytext; }


%%
/* Subroutines */

int yywrap(void) {
    return 1;
}

int main(void) {
    return 0;
