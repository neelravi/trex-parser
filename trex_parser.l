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
    /* Variables */
[a-zA-Z]+               { yylval.str    = *yytext - 'a'; return STRING; }                  /* one or more copies of characters */
[a-zA-Z0-9]+            { yylval.stran  = *yytext - 'a'; return STRING_ALPHA_NUMERIC; }    /* Review :: any alphanumeric string */
    /* Integers */
[-+]?[0-9]*             { yylval.val    = atoi(yytext); return INTEGER; }                  /* integer of any lenght */
    /* Floats */
[-+]?[0-9]*[.][0-9]+    { yylval.val    = atof(yytext); return FLOAT; }                    /* float of any lenght */
    /* skip whitespaces and tabs */
[ \t\n]+        ;                                                                       /* tabs and whitespaces are ignored */
    /* explicit text matching */
"print"                 return PRT;
"write"                 return PRT;
"while"		            return WHILE;
"if"		            return IF;
"else"		            return ELSE;
"endif"		            return ENDIF;
    /* operators */
[-+/%*=;()\n]           { return *yytext; }
    /* operators */
[NEGATION] 	            {return *yytext; }

    /* Everything else is and error */
.                         yyerror("Character not in the alphabet");                     /* Note there is a dot at the beginning */
%%
/* Subroutines */

int yywrap(void) {
    return 1;
}
