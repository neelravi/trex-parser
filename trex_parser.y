// Include :: a copy of licence here

%{                          // C declarations go here
#include <stdio.h>          // needed to handle io
#include <stdlib.h>         // needed to convert string to int
#include <stdarg.h>         // va_list, va_start, va_arg, va_end 
#include "trex_parser.h"    // Attention :: please check if no conflict with this name

nodeType *operator(int oper_id, int n_operands, ...);
nodeType *identifier(int i);
nodeType *constant(int value);
void freedom(nodeType *p);
int interpret(nodeType *p);

// Original from the bison tutorial
int yylex(void);
void yyerror(char const *);

int symbol_table[26]; 
// need to make this a hashtable and change every reference of it in every file
//Map<integer,integer> hm = new HashMap<>();
%}


/* Bison declarations below. */
%token <val>  NUM                               /* Numbers                  */
%token <str>  STR                               /* For strings              */
%token WHILE IF ELSE ENDIF PRT                  /* For special constructs   */
%token LE GE EQUAL LT GT LAND LOR NEG NOT       /* For logical constructs   */


%type  <val>  expr
%type  <str>  string


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
%nonassoc IFX
%nonassoc ELSE

%union { //Create a union to handle the integer input values, the index to the symble table for identifiers, or the
         // pointer for an operator node
    int input_Value;
    char symbol_index;
    nodeType *nodePointer;
};



%type <nodePointer> stmt expr stmt_list

%%


program:
    function	{ exit(0); }
    ;

function:
        function stmt   { interpret($2); freedom($2); }
        | /* NULL */
        ;

stmt:
    ';'				            { $$ = operator(';', 2, NULL, NULL); }
    | expr ';'			        { $$ = $1; }
    | PRT expr ';'		        { $$ = operator(PRT, 1, $2); }
    | VARIABLE '=' expr ';'	    { $$ = operator('=', 2, identifier($1), $3); }
    | WHILE '(' expr ')' stmt   { $$ = operator(WHILE, 2, $3, $5); }
    | IF '(' expr ')' stmt %prec IFX     { $$ = operator(IFX, 2, $3, $5); }
    | IF '(' expr ')' stmt ELSE stmt     { $$ = operator(ELSE, 3, $3, $5, $7); }
    | '{' stmt_list '}'         {$$ = $2; }
    ;

stmt_list:
       stmt                     { $$ = $1; }
    |  stmt_list stmt           { $$ = operator(';', 2, $1, $2); }
    ;

expr: 
    NUM                         { $$ = constant($1);   }                                /* a constant number */
    | VARIABLE                  { $$ = identifier($1); }                                /* a variable name */    
/* arithmatic */
    | expr '+' expr             { $$ = operator('+', 2, $1, $3); }                      /* addition of two operands */
    | expr '-' expr             { $$ = operator('-', 2, $1, $3); }                      /* subtraction of two operands */
    | expr '*' expr             { $$ = operator('*', 2, $1, $3); }                      /* multiplication of two operands */
    | expr '/' expr             { $$ = operator('/', 2, $1, $3); }                      /* divition of two operands */
    | expr '%' expr             { $$ = operator('%', 2, $1, $3); }                      /* modulo operation */
    | '+' expr                  { $$ = $2;                       }                      /* adding + sign behind does nothing */  
    | '-' expr  %prec NEGATION  { $$ = operator(NEGATION, 1, $2);}                      /* Negative of a number */
/* Logical */
    | expr '^' expr             { $$ = operator('^', 2, $1, $3);  }                     /* exponenciation second argument is power */
    | expr '<' expr             { $$ = operator('<', 2, $1, $3);  }                     /* Boolean a < b comparisons of two numbers */
    | expr '>' expr             { $$ = operator('>', 2, $1, $3);  }                     /* Boolean a > b comparisons of two numbers */
    | expr '<=' expr            { $$ = operator('<=', 2, $1, $3); }                     /* Boolean a <= b comparisons of two numbers */
    | expr '>=' expr            { $$ = operator('>=', 2, $1, $3); }                     /* Boolean a >= b comparisons of two numbers */
    | expr 'LT' expr            { $$ = operator('<', 2, $1, $3);  }                     /* Boolean a < b comparisons of two numbers */
    | expr 'GT' expr            { $$ = operator('>', 2, $1, $3);  }                     /* Boolean a > b comparisons of two numbers */
    | expr 'LE'  expr           { $$ = operator('<=', 2, $1, $3); }                     /* Boolean a <= b comparisons of two numbers */
    | expr 'GE'  expr           { $$ = operator('>=', 2, $1, $3); }                     /* Boolean a >= b comparisons of two numbers */
    | expr 'EQUAL' expr         { $$ = operator('==', 2, $1, $3); }                     /* Boolean a == b comparisons of two numbers */
    | expr 'LAND'  expr         { $$ = operator('&&', 2, $1, $3); }                     /* Boolean a && b logical AND */ 
    | expr 'LOR'  expr          { $$ = operator('||', 2, $1, $3); }                     /* Boolean a && b logical OR */ 
;

err:
    expr ',' expr               { fprintf(stderr, "Parser error: comma is not valid operator\n"); exit(1); }
    ;

%%

/*  C code follows below. This can be used to define the operations listed above. */

nodeType *constant(int value) {
    nodeType *p;
    if ((p = malloc(sizeof(nodeType))) == NULL) yyerror("Could not allocate node for constant");

    //set node properties
    p->type = typeConstant;
    p->constant.value = value;

    return p;
}

nodeType *identifier(int i) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL) yyerror("Could not allocate node for identifier");

    p->type = typeIdentifier;
    p->identifier.identifier_index = i;

    return p;
}

nodeType *operator(int oper_id, int n_operands, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending operands array */
    if ((p = malloc(sizeof(nodeType) + (n_operands - 1) * sizeof(nodeType *))) == NULL)
        yyerror("Could not allocate node for operator and its operands!");

    p->type = typeOperator;
    p->operator_.operator_id = oper_id;
    p->operator_.number_of_operands = n_operands;
    va_start(ap, n_operands);
    for (i = 0; i < n_operands; i++) p->operator_.poperands[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freedom(nodeType *p) {
    if (!p) return;
    int i;
    if (p->type == typeOperator)
        for (i = 0; i < p->operator_.number_of_operands; i++) freedom(p->operator_.poperands[i]);
    free(p);
}

void yyerror(char *s) { fprintf(stdout, "CSI3120 calc: %s\n", s);}

int main(void) { yyparse(); return 0; }
