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

/* Regular expressions */
integers        [-+]?[0-9]*
floats          [-+]?[0-9]*[.][0-9]+
strings         [a-zA-Z]+



/* Rules */
%%
    /* strings */
{strings}                {sscanf(yytext, "%s", yylval.name); return (STRING);}              /* one or more copies of characters */
    /* Integers */
{integers}               { yylval.number    = atoi(yytext); return INTEGER; }                  /* integer of any lenght */
    /* Floats */
{floats}                 { yylval.number    = atof(yytext); return FLOAT; }                    /* float of any lenght */
    /* skip whitespaces and tabs */
[ \t\n]+        ;                                                                           /* tabs and whitespaces are ignored */
    /* explicit text matching */
"print"                 {return (PRT);}
"write"                 {return (PRT);}
"while"		            {return (WHILE);}
"if"		            {return (IF);}
"else"		            {return (ELSE);}
"endif"		            {return (ENDIF);}
    /* operators */
[-+/%*=;()\n]           { return *yytext; }
    /* operators */
[NEGATION] 	            {return *yytext; }

    /* Everything else is an error */
.                         yyerror("Character not in the alphabet");                     /* Note there is a dot at the beginning */
%%
/* Subroutines */

int yywrap(void) {
    return 1;
}
