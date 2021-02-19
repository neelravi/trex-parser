// Include :: a copy of licence here

%{                          // C declarations go here
#include <stdio.h>          // needed to handle io
#include <math.h>          // needed to handle math
#include <stdlib.h>         // needed to convert string to int
#include <stdarg.h>         // va_list, va_start, va_arg, va_end 
#include "trex_parser.h"    // Attention :: please check if no conflict with this name

#define YYSTYPE double

// Original from the bison tutorial
int yylex(void);
void yyerror(char const *);

int symbol_table[26]; 
// need to make this a hashtable and change every reference of it in every file
//Map<integer,integer> hm = new HashMap<>();
%}


/* Bison/Yacc declarations below. */
%token <number>     INTEGER                           /* Integer                  */
%token <number>     FLOAT                             /* float                    */
%token <name>       STRING                            /* For strings              */
%token WHILE IF ELSE ENDIF PRT                  /* For special constructs   */
%token LE GE EQUAL LT GT LAND LOR NEG NOT       /* For logical constructs   */


%type  <number>  expr
%type  <name>  string


// arithmatic operators 
%left '-' '+'
%left '*' '/' '%'

// arithmatic exponenciation 
%right '^'   

// logical operators acting on left
%left '<' '>' '<=' '>=' LE GE LT GT EQUAL 
%left LAND LOR
%left NEG NOT  

// rest 
%left ','
%left ')'
%right '='

// keywords
%nonassoc NEGATION
%nonassoc IF
%nonassoc ELSE
%nonassoc WHILE
%nonassoc ENDIF

%union { //Create a union to handle the integer input values, the index to the symble table for identifiers, or the
         // pointer for an operator node
    int number;
    float number;    
    char name[1000];

};


/* grammar follows */
%%
    
input:     /* empty line */ 
     | input stmt
    ;

stmt:
    ';'				            
    | expr ';'			                { $$ = $1;             }
    | PRT expr ';'		                { $$ = $1; printf($1); }
    | VARIABLE '=' expr ';'	            { $$ = assignment('=', $1, $3); }
    | WHILE '(' expr ')' stmt           { $$ = operator(WHILE, $3, $5); }
    | IF '(' expr ')' stmt %prec IFX    { $$ = operator(IF, $3, $5); }
    | IF '(' expr ')' stmt ELSE stmt    { $$ = operator(ELSE,$3, $5, $7); }
    ;

expr: 
    INTEGER                     { $$ = $1;       }                      /* a constant number */
/* arithmatic */
    | expr '+' expr             { $$ =  $1 + $3; }                      /* addition of two operands */
    | expr '-' expr             { $$ =  $1 - $3; }                      /* subtraction of two operands */
    | expr '*' expr             { $$ =  $1 * $3; }                      /* multiplication of two operands */
    | expr '/' expr             { $$ =  $1 / $3; }                      /* divition of two operands */
    | expr '%' expr             { $$ =  $1 % $3; }                      /* modulo operation */
    | '+' expr                  { $$ = $2;       }                      /* adding + sign behind does nothing */  
    | '-' expr  %prec NEGATION  { $$ = -$2;      }                      /* Negative of a number */
    | expr '^' expr             { $$ =  $1 ^ $3; }                     /* exponenciation second argument is power */
/* Logical */
    | expr '<' expr             { $$ =  $1 < $3; }                     /* Boolean a < b comparisons of two numbers */
    | expr '>' expr             { $$ =  $1 > $3; }                     /* Boolean a > b comparisons of two numbers */
    | expr '<=' expr            { $$ =  $1 <= $3; }                     /* Boolean a <= b comparisons of two numbers */
    | expr '>=' expr            { $$ =  $1 >= $3; }                     /* Boolean a >= b comparisons of two numbers */
    | expr 'LT' expr            { $$ =  $1 < $3;  }                     /* Boolean a < b comparisons of two numbers */
    | expr 'GT' expr            { $$ =  $1 > $3;  }                     /* Boolean a > b comparisons of two numbers */
    | expr 'LE'  expr           { $$ =  $1 <= $3; }                     /* Boolean a <= b comparisons of two numbers */
    | expr 'GE'  expr           { $$ =  $1 >= $3; }                     /* Boolean a >= b comparisons of two numbers */
    | expr 'EQUAL' expr         { $$ =  $1 == $3; }                     /* Boolean a == b comparisons of two numbers */
    | expr 'LAND'  expr         { $$ =  $1 && $3; }                     /* Boolean a && b logical AND */ 
    | expr 'LOR'  expr          { $$ =  $1 || $3; }                     /* Boolean a && b logical OR */ 
;

err:
    expr ',' expr               { fprintf(stderr, "Parser error: comma is not valid operator\n"); exit(1); }
    ;

%%

/*  C code follows below. This can be used to define the operations listed above. */



void yyerror(char *s) { fprintf(stdout, "Error in parsing : %s\n", s);}

int main(void) { yyparse(); return 0; }
