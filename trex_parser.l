%{
#include <stdio.h>     // not sure if stdio is needed here
#include <stdlib.h>    // standard library to process strings and numbers
#include <math.h>      // math functions 


#include "trex_parser.h"
#include "y.tab.h"

void yyerror(char *);
%}

%%

[ \t\n]+    ; /* whitespaces don't matter */

"print"     return PRT;

"while"		return WHILE;

"if"		return IF;

"else"		return ELSE;

[-/%*=+;()]       { return *yytext; }

[NEGATION] 	{return *yytext; }

[a-z]       { yylval.symbol_index = *yytext - 'a'; return VARIABLE; }

0           { yylval.input_Value = atoi(yytext); return INTEGER; }

[1-9][0-9]* { yylval.input_Value = atoi(yytext); return INTEGER; }

.           yyerror("Character not in the alphabet");
%%

int yywrap(void) {
    return 1;
}








