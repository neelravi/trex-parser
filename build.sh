#!/bin/bash

bison -y -d trex_parser.y
flex trex_parser.l
gcc -c y.tab.c lex.yy.c
gcc y.tab.o lex.yy.o calculator_interpreter_partial.c -o trex_parser
